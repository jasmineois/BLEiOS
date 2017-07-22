//
//  BLESerial3Maneger.swift
//  BleOniOS
//
//  Created by たけのこ on 2017/07/23.
//  Copyright © 2017年 たけのこ. All rights reserved.
//

import CoreBluetooth


class BleManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    var characteristic: CBCharacteristic!
    
    /// （変数）BLEが使えるか
    var centralManagerReady = false;
    
    /// （変数）ペリフェラルが使えるか
    var peripheralReady = false
    
    /// （変数）見つけたペリフェラルの名前
    var peripheralName = ""
    
    var serviceUUID : [CBUUID]!;
    var characteristicsUUID : [CBUUID]!;
    
    
    /// イニシャライザ
    override init() {
        super.init();
        print("init called.")
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    
    /// UUIDを検索
    func scan(serviceUUID : [CBUUID], characteristicsUUID : [CBUUID]) {
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
    ///   - advertisementData: <#advertisementData description#>
    ///   - RSSI: RSSI description
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("found peripheral: \(peripheral)")
        self.stopScan()
        self.connectPeripheral(peripheral: peripheral)
    }
    
    
    /// BLE（ペリフェラル）に接続開始
    ///
    /// - Parameter peripheral: 接続するペリフェラル
    func connectPeripheral(peripheral: CBPeripheral) {
        print("start peripheral: \(peripheral)")
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
        self.peripheralName = peripheral.name!
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
        let service: CBService = peripheral.services![0]
        self.scanCharacteristics(service)
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
        self.characteristic = service.characteristics![0]
        self.peripheralReady = true
    }
    
    
    /// スキャンを中止
    func stopScan() {
        self.centralManager.stopScan()
    }

}
