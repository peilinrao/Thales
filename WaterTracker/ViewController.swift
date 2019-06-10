//
//  ViewController.swift
//  WaterTracker
//
//  Created by Peilin Rao on 6/8/19.
//  Copyright © 2019 Peilin. All rights reserved.
//

import UIKit
import CoreBluetooth

let BeetleCBUUID = CBUUID(string: "0xDFB0")
let BeetleCharUUID = CBUUID(string: "0xDFB1")
var beetlePeripheral: CBPeripheral!
class ViewController: UIViewController {
    @IBOutlet weak var weightLabel: UILabel!
    var centralManager: CBCentralManager!
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        // Do any additional setup after loading the view.
//        weightLabel.font = UIFont.monospacedDigitSystemFont(ofSize: weightLabel.font!.pointSize, weight: .regular)
    }
    
    func onWeightReceived(_ weight: Int){
        weightLabel.text = String(weight)
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
        case .poweredOn:
            print("state poweredOn")
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
            print(characteristic)
//            if characteristic.properties.contains(.read){
//                print("\(characteristic.uuid): it can read")
//            }
//            if characteristic.properties.contains(.notify){
//                print("\(characteristic.uuid): it can notify")
//            }
            if (characteristic.uuid == BeetleCharUUID) {
                // If it is, subscribe to it
                peripheral.setNotifyValue(true, for: characteristic);
                print("Subscribed characteristic")
            }
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,error: Error?){
        if (characteristic.uuid == BeetleCharUUID) {
            print(characteristic.value ?? "no value")
            let str = String(decoding: (characteristic.value)!, as: UTF8.self)
            print(str)
            
        }
    }
}
