//
//  BleDelegate.swift
//  BleOniOS
//
//  Created by たけのこ on 2018/06/23.
//  Copyright © 2018年 たけのこ. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BleDelegateProtocol: class, CBCentralManagerDelegate, CBPeripheralDelegate {

}

class BleDelegate: NSObject, BleDelegateProtocol {
    
    private let manager: Manager
    
    init(bleManager: Manager) {
        self.manager = bleManager
        super.init()
    }
    
    /// CBCentralManagerの状態が変化
    ///
    /// - Parameter central: セントラルの情報
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("centralManagerDidUpdateState")
        switch central.state {
        case .poweredOn: self.manager.centralManagerReady = true
        default: break
        }
        print("centralManagerReady: \(self.manager.centralManagerReady)")
    }
    
    /// BLE(ペリフェラル)が見つかった
    ///
    /// - Parameters:
    ///   - central: セントラルの情報
    ///   - peripheral: 発見したペリフェラル
    ///   - advertisementData:
    ///   - RSSI: RSSI description
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("found peripheral: \(peripheral)")
        if peripheral.name == nil {
            return
        }
        for gatt in self.manager.discoverdGATT where gatt.peripheral.identifier.uuidString == peripheral.identifier.uuidString {
            return
        }
        self.manager.discoverdGATT.append(BleGATT(peripheral: peripheral))
    }

    /// BLE（ペリフェラル）に接続成功
    ///
    /// - Parameters:
    ///   - central: セントラルの情報
    ///   - peripheral: 接続したペリフェラルの情報
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connect peripheral: \(peripheral)")
        self.manager.scanService(serviceUUID: nil)
    }
    
    /// サービスを発見
    ///
    /// - Parameters:
    ///   - peripheral: ペリフェラルの情報
    ///   - error: エラー情報
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("discover service: \(peripheral)")
        for (index, gatt) in self.manager.discoverdGATT.enumerated() where gatt.peripheral.identifier.uuidString == peripheral.identifier.uuidString {
            self.manager.discoverdGATT[index].services = peripheral.services ?? []
            for service in peripheral.services ?? [] {
                self.manager.scanCharacteristics(service, characteristicsUUID: nil)
            }
        }
    }
    
    /// キャラスタリスティックを発見
    ///
    /// - Parameters:
    ///   - peripheral: ペリフェラルの情報
    ///   - service: サービスの情報
    ///   - error: エラー情報
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("discover characteristic: \(peripheral)")
        self.manager.peripheralReady = true
        for (index, gatt) in self.manager.discoverdGATT.enumerated() where gatt.peripheral.identifier.uuidString == peripheral.identifier.uuidString {
            for chara in service.characteristics ?? [] {
                self.manager.discoverdGATT[index].characteristics[chara.uuid.uuidString] = chara
                self.manager.scanDescriptor(chara)
                self.manager.readValue(characteristic: chara)
                self.manager.notifyValue(characteristic: chara)
            }
        }
    }
    
    /// キャラスタリスティックの値を取得
    ///
    /// - Parameters:
    ///   - peripheral: ペリフェラルの情報
    ///   - characteristic: キャラスタリスティック
    ///   - error: エラー情報
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("didUpdateValueFor peripheral: \(peripheral.identifier.uuidString) characteristic \(characteristic)")
        for (index, gatt) in self.manager.discoverdGATT.enumerated() where gatt.peripheral.identifier.uuidString == peripheral.identifier.uuidString {
            self.manager.discoverdGATT[index].readCharacteristics[characteristic.uuid.uuidString] = characteristic
        }
    }
    
    /// キャラスタリスティックの値を通知
    ///
    /// - Parameters:
    ///   - peripheral: ペリフェラルの情報
    ///   - characteristic: キャラスタリスティック
    ///   - error: エラー情報
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("didUpdateNotifFor peripheral: \(peripheral.identifier.uuidString) characteristic \(characteristic)")
        for (index, gatt) in self.manager.discoverdGATT.enumerated() where gatt.peripheral.identifier.uuidString == peripheral.identifier.uuidString {
            self.manager.discoverdGATT[index].notifyCharacteristics[characteristic.uuid.uuidString] = characteristic
        }
    }
    
    /// ディスクリプトを発見
    ///
    /// - Parameters:
    ///   - peripheral: ペリフェラルの情報
    ///   - characteristic: キャラスタリスティック
    ///   - error: エラー情報
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        print("discover descriptors: \(peripheral)")
        for (index, gatt) in self.manager.discoverdGATT.enumerated() where gatt.peripheral.identifier.uuidString == peripheral.identifier.uuidString {
            for desc in characteristic.descriptors ?? [] {
                self.manager.discoverdGATT[index].descriptors[desc.uuid.uuidString] = desc
                self.manager.readValue(descriptor: desc)
            }
        }
    }
    
    /// ディスクリプトの値を取得
    ///
    /// - Parameters:
    ///   - peripheral: ペリフェラルの情報
    ///   - characteristic: キャラスタリスティック
    ///   - error: エラー情報
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        print("didUpdateValueFor peripheral: \(peripheral.identifier.uuidString) descriptor \(descriptor)")
        for (index, gatt) in self.manager.discoverdGATT.enumerated() where gatt.peripheral.identifier.uuidString == peripheral.identifier.uuidString {
            self.manager.discoverdGATT[index].readDescriptors[descriptor.uuid.uuidString] = descriptor
//            switch descriptor.uuid.uuidString {
//            case "2901": newChara.descript  = BleUtil.castValue(descriptor.value)
//            case "2902": newChara.conf      = BleUtil.castValue(descriptor.value)
//            case "2904": newChara.format    = BleUtil.castFormat(descriptor.value)
//            default: break
//            }
        }
    }
}
