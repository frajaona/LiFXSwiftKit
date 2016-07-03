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
    func liFXSession(session: LiFXSession, didReceiveMessage message: LiFXMessage, fromAddress address: String)
}

class LiFXSession: Session {
    
    static let DefaultBroadcastAddress: String = "192.168.240.255"
    
    private static let UDPPort: UInt16 = 56700
    
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
    
    private func openConnection(broadcastAddress: String) {
        let socket = UDPSocket<LiFXMessage>(destPort: LiFXSession.UDPPort, shouldBroadcast: true, socketDelegate: self)
        
        udpSocket = socket
        
        if !socket.openConnection() {
            closeConnection()
        } else {
            socket.sendMessage(LiFXMessage(messageType: LiFXMessage.MessageType.DeviceGetService), address: broadcastAddress)
        }
    }
    
    private func closeConnection() {
        udpSocket?.closeConnection()
        udpSocket = nil
    }
    
    func isConnected() -> Bool {
        return udpSocket != nil
    }
    
    private func handleMessage(message: LiFXMessage, address: String) {
        print("Handle message: \(message)")
        delegate?.liFXSession(self, didReceiveMessage: message ,fromAddress: address)
    }
    
}

extension LiFXSession: GCDAsyncUdpSocketDelegate {
    
    @objc func udpSocket(sock: GCDAsyncUdpSocket!, didSendDataWithTag tag: Int) {
        print("socked did send data with tag \(tag)")
    }
    
    @objc func udpSocket(sock: GCDAsyncUdpSocket!, didNotSendDataWithTag tag: Int, dueToError error: NSError!) {
        print("socked did not send data with tag \(tag)")
    }
    
    @objc func udpSocketDidClose(sock: GCDAsyncUdpSocket!, withError error: NSError!) {
        print("Socket closed: \(error.localizedDescription)")
    }
    
    @objc func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!, withFilterContext filterContext: AnyObject!) {
        print("\nReceive data from isIPv4=\(GCDAsyncUdpSocket.isIPv4Address(address)) address: \(GCDAsyncUdpSocket.hostFromAddress(address))")
        //print(data.description)
        let message = LiFXMessage(fromData: data)
        handleMessage(message, address: GCDAsyncUdpSocket.hostFromAddress(address))
    }
}