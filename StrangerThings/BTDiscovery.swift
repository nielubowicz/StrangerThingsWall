//
//  BTDiscovery.swift
//  StrangerThings
//
//  Created by Chris Nielubowicz on 9/30/16.
//  Copyright © 2016 Chris Nielubowicz. All rights reserved.
//

import CoreBluetooth

class BTDiscovery: NSObject {
    
    var centralManager: CBCentralManager?
    var peripheralBLE: CBPeripheral?
    var bleService: BTService? {
        willSet {
            self.bleService?.reset()
        }
        didSet {
            self.bleService?.startDiscovery()
        }
    }
    
    override init() {
        let queue = DispatchQueue(label: "com.strangerthings")
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: queue)
    }
    
    func startScanning() {
        self.centralManager?.scanForPeripherals(withServices: [RWT_BLE_SERVICE_UUID], options: nil)
    }
    
    internal func clearDevices() {
        self.bleService = nil
        self.peripheralBLE = nil
    }
}

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
            self.bleService = BTService(peripheral: peripheral)
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
