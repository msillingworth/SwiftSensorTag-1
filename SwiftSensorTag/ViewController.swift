//
//  ViewController.swift
//  SwiftSensorTag
//
//  Created by Anas Imtiaz on 13/11/2015.
//  Copyright © 2015 Anas Imtiaz. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, CBPeripheralManagerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    // Title labels
    var titleLabel : UILabel!
    var statusLabel : UILabel!
    
    // BLE
    var centralManager : CBCentralManager!
    var sensorTagPeripheral : CBPeripheral!
    var peripheralManager: CBPeripheralManager!
    
    // Table View
    var sensorTagTableView : UITableView!
    
    // Sensor Values
    var allSensorLabels : [String] = []
    var allSensorValues : [Double] = []
    var ambientTemperature : Double!
    var objectTemperature : Double!
    var accelerometerX : Double!
    var accelerometerY : Double!
    var accelerometerZ : Double!
    var relativeHumidity : Double!
    var magnetometerX : Double!
    var magnetometerY : Double!
    var magnetometerZ : Double!
    var gyroscopeX : Double!
    var gyroscopeY : Double!
    var gyroscopeZ : Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Initialize central manager on load
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        // Set up title label
        titleLabel = UILabel()
        titleLabel.text = "Sensor Tag"
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        titleLabel.sizeToFit()
        titleLabel.center = CGPoint(x: self.view.frame.midX, y: self.titleLabel.bounds.midY+28)
        self.view.addSubview(titleLabel)
        
        // Set up status label
        statusLabel = UILabel()
        statusLabel.textAlignment = NSTextAlignment.Center
        statusLabel.text = "Loading..."
        statusLabel.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        statusLabel.sizeToFit()
        //statusLabel.center = CGPoint(x: self.view.frame.midX, y: (titleLabel.frame.maxY + statusLabel.bounds.height/2) )
        statusLabel.frame = CGRect(x: self.view.frame.origin.x, y: self.titleLabel.frame.maxY, width: self.view.frame.width, height: self.statusLabel.bounds.height)
        self.view.addSubview(statusLabel)
        
        // Set up table view
        setupSensorTagTableView()
        
        // Initialize all sensor values and labels
        allSensorLabels = SensorTag.getSensorLabels()
        for (var i=0; i<allSensorLabels.count; i++) {
            allSensorValues.append(0)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     /******* CBCentralPeripheralDelegate *******/
    
    func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {
        
        print("WATCH OUT")
//        print(service)
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic) {
        
        print("!)!)!)!)!)!)!)!)")
        
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        if peripheral.state != CBPeripheralManagerState.PoweredOn
        {
            print("no power")
            return
        }
        
        print("powered on")
        let serviceCBUUID = CBUUID(string: "5DC90000-8F79-462B-98D7-C1F8C766FA47")
        let transferService:CBMutableService = CBMutableService(type: serviceCBUUID, primary: true)
        let characteristicBUUID = CBUUID(string: "5DC90001-8F79-462B-98D7-C1F8C766FA47")
        var intVal: NSInteger = 1
        let valueData:NSData = NSData(bytes: &intVal, length: sizeof(NSInteger))
        let transferCharacteristic = CBMutableCharacteristic(type: characteristicBUUID, properties: .Notify, value: nil, permissions: .Readable)
        
        transferService.characteristics = [transferCharacteristic as CBCharacteristic]
        self.peripheralManager.addService(transferService)
        self.peripheralManager.startAdvertising(nil)

        
    }
    
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
//        print("HAHAHAHAHAHAHAHAH")
    }
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveReadRequest request: CBATTRequest) {
        
        print("!!!!!!!!!!!!!!!!!!!!!")
//
    }
    
    
    /******* CBCentralManagerDelegate *******/
     
     // Check status of BLE hardware
    func centralManagerDidUpdateState(central: CBCentralManager) {
        if central.state == CBCentralManagerState.PoweredOn {
            // Scan for peripherals if BLE is turned on
            central.scanForPeripheralsWithServices(nil, options: nil)
            self.statusLabel.text = "Searching for BLE Devices"
        }
        else {
            // Can have different conditions for all states if needed - show generic alert for now
            showAlertWithText("Error", message: "Bluetooth switched off or not initialized")
        }
    }
    
    
    // Check out the discovered peripherals to find Sensor Tag
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        if SensorTag.sensorTagFound(advertisementData) == true {
            
            // Update Status Label
            self.statusLabel.text = "Sensor Tag Found"
            
            // Stop scanning, set as the peripheral to use and establish connection
            self.centralManager.stopScan()
            self.sensorTagPeripheral = peripheral
//            print("id")
//            print(self.sensorTagPeripheral.identifier)
            self.sensorTagPeripheral.delegate = self
            self.centralManager.connectPeripheral(peripheral, options: nil)
        }
        else {
            self.statusLabel.text = "Sensor Tag NOT Found"
            //showAlertWithText(header: "Warning", message: "SensorTag Not Found")
        }
    }
    
    // Discover services of the peripheral
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        self.statusLabel.text = "Discovering peripheral services"
        peripheral.discoverServices(nil)
    }
    
    
    // If disconnected, start searching again
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
//        print("error")
//        print(error)
        self.statusLabel.text = "Disconnected"
        central.scanForPeripheralsWithServices(nil, options: nil)
    }
    
    func centralManager(central: CBCentralManager, willRestoreState dict: [String : AnyObject]) {
        print("ciekawe")
    }
    /******* CBCentralPeripheralDelegate *******/
     
     // Check if the service discovered is valid i.e. one of the following:
     // IR Temperature Service
     // Accelerometer Service
     // Humidity Service
     // Magnetometer Service
     // Barometer Service
     // Gyroscope Service
     // (Others are not implemented)
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        self.statusLabel.text = "Looking at peripheral services"
        print("looking for p services")
        for service in peripheral.services! {
            print("dsd")
//            print(service)
            let thisService = service as CBService
            if SensorTag.validService(thisService) {
                // Discover characteristics of all valid services
                peripheral.discoverCharacteristics(nil, forService: thisService)
            }
        }
    }
    
    
    // Enable notification and sensor for each characteristic of valid service
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        self.statusLabel.text = "Enabling sensors"
        
        var enableValue = 1
        let enablyBytes = NSData(bytes: &enableValue, length: sizeof(UInt8))
//        print("\n")
        for charateristic in service.characteristics! {
//            print(charateristic.UUID)
            let thisCharacteristic = charateristic as CBCharacteristic
            if SensorTag.validDataCharacteristic(thisCharacteristic) {
                // Enable Sensor Notification
                print( "valid char")
//                print(thisCharacteristic)
                
                self.sensorTagPeripheral.setNotifyValue(true, forCharacteristic: thisCharacteristic)
                print("after notify set")
//                print(self.sensorTagPeripheral.services)
            }
            if SensorTag.validConfigCharacteristic(thisCharacteristic) {
                // Enable Sensor
                print("more valid")
//                print(thisCharacteristic)
                self.sensorTagPeripheral.writeValue(enablyBytes, forCharacteristic: thisCharacteristic, type: CBCharacteristicWriteType.WithResponse)
            }
        }
        
    }
    
    
    
    // Get data values when they are updated
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        self.statusLabel.text = "Connected"
        
        // TUTAJ WSTAWIONE:
    
        
 
        if characteristic.UUID == IRTemperatureDataUUID {
            print("=================== 002 \n")
            
//            print("properties.notify: \n")
//            print(characteristic.properties.rawValue)
//            print(characteristic.UUID)
//            print("properties: \n")
//            print(characteristic.properties)
//            print("isNotyfing: \n")
//            print(characteristic.isNotifying)
//            print("Data: \n")
//            print(characteristic.value)
            self.ambientTemperature = SensorTag.getAmbientTemperature(characteristic.value!)
            self.objectTemperature = SensorTag.getObjectTemperature(characteristic.value!, ambientTemperature: self.ambientTemperature)
            self.allSensorValues[0] = self.ambientTemperature
            self.allSensorValues[1] = self.objectTemperature
        }
        else if characteristic.UUID == AccelerometerDataUUID {
            let allValues = SensorTag.getAccelerometerData(characteristic.value!)
            print("=================== 003 \n")
            
//            print("properties.notify: \n")
//            print(characteristic.properties.rawValue)
//            print(characteristic.UUID)
//            print("properties: \n")
//            print(characteristic.properties)
//            print("isNotyfing: \n")
//            print(characteristic.isNotifying)
//            print("Data: \n")
//            print(characteristic.value)
            self.accelerometerX = allValues[0]
            self.accelerometerY = allValues[1]
            self.accelerometerZ = allValues[2]
         
            self.allSensorValues[2] = self.accelerometerX
            self.allSensorValues[3] = self.accelerometerY
            self.allSensorValues[4] = self.accelerometerZ
//            self.gyroscopeX = allValues[3]
//            self.gyroscopeY = allValues[4]
//            self.gyroscopeZ = allValues[5]
//            self.allSensorValues[9] = self.gyroscopeX
//            self.allSensorValues[10] = self.gyroscopeY
//            self.allSensorValues[11] = self.gyroscopeZ
        }
        else if characteristic.UUID == HumidityDataUUID {
            self.relativeHumidity = SensorTag.getRelativeHumidity(characteristic.value!)
            self.allSensorValues[5] = self.relativeHumidity
        }
        else if characteristic.UUID == MagnetometerDataUUID {
            
            let allValues = SensorTag.getMagnetometerData(characteristic.value!)
            self.magnetometerX = allValues[0]
            self.magnetometerY = allValues[1]
            self.magnetometerZ = allValues[2]
            self.allSensorValues[6] = self.magnetometerX
            self.allSensorValues[7] = self.magnetometerY
            self.allSensorValues[8] = self.magnetometerZ
        }
        else if characteristic.UUID == GyroscopeDataUUID {
            let allValues = SensorTag.getGyroscopeData(characteristic.value!)
            self.gyroscopeX = allValues[0]
            self.gyroscopeY = allValues[1]
            self.gyroscopeZ = allValues[2]
            self.allSensorValues[9] = self.gyroscopeX
            self.allSensorValues[10] = self.gyroscopeY
            self.allSensorValues[11] = self.gyroscopeZ
        }
        else if characteristic.UUID == BarometerDataUUID {
            //println("BarometerDataUUID")
        }
        
        self.sensorTagTableView.reloadData()
    }
    
    
    
    
    
    /******* UITableViewDataSource *******/
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allSensorLabels.count
    }
    
    
    /******* UITableViewDelegate *******/
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let thisCell = tableView.dequeueReusableCellWithIdentifier("sensorTagCell") as! SensorTagTableViewCell
        thisCell.sensorNameLabel.text  = allSensorLabels[indexPath.row]
        
        let valueString = NSString(format: "%.2f", allSensorValues[indexPath.row])
        thisCell.sensorValueLabel.text = valueString as String
        
        return thisCell
    }
    
    
    
    
    /******* Helper *******/
     
     // Show alert
    func showAlertWithText (header : String = "Warning", message : String) {
        let alert = UIAlertController(title: header, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        alert.view.tintColor = UIColor.redColor()
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // Set up Table View
    func setupSensorTagTableView () {
        
        self.sensorTagTableView = UITableView()
        self.sensorTagTableView.delegate = self
        self.sensorTagTableView.dataSource = self
        
        
        self.sensorTagTableView.frame = CGRect(x: self.view.bounds.origin.x, y: self.statusLabel.frame.maxY+20, width: self.view.bounds.width, height: self.view.bounds.height)
        
        self.sensorTagTableView.registerClass(SensorTagTableViewCell.self, forCellReuseIdentifier: "sensorTagCell")
        
        self.sensorTagTableView.tableFooterView = UIView() // to hide empty lines after cells
        self.view.addSubview(self.sensorTagTableView)
    }
}

