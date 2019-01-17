//
//  Created by Sergei E. on 12/11/18.
//  (c) 2018 Ambrosus. All rights reserved.
//  

import Foundation
import CoreBluetooth
import GRDB

@objc class AMIBLECentral: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @objc static let sharedInstance = AMIBLECentral()
    
    static let ambServiceUUID  = CBUUID.init(string: "9eb70001-8c04-4c98-ae44-2ca32bfa549a")
    static let ambInUUID = CBUUID.init(string: "9eb70003-8c04-4c98-ae44-2ca32bfa549a")
    static let ambOutUUID    = CBUUID.init(string: "9eb70002-8c04-4c98-ae44-2ca32bfa549a")
    static let batteryServiceUUID    = CBUUID.init(string: "0x180F")
    static let batteryCharacteristicUUID    = CBUUID.init(string: "0x2A19")
    
    var entities:[UUID: AMIDeviceDataUpdater] = [:]
    
    var rateLimitingTable = [String: Double]()
    
    var dbQueue : DatabaseQueue? = {
        return AMIDBStarter.sharedInstance.dbQueue
    } ()
    
    private var centralManager: CBCentralManager
    private let dataDispatchQueue: DispatchQueue
    private let scanOptions:[String : Any] = [CBCentralManagerScanOptionAllowDuplicatesKey: NSNumber(value: true)]
    
    override init() {
        self.dataDispatchQueue = DispatchQueue(label: "BLEDQueue")
        self.centralManager = CBCentralManager(delegate: nil, queue: self.dataDispatchQueue, options: scanOptions)
        super.init()
        self.centralManager.delegate = self
    }
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            entities = [:]
            central.scanForPeripherals(withServices: nil, options: self.scanOptions)
        default:
            debugPrint("Central manager state", central.state)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if AMIBLEHelper.isPeripheralAMBL1(peripheral) {
            NSLog("XX");
            if AMIBLEHelper.isPeripheralDisconnected(peripheral) {
                if let _ = entities[peripheral.identifier] {
                    return
                }

                central.cancelPeripheralConnection(peripheral)
                let updater = AMIDeviceDataUpdater.init(uuid: peripheral.identifier)
                updater.peripheral = peripheral
                updater.state = .st_discovered
                updater.record.uuid = peripheral.identifier.uuidString
                updater.record.broadcastedName = peripheral.name!
                updater.record.rssi = RSSI.doubleValue
                updater.record.addedTS = CACurrentMediaTime()
                updater.record.lastSeenTS = updater.record.addedTS
                updater.record.active = true
                
                if let components = peripheral.name?.components(separatedBy: ":") {
                    if let baseName = components.first {
                        updater.record.baseName = baseName
                    }
                    else {
                        updater.record.baseName = updater.record.broadcastedName
                    }

                    if let bytesAvailable = Int(components.last!) {
                        updater.bytesAvailable = bytesAvailable
                    }
                }
                
                if (updater.step(central, peripheral, .ev_connect, .empty)) {
                    entities[peripheral.identifier] = updater
                }
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if let updater = entities[peripheral.identifier] {
            peripheral.delegate = self
            _ = updater.step(central, peripheral, .ev_discoverServices, .empty)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let updater = entities[peripheral.identifier] {
            if let services = peripheral.services {
                _ = updater.step(centralManager, peripheral, .ev_discoverCharacteristics, .svcs(services))
                return
            }
            
            _ = updater.step(centralManager, peripheral, .ev_disconnect, .empty)
            entities[peripheral.identifier] = nil
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let updater = entities[peripheral.identifier] {
            if let characteristics = service.characteristics {
                if (updater.step(centralManager, peripheral, .ev_write, .chs(characteristics))) {
                    if (updater.step(centralManager, peripheral, .ev_setNotify, .chs(characteristics))) {
                        return
                    }
                }
            }
            
            _ = updater.step(centralManager, peripheral, .ev_disconnect, .empty)
            entities[peripheral.identifier] = nil
        }
    }
    
    private func hideUnreachableDevices() {
        
        
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let updater = entities[peripheral.identifier] {
            if let value = characteristic.value {
                if (updater.step(centralManager, peripheral, .ev_dataArrived, .data(value))) {
                    return
                }
            }
            
            let deadlineTime = DispatchTime.now() + 0.01
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) { [unowned self] in
                _ = updater.step(self.centralManager, peripheral, .ev_disconnect, .empty)
                self.entities[peripheral.identifier] = nil
                updater.propagateChanges()
            }
        }
    }
    
    public func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        debugPrint("DELE01")
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        debugPrint("DELE02")
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        debugPrint("DELE03")
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
        debugPrint("DELE05")
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        debugPrint("DELE08")
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        debugPrint("DELE09")
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        debugPrint("DELE10")
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        debugPrint("DELE11")
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        debugPrint("DELE12")
    }
    
    public func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        debugPrint("DELE13")
    }
}





// !! fragment from didDiscover: !!
//        if let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data {
//            if let ruuviFrame = AMIRuuviFrame.init(dataFrame: manufacturerData) {
//                self.updateRuuviFrame(ruuviFrame, rssi: RSSI, uuid: peripheral.identifier.uuidString, mock:false)
//            }
//        }
//        else if let peripheralName = peripheral.name {
//            if let dataInName = Data.init(base64Encoded: peripheralName) {
//                if let ruuviFrame = AMIRuuviFrame.init(dataFrame: dataInName) {
//                    self.updateRuuviFrame(ruuviFrame, rssi: RSSI, uuid: peripheral.identifier.uuidString, mock:true)
//                }
//            }
//        }




//    private func updateRuuviFrame(_ frame:AMIRuuviFrame, rssi: NSNumber, uuid: String, mock:Bool) {
//        if self.shouldUUIDBeRateLimited(uuid) {
//            return
//        }
//
//        debugPrint("discovered ", uuid, frame.humidity, frame.temperature, frame.pressure, rssi)
//
//        let lastTSToShow = CACurrentMediaTime() - 5.0
//        let oldKeys = rateLimitingTable.filter({$0.value < lastTSToShow}).keys
//        oldKeys.forEach({rateLimitingTable.removeValue(forKey: $0)})
//
//        if let dbq = self.dbQueue {
//            try! dbq.write { db in
//                let name = (mock ? "Mock AMB " : "Ruuvi ") + String(uuid.suffix(4))
//                let macaddr = uuid
//                var device = AMIDeviceRecord(id: nil,
//                                             deviceModelId: 1,
//                                             autogeneratedName:name,
//                                             name: name,
//                                             active:true,
//                                             macaddr:macaddr,
//                                             charge: frame.voltage,
//                                             rssi: rssi.doubleValue,
//                                             temp: frame.temperature,
//                                             pressure: frame.pressure,
//                                             humidity: frame.humidity,
//                                             tsAdded: CACurrentMediaTime(),
//                                             tsLastSeen: CACurrentMediaTime(),
//                                             unreachableFlag: false);
//
//                if let row = try! AMIDeviceRecord.fetchOne(db, "SELECT * FROM device WHERE macaddr = ?", arguments: [macaddr]) {
//                    device.id = row.id
//                    device.tsAdded = row.tsAdded
//                    try device.update(db)
//                }
//                else {
//                    try device.insert(db)
//                }
//
//                if (oldKeys.count > 0) {
//                    try db.execute("UPDATE device SET unreachableFlag = 1 WHERE macaddr in (?)", arguments: [oldKeys.joined(separator: ",")])
//                }
//            }
//        }
//    }
//
//    private func shouldUUIDBeRateLimited(_ uuid: String) -> Bool {
//        if (uuid.count == 0) {
//            return true
//        }
//
//        var result:Bool = true
//        let currentTS = CACurrentMediaTime()
//        if let ts = rateLimitingTable[uuid] {
//            if currentTS - ts > 0.2 {
//                result = false
//            }
//        }
//        else {
//            result = false
//        }
//
//        if (result == false) {
//            rateLimitingTable[uuid] = currentTS
//        }
//
//        return result
//    }