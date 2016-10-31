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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let string = textField.text?.lowercased() else { return }
        self.textToSend.append(string)
        string.utf8CString.forEach { (char) in
            self.bluetooth?.bleService?.write(character: UInt8(char))
        }
        textField.text = nil
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
