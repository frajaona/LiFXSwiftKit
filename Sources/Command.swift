//
//  Command.swift
//  LiFXController
//
//  Created by Fred Rajaona on 24/12/2015.
//  Copyright © 2015 Fred Rajaona. All rights reserved.
//

import Foundation

protocol Command {
    var sequenceNumber: UInt8 {get set}
    var sourceNumber: UInt32 {get set}
    
    init()
    
    func getMessage() -> LiFXMessage
    func getProtocolHandler() -> TransmitProtocolHandler
    func onNewMessage(_ message: LiFXMessage)
    func isComplete() -> Bool
    func initCommand(_ transmitProtocolHandler: TransmitProtocolHandler)
    
}

extension Command {
    
    init(transmitProtocolHandler: TransmitProtocolHandler, sourceNumber: UInt32) {
        self.init()
        self.sequenceNumber = transmitProtocolHandler.getNextTransmitSequenceNumber()
        self.sourceNumber = sourceNumber
        self.initCommand(transmitProtocolHandler)
    }
    
    func isComplete() -> Bool {
        return true
    }
    
    func onNewMessage(_ message: LiFXMessage) {
        
    }
    
    
    func execute() {
        getProtocolHandler().handleTransmitRequest(getMessage())
    }
    
}
