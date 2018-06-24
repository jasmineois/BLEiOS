//
//  BleExtensions.swift
//  BleOniOS
//
//  Created by たけのこ on 2018/06/24.
//  Copyright © 2018年 たけのこ. All rights reserved.
//

import Foundation

typealias Manager = BleManagerVariable & BleManagerProtocol

extension Data {
    
    func toString() -> String {
        var str : String = ""
        let bytes = [UInt8](self)
        for b in bytes { str = String(format: "%@ %02x", str, b) }
        return "[" + str + " ]"
    }
    
    func toUInt8() -> [UInt8] {
        return [UInt8](self)
    }
}

struct BleUtil {
    static func castValue(_ value: Any?) -> String {
        var str = value as? String
        if str == nil {
            str = (value as? Int)?.description
        }
        if str == nil {
            str = (value as? Data)?.toString()
        }
        return str ?? "<NOT CAST>"
    }
    static func castFormat(_ value: Any?) -> Format? {
        return Format(rawValue: (value as? Data)?.toUInt8()[0] ?? 0)
    }
}
