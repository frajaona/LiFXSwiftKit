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

class LiFXCASSocket: NSObject, LiFXSocket {
    
    var messageHandler: ((LiFXMessage, String) -> ())?
    
    var udpSocket: Socket? {
        return rawSocket
    }
    
    fileprivate var rawSocket: UdpCASSocket<LiFXMessage>?
    
    func openConnection() {
        let socket = UdpCASSocket<LiFXMessage>(destPort: LiFXCASSocket.UdpPort, shouldBroadcast: true, socketDelegate: self)
        
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
        return udpSocket != nil
    }
    
}

extension LiFXCASSocket: GCDAsyncUdpSocketDelegate {
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        Log.debug("socked did send data with tag \(tag)")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?) {
        Log.debug("socked did not send data with tag \(tag)")
    }
    
    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
        Log.debug("Socket closed: \(error?.localizedDescription)")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        Log.debug("\nReceive data from isIPv4=\(GCDAsyncUdpSocket.isIPv4Address(address)) address: \(GCDAsyncUdpSocket.host(fromAddress: address))")
        //Log.debug(data.description)
        let message = LiFXMessage(fromData: data)
        messageHandler?(message, GCDAsyncUdpSocket.host(fromAddress: address)!)
    }
}
