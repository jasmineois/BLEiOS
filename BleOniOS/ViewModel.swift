//
//  ViewModel.swift
//  BleOniOS
//
//  Created by たけのこ on 2018/06/23.
//  Copyright © 2018年 たけのこ. All rights reserved.
//

import Foundation

struct TableCell {
    var name: String
    var identifier: String
    var value: String
}

enum Status: String {
    case READY      = "スキャン開始"
    case SCANNING   = "スキャン中"
    case PAIRING    = "ペアリング中"
}

protocol ViewModelProtocol {
    var status: Status {get}
    var peripheralList: [TableCell] { get }
    var serviceList: [TableCell] { get }
    var characteristicList: [TableCell] { get }
    var descriptorList: [TableCell] { get }
    var logText: String {get}
    func onClickButton()
    func onClickTableCell(index: Int)
}

class ViewModel: ViewModelProtocol {
    
    var bleManager: BleManagerProtocol!
    var vc: ViewControllerCallback!
    
    var logText = ""
    var status = Status.READY
    var peripheralList: [TableCell] = []
    var serviceList: [TableCell] = []
    var characteristicList: [TableCell] = []
    var descriptorList: [TableCell] = []
    
    init(bleManager: BleManagerProtocol, vc: ViewControllerCallback) {
        self.bleManager = bleManager
        self.vc = vc
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.timerUpdate), userInfo: nil, repeats: true)
    }
    
    // Up Button
    func onClickButton() {
        print("onClickButton")
        self.status = Status.SCANNING
        self.bleManager.scan(serviceUUID: nil, characteristicsUUID: nil)
        if !self.bleManager.peripheralReady { return }
    }
    
    func onClickTableCell(index: Int) {
        print("onClickTableCell")
        self.status = Status.PAIRING
        self.bleManager.stopScan()
        self.bleManager.connectPeripheral(peripheral: self.bleManager.discoverdPeripheral[index])
    }
    
    func writeValue() {
        // self.bleManager.scan(serviceUUID: BleConst.U_SERVICE_BLE_SERIAL,characteristicsUUID: BleConst.U_UUID_WRITE)
        // var val: Int!
        // let data: NSData = NSData.init(bytes: &val, length: 1)
        // bleManager.peripheral.writeValue(data as Data, for: bleManager.characteristic, type: .withoutResponse)
    }
    
    @objc func timerUpdate() {
        peripheralList = []
        serviceList = []
        characteristicList = []
        descriptorList = []
        for peripheral in self.bleManager.discoverdPeripheral {
            peripheralList.append(TableCell(
                name: peripheral.name ?? "",
                identifier: peripheral.identifier.uuidString,
                value: ""
            ))
        }
        for servidce in self.bleManager.servidces {
            serviceList.append(TableCell(
                name: servidce.uuid.uuidString,
                identifier: servidce.description,
                value: ""
            ))
        }
        for characteristic in self.bleManager.readCharacteristics {
            characteristicList.append(TableCell(
                name: "[read]" + characteristic.uuid.uuidString,
                identifier: characteristic.description,
                value: characteristic.value?.toString() ?? ""
            ))
        }
        for characteristic in self.bleManager.writeCharacteristics {
            characteristicList.append(TableCell(
                name: "[write]" + characteristic.uuid.uuidString,
                identifier: characteristic.description,
                value: characteristic.value?.toString() ?? ""
            ))
        }
        for characteristic in self.bleManager.notifyCharacteristics {
            characteristicList.append(TableCell(
                name: "[notify]" + characteristic.uuid.uuidString,
                identifier: characteristic.description,
                value: characteristic.value?.toString() ?? ""
            ))
        }
        for descriptor in self.bleManager.readDescriptors {
            descriptorList.append(TableCell(
                name: "[read]" + descriptor.uuid.uuidString,
                identifier: descriptor.description,
                value: ""
            ))
        }
        vc.update()
    }
}
