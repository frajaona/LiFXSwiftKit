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

class TransmitProtocolHandler {
    
    fileprivate var nextTransmitSequenceNumber = 0 as UInt8
    
    fileprivate var nextReceiveSequenceNumber = 0 as UInt8
    
    fileprivate var protocolLayer: Socket
    
    fileprivate let retransmissionBuffer: RetransmissionBuffer
    
    fileprivate let transmitQueue = Queue<LiFXMessage>()
    
    fileprivate let address: String
    
    init(socket: Socket, address: String) {
        protocolLayer = socket
        retransmissionBuffer = RetransmissionBuffer(socket: socket, address: address)
        self.address = address
    }
    
    func getNextTransmitSequenceNumber() -> UInt8 {
        let sequenceNumber = nextTransmitSequenceNumber
        nextTransmitSequenceNumber = nextTransmitSequenceNumber &+ 1
        return sequenceNumber
    }
    
    fileprivate func transmitMessage(_ message: LiFXMessage) {
        retransmissionBuffer.addMessage(message)
        protocolLayer.sendMessage(message, address: address)
    }
    
    func handleTransmitRequest(_ message: LiFXMessage) {
        if retransmissionBuffer.windowRoom == 0 {
            // No space, window is full. The message waits in the queue
            transmitQueue.enQueue(message)
        } else {
            // If the window is open, transmit packet immediately
            transmitMessage(message)
        }
    }
    
    func handleReceivedAckNotification(_ ackSequenceNumber: UInt8) {
        retransmissionBuffer.handleReceivedAckNotification(ackSequenceNumber)
        
        let windowRoom = retransmissionBuffer.windowRoom
        for _ in 0 ..< windowRoom {
            if transmitQueue.size() <= 0 {
                break
            }
            if let message = transmitQueue.deQueue() {
                transmitMessage(message)
            }
        }
    }
    
}
