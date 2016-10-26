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

protocol LiFXSessionDelegate {
    func liFXSession(_ session: LiFXSession, didReceiveMessage message: LiFXMessage, fromAddress address: String)
}

class LiFXSession: Session {
    
    //static let DefaultBroadcastAddress: String = "172.20.223.255"
    static let DefaultBroadcastAddress: String = "192.168.240.255"
    fileprivate static let DefaultDiscoveryInterval = DispatchTimeInterval.seconds(60 * 5)
    
    fileprivate static let UDPPort: UInt16 = 56700
    
    var udpSocket: LiFXSocket
    
    var delegate: LiFXSessionDelegate?
    
    var broadcastAddress: String? {
        didSet {
            if (isConnected()) {
                print("Cannot change broadcast address while connected")
                broadcastAddress = oldValue
            }
        }
    }
    
    fileprivate var discoveryWorkItem: DispatchWorkItem?

    fileprivate var discoveryInterval: DispatchTimeInterval?
    
    init(socket: LiFXSocket) {
        udpSocket = socket
        udpSocket.messageHandler = handleMessage
    }
    
    /**
     Open connection and perform discovery repeatedly according to the given time interval.
     
        - parameter seconds: time interval in second between each discovery request. Passing negative value use the default time interval
     
     Use LiFXSession.start() if you don't want repeated discovery
     
     */
    func start(withDiscoveryInterval seconds: Int) {
        if !isConnected() {
            broadcastAddress = broadcastAddress ?? LiFXSession.DefaultBroadcastAddress
            udpSocket.openConnection()
            discoveryInterval = seconds < 0 ? LiFXSession.DefaultDiscoveryInterval : DispatchTimeInterval.seconds(seconds)
            let workItem = DispatchWorkItem {
                [unowned self] in
                self.discoverDevices()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + self.discoveryInterval!, execute: self.discoveryWorkItem!)
            }
            
            discoveryWorkItem = workItem
            workItem.perform()
        } else {
            print("Explorer already started")
        }
    }
    
    /**
        Open connection and only perform 1 discovery.
     
        Further discovery can be performed by calling LiFXSession.discoverDevices()
     */
    func start() {
        if !isConnected() {
            broadcastAddress = broadcastAddress ?? LiFXSession.DefaultBroadcastAddress
            udpSocket.openConnection()
            discoverDevices()
        } else {
            print("Explorer already started")
        }
    }

    
    func stop() {
        stopDiscovery()
        udpSocket.closeConnection()
    }
    
    fileprivate func stopDiscovery() {
        discoveryWorkItem?.cancel()
        discoveryWorkItem = nil
        discoveryInterval = nil
    }
    
    func isConnected() -> Bool {
        return udpSocket.isConnected()
    }
    
    fileprivate func handleMessage(_ message: LiFXMessage, address: String) {
        print("Handle message: \(message)")
        delegate?.liFXSession(self, didReceiveMessage: message ,fromAddress: address)
    }
    
    func discoverDevices() {
        udpSocket.udpSocket?.sendMessage(LiFXMessage(messageType: LiFXMessage.MessageType.deviceGetService), address: broadcastAddress!)
    }
    
}


