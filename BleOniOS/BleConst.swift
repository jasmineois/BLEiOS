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

enum BleCharacteristicType {
    case read
    case write
    case notify
}

struct BleCharacteristic {
    var type: BleCharacteristicType
    var uuid: CBUUID
    var value: Data?        = nil
    var descript: String    = "" // 2901
    var conf: String        = "" // 2902
    var format: Format?     = nil // 2904
    init(type: BleCharacteristicType, uuid: CBUUID) {
        self.type = type
        self.uuid = uuid
    }
}

enum Format: UInt8 {
    case uint8    = 0x04
    case ​​uint16   = 0x06
    case ​​uint32   = 0x08
    case ​​​uint64   = 0x0A
    case ​uint128  = 0x0B
    case ​​sint8    = 0x0C
    case ​​sint16   = 0x0E
    case ​​sint32   = 0x10
    case ​​sint64   = 0x12
    case ​​sint128  = 0x13
    case ​​float32  = 0x14
    case ​​float64  = 0x15
    case ​SFLOAT   = 0x16
    case ​​​​utf8     = 0x19
    case utf16    = 0x1A
    case ​​​​struct   = 0x1B
}
