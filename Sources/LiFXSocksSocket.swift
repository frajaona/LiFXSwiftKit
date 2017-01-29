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

class LiFXSocksSocket: LiFXSocket {
    
    var messageHandler: ((LiFXMessage, String) -> ())?
    
    var udpSocket: Socket? {
        return rawSocket
    }
    
    fileprivate var rawSocket: UdpSocksSocket?
    
    func openConnection() {
        let socket = UdpSocksSocket(destPort: LiFXSocksSocket.UdpPort, socketDelegate: self)
        
        rawSocket = socket
        
        if !socket.openConnection() {
            closeConnection()
        } else {
            
        }
    }
    
    func closeConnection() {
        rawSocket?.closeConnection()
        rawSocket = nil
    }
    
    func isConnected() -> Bool {
        return udpSocket != nil && udpSocket!.isConnected()
    }
    
}

extension LiFXSocksSocket: UdpSocksSocketDelegate {
    
    func onConnected(to socket: UdpSocksSocket) {
        Log.debug("socked did connect")
    }
    
    func onReceive(data: NSData, from address: String, by socket: UdpSocksSocket) {
        Log.debug("\nReceive data from address: \(address)")
        //Log.debug(data.description)
        let message = LiFXMessage(fromData: data as Data)
        messageHandler?(message, address)
    }
    
    func onSent(at address: String, by socket: UdpSocksSocket) {
        Log.debug("socked did send data")
    }
}
