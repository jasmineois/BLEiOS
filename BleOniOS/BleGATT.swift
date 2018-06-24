//
//  BleGATT.swift
//  BleOniOS
//
//  Created by たけのこ on 2018/06/25.
//  Copyright © 2018年 たけのこ. All rights reserved.
//

import CoreBluetooth

struct BleGATT {
    /// （変数）見つけたペリシャラル
    var peripheral: CBPeripheral
    /// （変数）見つけたサービス
    var services: [CBService] = []
    /// （変数）見つけたキャラスティック
    var characteristics: [String: CBCharacteristic] = [:]
    var readCharacteristics: [String: CBCharacteristic] = [:]
    var writeCharacteristics: [String: CBCharacteristic] = [:]
    var notifyCharacteristics: [String: CBCharacteristic] = [:]
    /// （変数）見つけたディスクリプト
    var descriptors: [String: CBDescriptor] = [:]
    var readDescriptors: [String: CBDescriptor] = [:]
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
    }
}

extension BleGATT {
    
//    mutating func updataService(service: CBService) {
//        for (i, s) in services.enumerated() where s.uuid.uuidString == service.uuid.uuidString {
//            self.services[i] = service
//        }
//        services.append(service)
//    }
//    
//    mutating func updataCharacteristic(characteristic: CBCharacteristic) {
//        for (i, c) in characteristics.enumerated() where c.uuid.uuidString == characteristic.uuid.uuidString {
//            self.characteristics[i] = characteristic
//        }
//        characteristics.append(characteristic)
//    }
//    
//    mutating func updataDescriptor(descriptor: CBDescriptor) {
//        for (i, d) in descriptors.enumerated() where d.uuid.uuidString == descriptor.uuid.uuidString {
//            descriptors[i] = descriptor
//        }
//        descriptors.append(descriptor)
//    }
}
