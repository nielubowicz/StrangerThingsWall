//
//  ViewController.swift
//  StrangerThings
//
//  Created by Chris Nielubowicz on 9/30/16.
//  Copyright © 2016 Chris Nielubowicz. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var positionSlider: UISlider!
    
    var bluetooth: BTDiscovery?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(connectionChanged(_:)), name: NSNotification.Name(rawValue:RWT_BLE_SERVICE_CHANGED_STATUS_NOTIFICATION), object: nil)
        
        self.bluetooth = BTDiscovery()
        self.bluetooth?.startScanning()
    }
    
    @objc func connectionChanged(_ notification: Notification) {
        guard let connectionDetails = notification.object as? [String : AnyObject] else { return }
        guard let connected = connectionDetails["isConnected"] as? Bool else { return }
        
        let color = connected ? UIColor.green : UIColor.red
        DispatchQueue.main.async {
            self.view.backgroundColor = color
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let char = string.utf8CString.first else { return false }
        self.bluetooth?.bleService?.write(character: UInt8(char))
        return true
    }
    
}
