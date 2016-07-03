//
//  RetransmissionBuffer.swift
//  LiFXController
//
//  Created by Fred Rajaona on 22/12/2015.
//  Copyright © 2015 Fred Rajaona. All rights reserved.
//

import Foundation

class RetransmissionBuffer {
    
    private let windowSize = 1
    
    private let timeout = 1000 as Double // in ms
    
    private let address: String
    
    private var lastTransmittedSequenceNumber = 0 as UInt8
    private var lastAcknowledgedSequenceNumber = 0 as UInt8
    
    private var protocolLayer: Socket
    
    private var pendingMessages = [UInt8: LiFXMessage]()
    
    //private var pendingMessage: [LiFXMessage?]
    private var timerBlock: dispatch_block_t?
    
    var windowRoom: Int {
        get {
            return windowSize - Int(lastTransmittedSequenceNumber &- lastAcknowledgedSequenceNumber)
        }
    }
    
    init(socket: Socket, address: String) {
        protocolLayer = socket
        //pendingMessage = [LiFXMessage?](count: windowSize, repeatedValue: nil)
        self.address = address
    }
    
    private func restartAwaitAckTimer() {
        stopAwaitAckTimer()
        let block = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS) {
            [unowned self] in
            self.handleAwaitAckTimeout()
        }
        timerBlock = block
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(timeout * Double(NSEC_PER_MSEC))), dispatch_get_main_queue(), block)
    }
    
    private func stopAwaitAckTimer() {
        if let block = timerBlock {
            dispatch_block_cancel(block)
            timerBlock = nil
        }
    }
    
    func addMessage(message: LiFXMessage) {
        lastTransmittedSequenceNumber = message.getSequenceNumber()
        
        pendingMessages[lastTransmittedSequenceNumber] = message
        
        restartAwaitAckTimer()
    }
    
    func handleReceivedAckNotification(newAckSequenceNumber: UInt8) {
        var index: UInt8 = lastAcknowledgedSequenceNumber
        while index != newAckSequenceNumber {
            pendingMessages[index] = nil
            index = index &+ 1
        }
        lastAcknowledgedSequenceNumber = newAckSequenceNumber
        
        if lastTransmittedSequenceNumber == lastAcknowledgedSequenceNumber {
            stopAwaitAckTimer()
        }
    }
    
    private func handleAwaitAckTimeout() {
        var i: UInt8 = lastAcknowledgedSequenceNumber &+ 1
        while i != lastTransmittedSequenceNumber {
            if let message = pendingMessages[i] {
                protocolLayer.sendMessage(message, address: address)
            }
            i = i &+ 1
        }
        
        restartAwaitAckTimer()
    }
    
}