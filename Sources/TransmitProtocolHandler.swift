//
//  TransmitProtocolHandler.swift
//  LiFXController
//
//  Created by Fred Rajaona on 22/12/2015.
//  Copyright © 2015 Fred Rajaona. All rights reserved.
//

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
