/*
 * Copyright (C) 2016 Fred Rajaona
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation

public protocol LiFXDeviceManagerObserver {
    var observerHashValue: String { get }
    func onDeviceListChanged(_ newList: [LiFXDevice])
}

public class LiFXDeviceManager {
    
    public static let sharedInstance = LiFXDeviceManager()
    
    public var devices = [String: LiFXDevice]()

#if os(OSX)
    fileprivate var session = LiFXSession(socket: LiFXSocksSocket())
#else
    fileprivate var session = LiFXSession(socket: LiFXCASSocket())
#endif
    
    public var broadcastAddress: String? {
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
            // Use default discovery interval
            session.start(withDiscoveryInterval: -1)
        }
    }

    public func refreshDeviceList() {
        if session.isConnected() {
            session.discoverDevices()
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
    
    public func getDevicePowers() {
        for (_, device) in devices {
            device.getPower()
        }
    }
    
    public func getPower(_ deviceUid: String) {
        for (_, device) in devices {
            if device.uid == deviceUid {
                device.getPower()
            }
        }
    }
    
    public func getDeviceInfo() {
        for (_, device) in devices {
            device.getInfo()
        }
    }
    
    public func getInfo(_ deviceUid: String) {
        for (_, device) in devices {
            if device.uid == deviceUid {
                device.getInfo()
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
                devices[address]!.getGroup()
                devices[address]!.getInfo()
            }
            
        default:
            if let device = devices[address] {
                device.onNewMessage(message)
            }
            break
            
        }
    }
}
