//
//  ViewController.swift
//  WaterTracker
//
//  Created by Peilin Rao on 6/8/19.
//  Copyright © 2019 Peilin. All rights reserved.
//

import UIKit
import CoreBluetooth

var cur_dat = ""

var dict: [String: Double] = [:] //Date and water drunk
var dict_list: [String: Double] = [:] //Time and water drunk
var lastvalid = -1.0
var stringBuffer = ""
var doubleBuffer = ""
var singlestr = ""
var lastnum = -1.0
var countSame = 0
let BeetleCBUUID = CBUUID(string: "0xDFB0")
let BeetleCharUUID = CBUUID(string: "0xDFB1")
var beetlePeripheral: CBPeripheral!
class ViewController: UIViewController {
    
    let chart = Chart(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
    let series = ChartSeries([0, 6.5, 2, 8, 4.1, 7, -3.1, 10, 8])
    chart.add(series)
    
    
    @IBOutlet weak var readings: UILabel!
    @IBOutlet weak var todayIntake: UILabel!
    @IBOutlet weak var valid: UILabel!
    @IBOutlet weak var info: UILabel!
    @IBOutlet weak var txtDatePicker: UITextField!
    var centralManager: CBCentralManager!
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        showDatePicker()
    }
    
    
    func showDatePicker(){
        //Formate Date
        datePicker.datePickerMode = .date
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        txtDatePicker.inputAccessoryView = toolbar
        txtDatePicker.inputView = datePicker
        
    }
    
    @objc func donedatePicker(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let dat_req = formatter.string(from: datePicker.date)
        print("Selecting:"+dat_req)
        txtDatePicker.text = String(dict[dat_req] ?? -1)+"ml"
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }

   

}

extension ViewController:CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state{
        case .unknown:
            print("state unknown")
        case .resetting:
            print("state resetting")
        case .unsupported:
            print("state unsupported")
        case .unauthorized:
            print("state unauthorized")
        case .poweredOff:
            print("state poweredOff")
            info.text = "Please Turn on Bluetooth!"
        case .poweredOn:
            print("state poweredOn")
            info.text = "Scanning for Your Device..."
            centralManager.scanForPeripherals(withServices: [BeetleCBUUID])
        @unknown default:
            print("???")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)
        beetlePeripheral = peripheral
        beetlePeripheral.delegate = self
        centralManager.stopScan()
        centralManager.connect(beetlePeripheral)
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        info.text = "Connecting to Your Device..."
        print("Beetle connected!")
        beetlePeripheral.discoverServices([BeetleCBUUID])
    }

}
extension ViewController: CBPeripheralDelegate{
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {return}
        for service in services{
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {return}
        for characteristic in characteristics{
            if (characteristic.uuid == BeetleCharUUID) {
                // If it is, subscribe to it
                peripheral.setNotifyValue(true, for: characteristic);
                print("Subscribed characteristic")
                info.text = "Successful Connection"
            }
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,error: Error?){
        if (characteristic.uuid == BeetleCharUUID) {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            cur_dat = formatter.string(from: Date())
            print(cur_dat)
            
            
            print(characteristic.value ?? "no value")
            let str = String(decoding: (characteristic.value)!, as: UTF8.self)
            print(str)
            readings.text = "Current reading: "+str
            let num = Double(str) ?? 0.0
            if(num == lastnum){
                
                if(num>0){
                    countSame += 1
                }else{
                    countSame = 0
                }
            }else{
                countSame = 0
            }
            //If we get 3 same num, we can assume it is a valid reading
            if(countSame == 3){
                countSame = 0
                if (num < lastvalid){
                    dict[cur_dat] = (dict[cur_dat] ?? 0.0+(lastvalid-num))
                    todayIntake.text = "Intake: "+String(dict[cur_dat] ?? 0*2.5)+"ml"
                }else{
                    lastvalid = num
                }
                valid.text = "Valid reading:"+String(num*2.5)+"ml"
            }
            lastnum = num
        }
    }
}
