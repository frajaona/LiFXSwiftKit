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

struct UdpCASSocket<T: Message>: Socket {
    
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
