//
//  BTDiscovery.swift
//  StrangerThings
//
//  Created by Chris Nielubowicz on 9/30/16.
//  Copyright © 2016 Chris Nielubowicz. All rights reserved.
//

import CoreBluetooth

class BTDiscovery: NSObject {
    
    private(set) var queue: DispatchQueue?
    var centralManager: CBCentralManager?
    var peripheralManager: CBPeripheralManager?
    var peripheralBLE: CBPeripheral?
    
    weak var delegate: BTServiceDelegate?

    var bleService: BTService? {
        willSet {
            self.bleService?.reset()
        }
        didSet {
            self.bleService?.startDiscovery()
        }
    }
    
    override init() {
        self.queue = DispatchQueue(label: "com.strangerthings")
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: self.queue)
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: self.queue)
    }
    
    func startScanning() {
        self.centralManager?.scanForPeripherals(withServices: [RWT_BLE_SERVICE_UUID], options: nil)
    }
    
    internal func clearDevices() {
        self.bleService = nil
        self.peripheralBLE = nil
    }
}

// MARK: - CBCentralManagerDelegate
extension BTDiscovery: CBCentralManagerDelegate {
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Be sure to retain the peripheral or it will fail during connection.
        
        // Validate peripheral information
        guard let name = peripheral.name, name.characters.count > 0 else { return }
        //        if self.peripheralBLE?.state == .disconnected {
        self.peripheralBLE = peripheral
        
        self.bleService = nil
        self.centralManager?.connect(peripheral, options: nil)
        //        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == self.peripheralBLE {
            self.bleService = BTService(peripheral: peripheral, delegate: self.delegate)
        }
        
        self.centralManager?.stopScan()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral == self.peripheralBLE {
            self.bleService = nil
            self.peripheralBLE = nil
        }
        
        self.startScanning()
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard let centralManager = self.centralManager else { return }
        switch centralManager.state {
        case .poweredOff:
            self.clearDevices()
            break
        case .poweredOn:
            self.startScanning()
            break
        case .resetting:
            self.clearDevices()
            break
        default:
            break
        }
    }
}

// MARK: - CBPeripheralManagerDelegate
extension BTDiscovery: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) { }

}
