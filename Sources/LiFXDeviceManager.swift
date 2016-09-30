//
//  LiFXDeviceManager.swift
//  LiFXController
//
//  Created by Fred Rajaona on 19/09/2015.
//  Copyright © 2015 Fred Rajaona. All rights reserved.
//

import Foundation

public protocol LiFXDeviceManagerObserver {
    var observerHashValue: String { get }
    func onDeviceListChanged(_ newList: [LiFXDevice])
}

public class LiFXDeviceManager {
    
    public static let sharedInstance = LiFXDeviceManager()
    
    public var devices = [String: LiFXDevice]()
    
    fileprivate var session = LiFXSession()
    
    var broadcastAddress: String? {
        get {
            return session.broadcastAddress ?? LiFXSession.DefaultBroadcastAddress
        }
        set {
            session.broadcastAddress = newValue
        }
    }
    
    fileprivate var deviceListObservable = [String: LiFXDeviceManagerObserver]()
    
    init() {
        session.delegate = self
    }
    
    public func registerDeviceListObserver(_ observer: LiFXDeviceManagerObserver) {
        if deviceListObservable[observer.observerHashValue] == nil {
            deviceListObservable[observer.observerHashValue] = observer
        }
    }
    
    public func unregisterDeviceListObserver(_ observer: LiFXDeviceManagerObserver) {
        deviceListObservable[observer.observerHashValue] = nil
    }
    
    public func loadDevices() {
        if session.isConnected() {
            notifyDeviceListObservers()
        } else {
            session.start()
        }
    }
    
    public func switchOnDevices() {
        for (_, device) in devices {
            device.switchOn()
        }
    }
    
    public func switchOffDevices() {
        for (_, device) in devices {
            device.switchOff()
        }
    }
    
    public func switchOn(_ deviceUid: String) {
        for (_, device) in devices {
            if device.uid == deviceUid {
                device.switchOn()
            }
        }
    }
    
    public func switchOff(_ deviceUid: String) {
        for (_, device) in devices {
            if device.uid == deviceUid {
                device.switchOff()
            }
        }
    }
    
    public func switchOnGroup(_ group: String) {
        for (_, device) in devices {
            if let deviceGroup = device.group , deviceGroup.label == group {
                device.switchOn()
            }
        }
    }
    
    public func switchOffGroup(_ group: String) {
        for (_, device) in devices {
            if let deviceGroup = device.group , deviceGroup.label == group {
                device.switchOff()
            }
        }
    }
    
    public func toggle(_ deviceUid: String) {
        for (_, device) in devices {
            if device.uid == deviceUid {
                device.toggle()
            }
        }
    }
    
    public func toggleDevices() {
        for (_, device) in devices {
            device.toggle()
        }
    }
    
    public func toggleGroup(_ group: String) {
        for (_, device) in devices {
            if let deviceGroup = device.group , deviceGroup.label == group {
                device.toggle()
            }
        }
    }
    
    func getDevicePowers() {
        for (_, device) in devices {
            device.getPower()
        }
    }
    
    func getPower(_ deviceUid: String) {
        for (_, device) in devices {
            if device.uid == deviceUid {
                device.getPower()
            }
        }
    }
    
    public func setBrightness(_ brightness: Int) {
        for (_, device) in devices {
            device.setBrightness(brightness)
        }
    }
    
    public func setBrightness(_ deviceUid: String, brightness: Int) {
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
    func liFXSession(_ session: LiFXSession, didReceiveMessage message: LiFXMessage, fromAddress address: String) {
        switch message.messageType {
        case LiFXMessage.MessageType.deviceStateService:
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
