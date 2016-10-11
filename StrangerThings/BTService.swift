//
//  BTService.swift
//  StrangerThings
//
//  Created by Chris Nielubowicz on 9/30/16.
//  Copyright © 2016 Chris Nielubowicz. All rights reserved.
//

import Foundation
import CoreBluetooth

class BTService: NSObject {
    
    let peripheral: CBPeripheral
    var positionCharacteristic: CBCharacteristic?
    var writeData: [UInt8] = []
    internal var inFlight: Bool = false
    
    internal var queue: DispatchQueue = DispatchQueue(label: "bluetooth")
    internal var timer: Timer?
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        super.init()
        self.peripheral.delegate = self
    }
    
    deinit {
        self.reset()
    }
    
    func reset() {
        self.sendBTServiceNotificationWithIsBluetoothConnected(false)
    }
    
    func startDiscovery() {
        self.peripheral.discoverServices([RWT_BLE_SERVICE_UUID])
    }
}

extension BTService: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard peripheral == self.peripheral else { return }
        guard error == nil else { return }
        
        let uuidsForBTService = [RWT_POSITION_CHAR_UUID];
        guard let services = peripheral.services , services.count > 0 else { return }
        for service in services {
            if service.uuid == RWT_BLE_SERVICE_UUID {
                peripheral.discoverCharacteristics(uuidsForBTService, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        guard peripheral == self.peripheral else { return }
        guard error == nil else { return }
        
        for characteristic in characteristics {
            if characteristic.uuid == RWT_POSITION_CHAR_UUID {
                self.positionCharacteristic = characteristic
                self.sendBTServiceNotificationWithIsBluetoothConnected(true)
            }
        }
    }
    
    @objc internal func dequeCharacter() {
        self.timer = nil
        guard let character = self.writeData.first else { return }
        self.writeData.removeFirst()
        self.writeBLE(character: character)
        if self.writeData.count > 0 {
            self.timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(dequeCharacter), userInfo: nil, repeats: false)
        }
    }
}

// MARK - Private
extension BTService {
    public func write(character: UInt8) {
        self.writeData.append(character)
        guard self.timer == nil else { return }
        self.timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(dequeCharacter), userInfo: nil, repeats: false)
        self.writeData.removeFirst()
        self.writeBLE(character: character)
    }
    
    internal func writeBLE(character: UInt8) {
        var character = character
        guard let positionCharacteristic = self.positionCharacteristic else { return }
        let data = Data(bytes: &character, count: MemoryLayout<UInt8>.size)
        self.peripheral.writeValue(data, for: positionCharacteristic, type: .withResponse)
    }
    
    internal func sendBTServiceNotificationWithIsBluetoothConnected(_ connected: Bool) {
        let connectionDetails = ["isConnected" : connected]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: RWT_BLE_SERVICE_CHANGED_STATUS_NOTIFICATION), object: connectionDetails)
    }
}

