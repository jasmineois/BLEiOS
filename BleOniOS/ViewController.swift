//
//  ViewController.swift
//  BleOniOS
//
//  Created by たけのこ on 2017/07/22.
//  Copyright © 2017年 たけのこ. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var bleManager : BleManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print("viewDidLoad called.")
        bleManager = BleManager();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Up Button
    @IBAction func onClickForUpButton(_ sender: UIButton) {
        print(sender.tag)
        if !bleManager.peripheralReady { return }
        var val: Int!
        switch sender.tag {
            case 1001: val = 1 // UP
            case 1002: val = 2 // LEFT
            case 1003: val = 3 // DOWN
            case 1004: val = 4 // RIGHT
        default: val = 0
        }
        let data: NSData = NSData.init(bytes: &val, length: 1)
        bleManager.peripheral.writeValue(data as Data, for: bleManager.characteristic, type: .withoutResponse)
    }
    
    // Menu Button
    @IBAction func onClickForMenuButton(_ sender: UIButton) {
        bleManager.scan(serviceUUID: BleConst.U_SERVICE_BLE_SERIAL,characteristicsUUID: BleConst.U_UUID_WRITE)
    }
    
}

