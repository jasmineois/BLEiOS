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
    
    private var bleManager: Manager!
    var vc: ViewControllerCallback!
    
    var logText = ""
    var status = Status.READY
    var peripheralList: [TableCell] = []
    var serviceList: [TableCell] = []
    var characteristicList: [TableCell] = []
    var descriptorList: [TableCell] = []
    
    init(bleManager: Manager, vc: ViewControllerCallback) {
        self.bleManager = bleManager
        self.vc = vc
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.timerUpdate), userInfo: nil, repeats: true)
    }
    
    // Up Button
    func onClickButton() {
        print("onClickButton")
        self.status = Status.SCANNING
        self.bleManager.scan(serviceUUID: nil)
        if !self.bleManager.peripheralReady { return }
    }
    
    func onClickTableCell(index: Int) {
        print("onClickTableCell")
        self.status = Status.PAIRING
        self.bleManager.stopScan()
        self.bleManager.connectPeripheral(peripheral: self.bleManager.discoverdGATT[index].peripheral)
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
        for gatt in self.bleManager.discoverdGATT {
            peripheralList.append(TableCell(
                name: gatt.peripheral.name ?? "",
                identifier: gatt.peripheral.identifier.uuidString,
                value: ""
            ))
            for servidce in gatt.services {
                serviceList.append(TableCell(
                    name: servidce.uuid.uuidString,
                    identifier: servidce.description,
                    value: ""
                ))
            }
            for characteristic in gatt.characteristics {
                characteristicList.append(TableCell(
                    name: "\(characteristic.value.uuid.uuidString)",
                    identifier: "\(characteristic.value)",
                    value: "\(characteristic.value.value)"
                ))
            }
            for descriptor in gatt.descriptors {
                descriptorList.append(TableCell(
                    name: "\(descriptor.value.uuid.uuidString)",
                    identifier: "\(descriptor.value.uuid)",
                    value: "\(descriptor.value.value)"
                ))
            }
        }
        vc.update()
    }
}
