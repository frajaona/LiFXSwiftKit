//
//  LiFXUDPSession.swift
//  LiFXController
//
//  Created by Fred Rajaona on 20/09/2015.
//  Copyright © 2015 Fred Rajaona. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

struct UDPSocket<T: Message>: Socket {
    
    fileprivate let delegate: GCDAsyncUdpSocketDelegate
    
    fileprivate let socket: GCDAsyncUdpSocket
    
    fileprivate let port: UInt16
    
    fileprivate let enableBroadcast: Bool
    
    init(destPort: UInt16, shouldBroadcast: Bool, socketDelegate: GCDAsyncUdpSocketDelegate) {
        delegate = socketDelegate
        port = destPort
        enableBroadcast = shouldBroadcast
        socket = GCDAsyncUdpSocket(delegate: delegate, delegateQueue: DispatchQueue.main)
    }
    
    func openConnection() -> Bool {
        
        socket.setIPv6Enabled(false)
        
        do {
            try socket.bind(toPort: port)
        } catch let error as NSError {
            print("Cannot bind socket to port: \(error.description)")
            closeConnection()
            return false
        }
        
        do {
            try socket.beginReceiving()
        } catch let error as NSError {
            print("Cannot begin receiving: \(error.description)")
            closeConnection()
            return false
        }
        
        
        do {
            try socket.enableBroadcast(enableBroadcast)
        } catch let error as NSError {
            print("Cannot enable broadcast on socket: \(error.description)")
            closeConnection()
            return false
        }
        
        return true
    }
    
    func sendMessage<T : Message>(_ message: T, address: String) {
        let strData = message.getData()
        print("\n\nsending(\(strData.count)): \(strData.description)\n\n")
        socket.send(message.getData() as Data!, toHost: address, port: port, withTimeout: -1, tag: 0)
    }
    
    func closeConnection() {
        socket.close()
    }
    
    func isConnected() -> Bool {
        return socket.isConnected()
    }
}
