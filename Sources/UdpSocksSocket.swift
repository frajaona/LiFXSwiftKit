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
#if SWIFT_PACKAGE
    import SocksCore
#else
    import socks
#endif

protocol UdpSocksSocketDelegate {
    func onConnected(to socket: UdpSocksSocket)
    func onReceive(data: NSData, from address: String, by socket: UdpSocksSocket)
    func onSent(at address: String, by socket: UdpSocksSocket)
}

class UdpSocksSocket: Socket {
    
    private let port: UInt16
    
    private let socket: UDPInternetSocket?
    
    private let socketQueue: DispatchQueue
    private let readQueue: DispatchQueue
    
    private let delegate: UdpSocksSocketDelegate
    
    private var connected = false
    
    
    init(destPort: UInt16, socketDelegate: UdpSocksSocketDelegate) {
        port = destPort
        delegate = socketDelegate
        socketQueue = DispatchQueue(label: "SocketQueue")
        readQueue = DispatchQueue(label: "SocketReadQueue")
        do {
            socket = try UDPInternetSocket(address: InternetAddress.any(port: port))
        }
        catch let error {
            socket = nil
            print("failed creating socket: \(error)")
        }
        
    }
    
    func openConnection() -> Bool {
        return socketQueue.sync {
            do {
                try socket?.bind()
                connected = true
                startReceivingMessage()
                delegate.onConnected(to: self)
            } catch let error {
                print("Cannot connect to host: \(error)")
                connected = false
            }
            return connected
        }

    }
    
    func closeConnection() {
        socketQueue.sync {
            do {
                try socket?.close()
            } catch let error {
                print("Cannot close socket: \(error)")
            }
        }
        connected = false
    }
    
    func isConnected() -> Bool {
        return socketQueue.sync { connected }
    }
    
    func sendMessage<T: Message>(_ message: T, address: String) {
        let data = message.getData()
        let bytes = data.withUnsafeBytes {
            [UInt8](UnsafeBufferPointer(start: $0, count: data.count))
        }
        socketQueue.async {
            [unowned self] in
            if self.connected {
                do {
                    try self.socket?.sendto(data: bytes, ip: address, port: self.port)
                    DispatchQueue.main.async {
                        [unowned self] in
                        self.delegate.onSent(at: address, by: self)
                    }
                } catch let error {
                    print("failed sending message: \(error)")
                }
            }
        }
        
    }
    
    private func startReceivingMessage() {
        readQueue.async {
            [unowned self] in
            while self.isConnected() {
                do {
                    if let (bytes, sender) = try self.socket?.recvfrom() {
                        var ubytes = bytes
                        let data = NSData(bytes: &ubytes, length: bytes.count)
                        let senderIp = sender.ipString()
                        DispatchQueue.main.async {
                            [unowned self] in
                            self.delegate.onReceive(data: data, from: senderIp, by: self)
                        }
                    }
                } catch let error {
                    print("failed reading bytes: \(error)")
                }
            }
        }
    }
}
