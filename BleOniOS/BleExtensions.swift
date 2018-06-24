//
//  BleExtensions.swift
//  BleOniOS
//
//  Created by たけのこ on 2018/06/24.
//  Copyright © 2018年 たけのこ. All rights reserved.
//

import Foundation

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
