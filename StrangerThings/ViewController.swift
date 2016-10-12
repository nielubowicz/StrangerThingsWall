//
//  ViewController.swift
//  StrangerThings
//
//  Created by Chris Nielubowicz on 9/30/16.
//  Copyright © 2016 Chris Nielubowicz. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textToTheUpsideDown: UILabel!
    
    var bluetooth: BTDiscovery?
    var textToSend: String = "" {
        didSet {
            self.textToTheUpsideDown.text = textToSend
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bluetooth = BTDiscovery()
        self.bluetooth?.delegate = self
        self.bluetooth?.startScanning()
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let char = string.utf8CString.first else { return false }
        self.textToSend.append(string)
        self.bluetooth?.bleService?.write(character: UInt8(char))
        return true
    }
    
}

extension ViewController: BTServiceDelegate {
    func peripheral(peripheral: CBPeripheral, didConnect connected: Bool) {
        let color = connected ? UIColor.green : UIColor.red
        DispatchQueue.main.async {
            self.view.backgroundColor = color
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValue value: AnyObject?) {
        guard self.textToSend.characters.count > 0 else { return }
        self.textToSend.remove(at: self.textToSend.startIndex)
    }
}
