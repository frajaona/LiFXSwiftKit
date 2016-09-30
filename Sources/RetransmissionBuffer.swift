//
//  RetransmissionBuffer.swift
//  LiFXController
//
//  Created by Fred Rajaona on 22/12/2015.
//  Copyright © 2015 Fred Rajaona. All rights reserved.
//

import Foundation

class RetransmissionBuffer {
    
    fileprivate let windowSize = 1
    
    fileprivate let timeout = 1000 as Double // in ms
    
    fileprivate let address: String
    
    fileprivate var lastTransmittedSequenceNumber = 0 as UInt8
    fileprivate var lastAcknowledgedSequenceNumber = 0 as UInt8
    
    fileprivate var protocolLayer: Socket
    
    fileprivate var pendingMessages = [UInt8: LiFXMessage]()
    
    //private var pendingMessage: [LiFXMessage?]
    //fileprivate var timerBlock: (()->())?
    fileprivate var timerWorkItem: DispatchWorkItem?
    
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
    
    fileprivate func restartAwaitAckTimer() {
        stopAwaitAckTimer()
        let workItem = DispatchWorkItem {
            [unowned self] in
            self.handleAwaitAckTimeout()
        }
        timerWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(timeout * Double(NSEC_PER_MSEC))) / Double(NSEC_PER_SEC), execute: workItem)
    }
    
    fileprivate func stopAwaitAckTimer() {
        if let workItem = timerWorkItem {
            workItem.cancel()
            timerWorkItem = nil
        }
    }
    
    func addMessage(_ message: LiFXMessage) {
        lastTransmittedSequenceNumber = message.getSequenceNumber()
        
        pendingMessages[lastTransmittedSequenceNumber] = message
        
        restartAwaitAckTimer()
    }
    
    func handleReceivedAckNotification(_ newAckSequenceNumber: UInt8) {
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
    
    fileprivate func handleAwaitAckTimeout() {
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
