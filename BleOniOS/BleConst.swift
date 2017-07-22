//
//  BleConst.swift
//  BleOniOS
//
//  Created by たけのこ on 2017/07/23.
//  Copyright © 2017年 たけのこ. All rights reserved.
//

import Foundation
import CoreBluetooth

struct BleConst {
    static let SERVICE_BLE_SERIAL = "FEED0001-C497-4476-A7ED-727DE7648AB1"
    static let UUID_NOTIFY = "FEEDAA03-C497-4476-A7ED-727DE7648AB1"
    static let UUID_WRITE = "FEEDAA02-C497-4476-A7ED-727DE7648AB1"
    
    static let U_SERVICE_BLE_SERIAL: [CBUUID] = [CBUUID.init(string: "FEED0001-C497-4476-A7ED-727DE7648AB1")]
    static let U_UUID_WRITE: [CBUUID] = [CBUUID.init(string: "FEEDAA02-C497-4476-A7ED-727DE7648AB1")]
}
