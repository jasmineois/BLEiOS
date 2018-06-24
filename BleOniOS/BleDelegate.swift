//
//  BleDelegate.swift
//  BleOniOS
//
//  Created by たけのこ on 2018/06/23.
//  Copyright © 2018年 たけのこ. All rights reserved.
//

import Foundation
import CoreBluetooth

class BleDelegate: NSObject {
    
    static let shared = BleDelegate()
    
    /// （変数）BLEが使えるか
    var centralManagerReady = false;
    
    private override init() {
        
    }

}
