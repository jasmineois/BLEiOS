//
//  BLESerial3Maneger.swift
//  BleOniOS
//
//  Created by たけのこ on 2017/07/23.
//  Copyright © 2017年 たけのこ. All rights reserved.
//

import CoreBluetooth

protocol BleManagerVariable: class {
    /// （変数）BLEが使えるか
    var centralManagerReady: Bool { get set }
    /// （変数）ペリフェラルが使えるか
    var peripheralReady: Bool { get set }
    /// （変数）GATT
    var discoverdGATT: [BleGATT] { get set }
}

protocol BleManagerProtocol: class {
    /// UUIDを検索
    func scan(serviceUUID : [CBUUID]?)
    /// BLE（ペリフェラル）に接続開始
    func connectPeripheral(peripheral: CBPeripheral)
    /// サービスを検索
    func scanService(serviceUUID : [CBUUID]?)
    /// スキャンを中止
    func stopScan()
    /// キャラスタリスティックを検索
    func scanCharacteristics(_ service: CBService, characteristicsUUID : [CBUUID]?)
    /// ディスクリプトを検索
    func scanDescriptor(_ characteristic: CBCharacteristic)
    /// キャラスタリスティックの値を取得
    func readValue(characteristic: CBCharacteristic)
    /// ディスクリプトの値を取得
    func readValue(descriptor: CBDescriptor)
    /// キャラスタリスティックの値を通知
    func notifyValue(characteristic: CBCharacteristic)
}

class BleManager: NSObject, BleManagerVariable, BleManagerProtocol {
    
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    var delegate: BleDelegateProtocol?
    
    /// （変数）BLEが使えるか
    var centralManagerReady = false
    
    /// （変数）ペリフェラルが使えるか
    var peripheralReady = false
    
    /// （変数）見つけたペリフェラル
    var discoverdGATT: [BleGATT] = []
    var bleCharacteristics: [BleCharacteristic] = []
    
    /// イニシャライザ
    override init() {
        super.init()
        print("init called.")
        self.delegate = BleDelegate(bleManager: self)
        self.centralManager = CBCentralManager(delegate: self.delegate, queue: nil)
    }
    
    /// UUIDを検索
    func scan(serviceUUID : [CBUUID]?) {
        print("scan called.")
        if !self.centralManagerReady { return }
        self.centralManager?.scanForPeripherals(withServices: serviceUUID, options: nil)
    }
        
    /// BLE（ペリフェラル）に接続開始
    ///
    /// - Parameter peripheral: 接続するペリフェラル
    func connectPeripheral(peripheral: CBPeripheral) {
        print("connect peripheral: \(peripheral)")
        self.peripheral = peripheral
        self.centralManager.connect(self.peripheral, options: nil)
    }
    
    /// サービスを検索
    func scanService(serviceUUID : [CBUUID]?) {
        self.peripheral.delegate = self.delegate
        self.peripheral.discoverServices(serviceUUID)
    }
        
    /// キャラスタリスティックを検索
    ///
    /// - Parameter service: サービスの情報
    func scanCharacteristics(_ service: CBService, characteristicsUUID : [CBUUID]?) {
        self.peripheral.discoverCharacteristics(characteristicsUUID, for: service)
    }
    
    /// ディスクリプトを検索
    ///
    /// - Parameter characteristic: キャラスタリスティック
    func scanDescriptor(_ characteristic: CBCharacteristic) {
        self.peripheral.discoverDescriptors(for: characteristic)
    }
    
    /// キャラスタリスティックの値を取得
    ///
    /// - Parameter characteristic:
    func readValue(characteristic: CBCharacteristic) {
        self.peripheral.readValue(for: characteristic)
    }
        
    /// ディスクリプトの値を取得
    ///
    /// - Parameter characteristic:
    func readValue(descriptor: CBDescriptor) {
        self.peripheral.readValue(for: descriptor)
    }
    
    /// キャラスタリスティックの値を通知
    ///
    /// - Parameter characteristic:
    func notifyValue(characteristic: CBCharacteristic) {
        self.peripheral.setNotifyValue(true, for: characteristic)
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
}
