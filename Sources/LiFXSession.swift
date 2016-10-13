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
import CocoaAsyncSocket

protocol LiFXSessionDelegate {
    func liFXSession(_ session: LiFXSession, didReceiveMessage message: LiFXMessage, fromAddress address: String)
}

class LiFXSession: Session {
    
    static let DefaultBroadcastAddress: String = "192.168.240.255"
    
    fileprivate static let UDPPort: UInt16 = 56700
    
    var udpSocket: UDPSocket<LiFXMessage>?
    
    var delegate: LiFXSessionDelegate?
    
    var broadcastAddress: String? {
        didSet {
            if (isConnected()) {
                print("Cannot change broadcast address while connected")
                broadcastAddress = oldValue
            }
        }
    }
    
    func start() {
        if !isConnected() {
            openConnection(broadcastAddress ?? LiFXSession.DefaultBroadcastAddress)
        } else {
            print("Explorer already started")
        }
    }
    
    func stop() {
        closeConnection()
    }
    
    fileprivate func openConnection(_ broadcastAddress: String) {
        let socket = UDPSocket<LiFXMessage>(destPort: LiFXSession.UDPPort, shouldBroadcast: true, socketDelegate: self)
        
        udpSocket = socket
        
        if !socket.openConnection() {
            closeConnection()
        } else {
            socket.sendMessage(LiFXMessage(messageType: LiFXMessage.MessageType.deviceGetService), address: broadcastAddress)
        }
    }
    
    fileprivate func closeConnection() {
        udpSocket?.closeConnection()
        udpSocket = nil
    }
    
    func isConnected() -> Bool {
        return udpSocket != nil
    }
    
    fileprivate func handleMessage(_ message: LiFXMessage, address: String) {
        print("Handle message: \(message)")
        delegate?.liFXSession(self, didReceiveMessage: message ,fromAddress: address)
    }
    
}

extension LiFXSession: GCDAsyncUdpSocketDelegate {
    
    @objc func udpSocket(_ sock: GCDAsyncUdpSocket!, didSendDataWithTag tag: Int) {
        print("socked did send data with tag \(tag)")
    }
    
    @objc func udpSocket(_ sock: GCDAsyncUdpSocket!, didNotSendDataWithTag tag: Int, dueToError error: Error!) {
        print("socked did not send data with tag \(tag)")
    }
    
    @objc func udpSocketDidClose(_ sock: GCDAsyncUdpSocket!, withError error: Error!) {
        print("Socket closed: \(error.localizedDescription)")
    }
    
    @objc func udpSocket(_ sock: GCDAsyncUdpSocket!, didReceive data: Data!, fromAddress address: Data!, withFilterContext filterContext: Any!) {
        print("\nReceive data from isIPv4=\(GCDAsyncUdpSocket.isIPv4Address(address)) address: \(GCDAsyncUdpSocket.host(fromAddress: address))")
        //print(data.description)
        let message = LiFXMessage(fromData: data)
        handleMessage(message, address: GCDAsyncUdpSocket.host(fromAddress: address))
    }
}
