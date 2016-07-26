//
//  SensorTag.swift
//  SwiftSensorTag
//
//  Created by Anas Imtiaz on 13/11/2015.
//  Copyright © 2015 Anas Imtiaz. All rights reserved.
//

import Foundation
import CoreBluetooth


let deviceName = "SnowcookieTag"

// Service UUIDs
let IRTemperatureServiceUUID = CBUUID(string: "AF760000-6511-77A5-A640-E9511C08F83A")
let AccelerometerServiceUUID = CBUUID(string: "AF760000-6511-77A5-A640-E9511C08F83A")
let HumidityServiceUUID      = CBUUID(string: "AF760000-6511-77A5-A640-E9511C08F83A")
let MagnetometerServiceUUID  = CBUUID(string: "AF760000-6511-77A5-A640-E9511C08F83A")
let BarometerServiceUUID     = CBUUID(string: "AF760000-6511-77A5-A640-E9511C08F83A")
let GyroscopeServiceUUID     = CBUUID(string: "AF760000-6511-77A5-A640-E9511C08F83A")

// Characteristic UUIDs
let IRTemperatureDataUUID   = CBUUID(string: "AF760002-6511-77A5-A640-E9511C08F83A")
let IRTemperatureConfigUUID = CBUUID(string: "AF760002-6511-77A5-A640-E9511C08F83A")
let AccelerometerDataUUID   = CBUUID(string: "AF760001-6511-77A5-A640-E9511C08F83A")
let AccelerometerConfigUUID = CBUUID(string: "AF760001-6511-77A5-A640-E9511C08F83A")
let HumidityDataUUID        = CBUUID(string: "5DC90001-8F79-462B-98D7-C1F8C766FA47")
let HumidityConfigUUID      = CBUUID(string: "5DC90001-8F79-462B-98D7-C1F8C766FA47")
let MagnetometerDataUUID    = CBUUID(string: "AF760003-6511-77A5-A640-E9511C08F83A")
let MagnetometerConfigUUID  = CBUUID(string: "AF760003-6511-77A5-A640-E9511C08F83A")
let BarometerDataUUID       = CBUUID(string: "F000AA41-0451-4000-B000-000000000000")
let BarometerConfigUUID     = CBUUID(string: "F000AA42-0451-4000-B000-000000000000")
let GyroscopeDataUUID       = CBUUID(string: "AF760001-6511-77A5-A640-E9511C08F83A")
let GyroscopeConfigUUID     = CBUUID(string: "F000AA52-0451-4000-B000-000000000000")



class SensorTag {
    
    // Check name of device from advertisement data
    class func sensorTagFound (advertisementData: [NSObject : AnyObject]!) -> Bool {
        let nameOfDeviceFound = (advertisementData as NSDictionary).objectForKey(CBAdvertisementDataLocalNameKey) as? NSString
        return (nameOfDeviceFound == deviceName)
    }
    
    
    // Check if the service has a valid UUID
    class func validService (service : CBService) -> Bool {
        if service.UUID == IRTemperatureServiceUUID || service.UUID == AccelerometerServiceUUID ||
            service.UUID == HumidityServiceUUID || service.UUID == MagnetometerServiceUUID ||
            service.UUID == BarometerServiceUUID || service.UUID == GyroscopeServiceUUID {
                return true
        }
        else {
            return false
        }
    }
    
    
    // Check if the characteristic has a valid data UUID
    class func validDataCharacteristic (characteristic : CBCharacteristic) -> Bool {
        if characteristic.UUID == IRTemperatureDataUUID || characteristic.UUID == AccelerometerDataUUID ||
            characteristic.UUID == HumidityDataUUID || characteristic.UUID == MagnetometerDataUUID ||
            characteristic.UUID == BarometerDataUUID || characteristic.UUID == GyroscopeDataUUID {
                return true
        }
        else {
            return false
        }
    }
    
    
    // Check if the characteristic has a valid config UUID
    class func validConfigCharacteristic (characteristic : CBCharacteristic) -> Bool {
        if characteristic.UUID == IRTemperatureConfigUUID || characteristic.UUID == AccelerometerConfigUUID ||
            characteristic.UUID == HumidityConfigUUID || characteristic.UUID == MagnetometerConfigUUID ||
            characteristic.UUID == BarometerConfigUUID || characteristic.UUID == GyroscopeConfigUUID {
                return true
        }
        else {
            return false
        }
    }
    
    
    // Get labels of all sensors
    class func getSensorLabels () -> [String] {
        let sensorLabels : [String] = [
            "Ambient Temperature",
            "Object Temperature",
            "Accelerometer X",
            "Accelerometer Y",
            "Accelerometer Z",
            "Relative Humidity",
            "Magnetometer X",
            "Magnetometer Y",
            "Magnetometer Z",
            "Gyroscope X",
            "Gyroscope Y",
            "Gyroscope Z"
        ]
        return sensorLabels
    }
    
    
    
    // Process the values from sensor
    
    
    // Convert NSData to array of bytes
    class func dataToSignedBytes16(value : NSData) -> [Int16] {
        let count = value.length
        var array = [Int16](count: count, repeatedValue: 0)
        value.getBytes(&array, length:count * sizeof(Int16))
        return array
    }
    
    class func dataToUnsignedBytes16(value : NSData) -> [UInt16] {
        let count = value.length
        var array = [UInt16](count: count, repeatedValue: 0)
        value.getBytes(&array, length:count * sizeof(UInt16))
        return array
    }
    
    class func dataToSignedBytes8(value : NSData) -> [Int8] {
        let count = value.length
        var array = [Int8](count: count, repeatedValue: 0)
        value.getBytes(&array, length:count * sizeof(Int8))
        return array
    }
    
    // Get ambient temperature value
    class func getAmbientTemperature(value : NSData) -> Double {
        let dataFromSensor = dataToSignedBytes16(value)
        let ambientTemperature = Double(dataFromSensor[1])/128
        return ambientTemperature
    }
    
    // Get object temperature value
    class func getObjectTemperature(value : NSData, ambientTemperature : Double) -> Double {
        let dataFromSensor = dataToSignedBytes16(value)
        let Vobj2 = Double(dataFromSensor[0]) * 0.00000015625
        
        let Tdie2 = ambientTemperature + 273.15
        let Tref  = 298.15
        
        let S0 = 6.4e-14
        let a1 = 1.75E-3
        let a2 = -1.678E-5
        let b0 = -2.94E-5
        let b1 = -5.7E-7
        let b2 = 4.63E-9
        let c2 = 13.4
        
        let S = S0*(1+a1*(Tdie2 - Tref)+a2*pow((Tdie2 - Tref),2))
        let Vos = b0 + b1*(Tdie2 - Tref) + b2*pow((Tdie2 - Tref),2)
        let fObj = (Vobj2 - Vos) + c2*pow((Vobj2 - Vos),2)
        let tObj = pow(pow(Tdie2,4) + (fObj/S),0.25)
        
        let objectTemperature = (tObj - 273.15)
        
        return objectTemperature
    }
    
    class func twosComplement(num:Int16) -> String {
        var numm:UInt16 = 0
        if num < 0 {
            let a = Int(UInt16.max) + Int(num) + 1
            numm = UInt16(a)
        }
        else { return String(num, radix:2) }
        return String(numm, radix:2)
    }
    
    // Get Accelerometer values
    class func getAccelerometerData(value: NSData) -> [Double] {
        
        let dataFromSensor = dataToSignedBytes8(value)
        print(dataFromSensor)
        let bytes:[Int8] = [dataFromSensor[0], dataFromSensor[1]]
        
        let u16 = UnsafePointer<Int16>(bytes).memory
        let ansas = unsafeBitCast(u16, Int16.self)
        print(twosComplement(u16))
        
        print("u16")
        print(u16)
        print("")
        print(Double(u16))
        let xVal = Double(dataFromSensor[0]) / 64
        let yVal = Double(dataFromSensor[1]) / 64
        let zVal = Double(dataFromSensor[2]) / 64 * -1
        return [xVal, yVal, zVal]
    }
    
    // Get Relative Humidity
    class func getRelativeHumidity(value: NSData) -> Double {
        let dataFromSensor = dataToUnsignedBytes16(value)
        let humidity = -6 + 125/65536 * Double(dataFromSensor[1])
        return humidity
    }
    
    // Get magnetometer values
    class func getMagnetometerData(value: NSData) -> [Double] {
        let dataFromSensor = dataToSignedBytes16(value)
        let xVal = Double(dataFromSensor[0]) * 2000 / 65536 * -1
        let yVal = Double(dataFromSensor[1]) * 2000 / 65536 * -1
        let zVal = Double(dataFromSensor[2]) * 2000 / 65536
        return [xVal, yVal, zVal]
    }
    
    // Get gyroscope values
    class func getGyroscopeData(value: NSData) -> [Double] {
        let dataFromSensor = dataToSignedBytes16(value)
        let yVal = Double(dataFromSensor[0]) * 500 / 65536 * -1
        let xVal = Double(dataFromSensor[1]) * 500 / 65536
        let zVal = Double(dataFromSensor[2]) * 500 / 65536
        return [xVal, yVal, zVal]
    }
}
