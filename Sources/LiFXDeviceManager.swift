//
//  LiFXDeviceManager.swift
//  LiFXController
//
//  Created by Fred Rajaona on 19/09/2015.
//  Copyright © 2015 Fred Rajaona. All rights reserved.
//

import Foundation

protocol LiFXDeviceManagerObserver {
    var observerHashValue: String { get }
    func onDeviceListChanged(newList: [LiFXDevice])
}

class LiFXDeviceManager {
    
    static let sharedInstance = LiFXDeviceManager()
    
    var devices = [String: LiFXDevice]()
    
    private var session = LiFXSession()
    
    var broadcastAddress: String? {
        get {
            return session.broadcastAddress ?? LiFXSession.DefaultBroadcastAddress
        }
        set {
            session.broadcastAddress = newValue
        }
    }
    
    private var deviceListObservable = [String: LiFXDeviceManagerObserver]()
    
    init() {
        session.delegate = self
    }
    
    func registerDeviceListObserver(observer: LiFXDeviceManagerObserver) {
        if deviceListObservable[observer.observerHashValue] == nil {
            deviceListObservable[observer.observerHashValue] = observer
        }
    }
    
    func unregisterDeviceListObserver(observer: LiFXDeviceManagerObserver) {
        deviceListObservable[observer.observerHashValue] = nil
    }
    
    func loadDevices() {
        if session.isConnected() {
            notifyDeviceListObservers()
        } else {
            session.start()
        }
    }
    
    func switchOnDevices() {
        for (_, device) in devices {
            device.switchOn()
        }
    }
    
    func switchOffDevices() {
        for (_, device) in devices {
            device.switchOff()
        }
    }
    
    func switchOn(deviceUid: String) {
        for (_, device) in devices {
            if device.uid == deviceUid {
                device.switchOn()
            }
        }
    }
    
    func switchOff(deviceUid: String) {
        for (_, device) in devices {
            if device.uid == deviceUid {
                device.switchOff()
            }
        }
    }
    
    func switchOnGroup(group: String) {
        for (_, device) in devices {
            if let deviceGroup = device.group where deviceGroup.label == group {
                device.switchOn()
            }
        }
    }
    
    func switchOffGroup(group: String) {
        for (_, device) in devices {
            if let deviceGroup = device.group where deviceGroup.label == group {
                device.switchOff()
            }
        }
    }
    
    func toggle(deviceUid: String) {
        for (_, device) in devices {
            if device.uid == deviceUid {
                device.toggle()
            }
        }
    }
    
    func toggleDevices() {
        for (_, device) in devices {
            device.toggle()
        }
    }
    
    func toggleGroup(group: String) {
        for (_, device) in devices {
            if let deviceGroup = device.group where deviceGroup.label == group {
                device.toggle()
            }
        }
    }
    
    func getDevicePowers() {
        for (_, device) in devices {
            device.getPower()
        }
    }
    
    func getPower(deviceUid: String) {
        for (_, device) in devices {
            if device.uid == deviceUid {
                device.getPower()
            }
        }
    }
    
    func setBrightness(brightness: Int) {
        for (_, device) in devices {
            device.setBrightness(brightness)
        }
    }
    
    func setBrightness(deviceUid: String, brightness: Int) {
        for (_, device) in devices {
            if device.uid == deviceUid {
                device.setBrightness(brightness)
            }
        }
    }
    
    func cancelDeviceLoading() {
        session.stop()
    }
    
    func notifyDeviceListObservers() {
        var newList = [LiFXDevice]()
        for (_, device) in devices {
            newList.append(device)
        }
        for (_, observer) in deviceListObservable {
            observer.onDeviceListChanged(newList)
        }
    }
    
}


extension LiFXDeviceManager: LiFXSessionDelegate {
    func liFXSession(session: LiFXSession, didReceiveMessage message: LiFXMessage, fromAddress address: String) {
        switch message.messageType {
        case LiFXMessage.MessageType.DeviceStateService:
            if devices[address] == nil {
                devices[address] = LiFXDevice(fromMessage: message, address: address, session: session)
                print("Found new device with IP address: \(address)")
                notifyDeviceListObservers()
                devices[address]?.getGroup()
                devices[address]?.getInfo()
            }
            
        default:
            if let device = devices[address] {
                device.onNewMessage(message)
            }
            break
            
        }
    }
}
