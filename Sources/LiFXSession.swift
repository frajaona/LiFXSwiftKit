//
//  LiFXExplorer.swift
//  LiFXController
//
//  Created by Fred Rajaona on 14/09/2015.
//  Copyright (c) 2015 Fred Rajaona. All rights reserved.
//

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
