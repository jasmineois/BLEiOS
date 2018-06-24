//
//  ViewController.swift
//  BleOniOS
//
//  Created by たけのこ on 2017/07/22.
//  Copyright © 2017年 たけのこ. All rights reserved.
//

import UIKit

protocol  ViewControllerCallback {
    func update()
}

class ViewController: UIViewController, ViewControllerCallback, UITableViewDelegate, UITableViewDataSource {

    var viewModel: ViewModelProtocol!
    
    @IBOutlet var button: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var indicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad called.")
        viewModel = ViewModel(bleManager: BleManager(), vc: self)
        button.addTarget(self, action: #selector(self.tapButton), for: UIControlEvents.touchDown)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
        indicator.hidesWhenStopped = true
        self.update()
    }
    
    @objc func tapButton() {
        print("tap button.")
        viewModel.onClickButton()
    }
    
    func update() {
        tableView.reloadData()
        button.setTitle(viewModel.status.rawValue, for: UIControlState.normal)
        viewModel.status != Status.READY ? indicator.startAnimating() : indicator.stopAnimating()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["Peripheral", "Service", "Characteristic", "Descriptor"][section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:     return viewModel.peripheralList.count
        case 1:     return viewModel.serviceList.count
        case 2:     return viewModel.characteristicList.count
        default:    return viewModel.descriptorList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = (indexPath.section != 3)
            ? tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            : tableView.dequeueReusableCell(withIdentifier: "descriptorCell", for: indexPath)
        let label1: UILabel = cell.viewWithTag(1) as! UILabel
        let label2: UILabel = cell.viewWithTag(2) as! UILabel
        let label3: UILabel = cell.viewWithTag(3) as! UILabel
        switch indexPath.section {
        case 0:
            label1.text = viewModel.peripheralList[indexPath.row].name
            label2.text = viewModel.peripheralList[indexPath.row].identifier
            label3.text = viewModel.peripheralList[indexPath.row].value
        case 1:
            label1.text = viewModel.serviceList[indexPath.row].name
            label2.text = viewModel.serviceList[indexPath.row].identifier
            label3.text = viewModel.serviceList[indexPath.row].value
        case 2:
            label1.text = viewModel.characteristicList[indexPath.row].name
            label2.text = viewModel.characteristicList[indexPath.row].identifier
            label3.text = viewModel.characteristicList[indexPath.row].value
        default:
            label1.text = viewModel.descriptorList[indexPath.row].name
            label2.text = viewModel.descriptorList[indexPath.row].identifier
            label3.text = viewModel.descriptorList[indexPath.row].value
            // label3.isHidden =  label3.text == ""
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.onClickTableCell(index: indexPath.row)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
