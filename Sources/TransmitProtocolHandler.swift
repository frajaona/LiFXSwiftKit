//
//  TransmitProtocolHandler.swift
//  LiFXController
//
//  Created by Fred Rajaona on 22/12/2015.
//  Copyright © 2015 Fred Rajaona. All rights reserved.
//

import Foundation

class TransmitProtocolHandler {
    
    private var nextTransmitSequenceNumber = 0 as UInt8
    
    private var nextReceiveSequenceNumber = 0 as UInt8
    
    private var protocolLayer: Socket
    
    private let retransmissionBuffer: RetransmissionBuffer
    
    private let transmitQueue = Queue<LiFXMessage>()
    
    private let address: String
    
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
    
    private func transmitMessage(message: LiFXMessage) {
        retransmissionBuffer.addMessage(message)
        protocolLayer.sendMessage(message, address: address)
    }
    
    func handleTransmitRequest(message: LiFXMessage) {
        if retransmissionBuffer.windowRoom == 0 {
            // No space, window is full. The message waits in the queue
            transmitQueue.enQueue(message)
        } else {
            // If the window is open, transmit packet immediately
            transmitMessage(message)
        }
    }
    
    func handleReceivedAckNotification(ackSequenceNumber: UInt8) {
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