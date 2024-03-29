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
let parameter = 17.12 //should be set to 2.5
let water_per_bottle = 30.0 //should be set to 250
var dict: [String: Double] = [:] //Date and water drunk
var dict_list: [Int: Double] = [:] //Time and water drunk
var zeros = Array(repeating: 0.0, count: 1440)
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
    @IBOutlet weak var readings: UILabel!
    @IBOutlet weak var todayIntake: UILabel!
    @IBOutlet weak var valid: UILabel!
    @IBOutlet weak var info: UILabel!
    @IBOutlet weak var txtDatePicker: UITextField!
    @IBOutlet weak var chart: Chart!
    @IBOutlet weak var nerd_button: UIButton!
    
    
    @IBOutlet weak var bottle_1: UIImageView!
    @IBOutlet weak var bottle_2: UIImageView!
    @IBOutlet weak var bottle_3: UIImageView!
    @IBOutlet weak var bottle_4: UIImageView!
    @IBOutlet weak var bottle_5: UIImageView!
    @IBOutlet weak var bottle_6: UIImageView!
    @IBOutlet weak var bottle_7: UIImageView!
    @IBOutlet weak var bottle_8: UIImageView!
    
    var centralManager: CBCentralManager!
    let datePicker = UIDatePicker()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        valid.isHidden = true
//        readings.isHidden = true
        self.readings.isHidden = true;
        self.valid.isHidden = true;
        self.info.isHidden = true;
        centralManager = CBCentralManager(delegate: self, queue: nil)
        showDatePicker()
        self.chart.isHidden = true;
        self.view.backgroundColor = #colorLiteral(red: 0.04537009448, green: 0.1424690783, blue: 0.2587065697, alpha: 1);
        self.nerd_button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
//        startRepeating()
//        print("Here")
//        let series = ChartSeries([1.2, 0])
//        chart.add(series)
        
        self.bottle_1.isHidden = true;
        self.bottle_2.isHidden = true;
        self.bottle_3.isHidden = true;
        self.bottle_4.isHidden = true;
        self.bottle_5.isHidden = true;
        self.bottle_6.isHidden = true;
        self.bottle_7.isHidden = true;
        self.bottle_8.isHidden = true;
       
    }
    
    func showWaterBottles(){
        
    }
    
    @objc func buttonAction(sender: UIButton!) {
        if (self.readings.isHidden == true){
            self.readings.isHidden = false;
            self.valid.isHidden = false;
            self.info.isHidden = false;
        }else{
            self.readings.isHidden = true;
            self.valid.isHidden = true;
            self.info.isHidden = true;
        }
    }
    
    
//    func startRepeating(){
//        _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {_ in
//
//            // Flush on the other day
////             print("Updating chart")
//            let hour = Calendar.current.component(.hour, from: Date())
//            let minute = Calendar.current.component(.minute, from: Date())
//            let minute_day = minute + hour * 60
//            if minute_day == 0{
//                zeros = Array(repeating: 0.0, count: 1440)
//            }
//
//            var list = Array(repeating: 0.0, count: 1440)
//            for i in 0...1439{
//                if i == 0{
//                    list[i] = zeros[i]
//                    continue
//                }else{
//                    list[i] = list[i-1]+zeros[i]
//                }
//            }
//            self.chart.removeAllSeries()
//            let series = ChartSeries(list)
//            self.chart.add(series)
//        }
//    }
    
    
 
    
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
        txtDatePicker.text = dat_req+": "+String(dict[dat_req] ?? -1)+"ml"
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
        print("cp1")
        if (characteristic.uuid == BeetleCharUUID) {
            print("cp2")
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
                    let water_ml = dict[cur_dat] ?? 0 * parameter
                    todayIntake.text = String(dict[cur_dat] ?? 0 * parameter)+"ml"
                    
                    //Update bottle graph
                    self.bottle_1.isHidden = true;
                    self.bottle_2.isHidden = true;
                    self.bottle_3.isHidden = true;
                    self.bottle_4.isHidden = true;
                    self.bottle_5.isHidden = true;
                    self.bottle_6.isHidden = true;
                    self.bottle_7.isHidden = true;
                    self.bottle_8.isHidden = true;
                    if (water_ml > water_per_bottle){self.bottle_1.isHidden = false;}
                    if (water_ml > 2*water_per_bottle){self.bottle_2.isHidden = false;}
                    if (water_ml > 3*water_per_bottle){self.bottle_3.isHidden = false;}
                    if (water_ml > 4*water_per_bottle){self.bottle_4.isHidden = false;}
                    if (water_ml > 5*water_per_bottle){self.bottle_5.isHidden = false;}
                    if (water_ml > 6*water_per_bottle){self.bottle_6.isHidden = false;}
                    if (water_ml > 7*water_per_bottle){self.bottle_7.isHidden = false;}
                    if (water_ml > 8*water_per_bottle){self.bottle_8.isHidden = false;}
                    
                    let hour = Calendar.current.component(.hour, from: Date())
                    let minute = Calendar.current.component(.minute, from: Date())
                    let minute_day = minute + hour * 60
                    dict_list[minute_day] = dict[cur_dat]
                    lastvalid = num
                }else{
                    lastvalid = num
                }
                valid.text = "Valid reading:"+String(num*parameter)+"ml"
            }
            lastnum = num
        }
    }
}
