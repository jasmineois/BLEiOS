//
//  BLESerial3Maneger.swift
//  BleOniOS
//
//  Created by たけのこ on 2017/07/23.
//  Copyright © 2017年 たけのこ. All rights reserved.
//

import CoreBluetooth

protocol BleManagerProtocol: class, CBCentralManagerDelegate, CBPeripheralDelegate {
    /// （変数）BLEが使えるか
    var centralManagerReady: Bool { get }
    /// （変数）ペリフェラルが使えるか
    var peripheralReady: Bool { get }
    /// （変数）見つけたペリフェラル
    var discoverdPeripheral: [CBPeripheral] { get }
    /// （変数）見つけたサービス
    var servidces: [CBService] { get }
    /// （変数）見つけたキャラスティック
    var bleCharacteristics: [BleCharacteristic] { get }
    /// （変数）見つけたディスクリプト
    var descriptors: [CBDescriptor] { get }
    /// UUIDを検索
    func scan(serviceUUID : [CBUUID]?, characteristicsUUID : [CBUUID]?)
    /// BLE（ペリフェラル）に接続開始
    func connectPeripheral(peripheral: CBPeripheral)
    /// スキャンを中止
    func stopScan()
}

class BleManager: NSObject, BleManagerProtocol  {
    
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    
    /// （変数）BLEが使えるか
    var centralManagerReady = false
        
    /// （変数）ペリフェラルが使えるか
    var peripheralReady = false
    
    /// （変数）見つけたペリフェラル
    var discoverdPeripheral: [CBPeripheral] = []
    
    /// （変数）見つけたサービス
    var servidces: [CBService] = []
    
    /// （変数）見つけたキャラスティック
    private var characteristics: [CBCharacteristic] = []
    var bleCharacteristics: [BleCharacteristic] = []
    
    /// （変数）見つけたディスクリプト
    var descriptors: [CBDescriptor] = []
    
    var serviceUUID : [CBUUID]!;
    var characteristicsUUID : [CBUUID]!;
    
    /// イニシャライザ
    override init() {
        super.init();
        print("init called.")
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    /// UUIDを検索
    func scan(serviceUUID : [CBUUID]?, characteristicsUUID : [CBUUID]?) {
        print("scan called.")
        if !self.centralManagerReady { return }
        self.serviceUUID = serviceUUID
        self.characteristicsUUID = characteristicsUUID
        self.centralManager?.scanForPeripherals(withServices: self.serviceUUID, options: nil)
    }
    
    /// CBCentralManagerの状態が変化
    ///
    /// - Parameter central: セントラルの情報
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("centralManagerDidUpdateState")
        switch central.state {
        case .poweredOn: self.centralManagerReady = true
        default: break
        }
        print("centralManagerReady: \(centralManagerReady)")
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
        for p in discoverdPeripheral where p.identifier.uuidString == peripheral.identifier.uuidString {
            return
        }
        discoverdPeripheral.append(peripheral)
    }
    
    
    /// BLE（ペリフェラル）に接続開始
    ///
    /// - Parameter peripheral: 接続するペリフェラル
    func connectPeripheral(peripheral: CBPeripheral) {
        print("connect peripheral: \(peripheral)")
        self.peripheral = peripheral
        self.centralManager.connect(self.peripheral, options: nil)
    }
    
    
    /// BLE（ペリフェラル）に接続成功
    ///
    /// - Parameters:
    ///   - central: セントラルの情報
    ///   - peripheral: 接続したペリフェラルの情報
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connect peripheral: \(peripheral)")
        self.scanService()
    }
    
    /// サービスを検索
    func scanService() {
        self.peripheral.delegate = self
        self.peripheral.discoverServices(self.serviceUUID)
    }
    
    /// サービスを発見
    ///
    /// - Parameters:
    ///   - peripheral: ペリフェラルの情報
    ///   - error: エラー情報
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("discover service: \(peripheral)")
        self.servidces = peripheral.services ?? []
        for service in peripheral.services ?? [] {
            self.scanCharacteristics(service)
        }
    }
    
    /// キャラスタリスティックを検索
    ///
    /// - Parameter service: サービスの情報
    func scanCharacteristics(_ service: CBService) {
        self.peripheral.discoverCharacteristics(self.characteristicsUUID, for: service)
    }
    
    /// キャラスタリスティックを発見
    ///
    /// - Parameters:
    ///   - peripheral: ペリフェラルの情報
    ///   - service: サービスの情報
    ///   - error: エラー情報
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("discover characteristic: \(peripheral)")
        self.characteristics = service.characteristics ?? []
        self.peripheralReady = true
        
        for chara in characteristics {
            self.scanDescriptor(chara)
            self.readValue(characteristic: chara)
            self.notifyValue(characteristic: chara)
        }
    }
    
    /// ディスクリプトを検索
    ///
    /// - Parameter characteristic: キャラスタリスティック
    func scanDescriptor(_ characteristic: CBCharacteristic) {
        self.peripheral.discoverDescriptors(for: characteristic)
    }
    
    /// ディスクリプトを発見
    ///
    /// - Parameters:
    ///   - peripheral: ペリフェラルの情報
    ///   - characteristic: キャラスタリスティック
    ///   - error: エラー情報
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        print("discover descriptors: \(peripheral)")
        
        for descriptor in characteristic.descriptors ?? [] {
            var addFlag = false
            for (index, descr) in self.descriptors.enumerated() where (descr.uuid.uuidString == descriptor.uuid.uuidString)
                && (descr.characteristic.uuid.uuidString == descriptor.characteristic.uuid.uuidString) {
                self.descriptors[index] = descr
                addFlag = true
            }
            if !addFlag {
                self.descriptors.append(descriptor)
            }
        }

        for descr in characteristic.descriptors ?? [] {
            self.readValue(descriptor: descr)
            //self.notifyValue(descr)
        }
    }
    
    /// キャラスタリスティックの値を取得
    ///
    /// - Parameter characteristic:
    func readValue(characteristic: CBCharacteristic) {
        self.peripheral.readValue(for: characteristic)
    }
    
    /// キャラスタリスティックの値を取得
    ///
    /// - Parameters:
    ///   - peripheral: ペリフェラルの情報
    ///   - characteristic: キャラスタリスティック
    ///   - error: エラー情報
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("didUpdateValueFor peripheral: \(peripheral.identifier.uuidString) characteristic \(characteristic)")
        var bChar = BleCharacteristic(type: BleCharacteristicType.read, uuid: characteristic.uuid)
        
        var addFlag = false
        for (index, chara) in self.bleCharacteristics.enumerated() where chara.type == bChar.type && chara.uuid.uuidString == bChar.uuid.uuidString {
            bChar = self.bleCharacteristics[index]
            bChar.value = characteristic.value
            self.bleCharacteristics[index] = bChar
            addFlag = true
        }
        if !addFlag {
            bChar.value = characteristic.value
            self.bleCharacteristics.append(bChar)
        }
    }
    
    /// ディスクリプトの値を取得
    ///
    /// - Parameter characteristic:
    func readValue(descriptor: CBDescriptor) {
        self.peripheral.readValue(for: descriptor)
    }
    
    /// ディスクリプトの値を取得
    ///
    /// - Parameters:
    ///   - peripheral: ペリフェラルの情報
    ///   - characteristic: キャラスタリスティック
    ///   - error: エラー情報
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        print("didUpdateValueFor peripheral: \(peripheral.identifier.uuidString) descriptor \(descriptor)")
        
        for (index, chara) in self.bleCharacteristics.enumerated() where (chara.uuid.uuidString == descriptor.characteristic.uuid.uuidString) {
            var newChara = chara
            switch descriptor.uuid.uuidString {
            case "2901": newChara.descript  = castValue(descriptor.value)
            case "2902": newChara.conf      = castValue(descriptor.value)
            case "2904": newChara.format    = castFormat(descriptor.value)
            default: break
            }
            self.bleCharacteristics[index] = newChara
        }
    }
    
    /// キャラスタリスティックの値を通知
    ///
    /// - Parameter characteristic:
    func notifyValue(characteristic: CBCharacteristic) {
        self.peripheral.setNotifyValue(true, for: characteristic)
    }
    
    /// キャラスタリスティックの値を通知
    ///
    /// - Parameters:
    ///   - peripheral: ペリフェラルの情報
    ///   - characteristic: キャラスタリスティック
    ///   - error: エラー情報
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("didUpdateNotifFor peripheral: \(peripheral.identifier.uuidString) characteristic \(characteristic)")
        var bChar = BleCharacteristic(type: BleCharacteristicType.notify, uuid: characteristic.uuid)
        bChar.value = characteristic.value
        
        var addFlag = false
        for (index, chara) in self.bleCharacteristics.enumerated() where  chara.type == bChar.type && chara.uuid.uuidString == bChar.uuid.uuidString  {
            self.bleCharacteristics[index] = bChar
            addFlag = true
        }
        if !addFlag {
            self.bleCharacteristics.append(bChar)
        }
    }
    
    /// ディスクリプトの値を通知
    ///
    /// - Parameter characteristic:
    func writeValue(descriptor: CBDescriptor, data: Data) {
        self.peripheral.writeValue(data, for: descriptor)
    }
    
    /// スキャンを中止
    func stopScan() {
        self.centralManager.stopScan()
    }
    
    func castValue(_ value: Any?) -> String {
        var str = value as? String
        if str == nil {
            str = (value as? Int)?.description
        }
        if str == nil {
            str = (value as? Data)?.toString()
        }
        return str ?? "<NOT CAST>"
    }
    
    func castFormat(_ value: Any?) -> Format? {
        return Format(rawValue: (value as? Data)?.toUInt8()[0] ?? 0)
    }
}
