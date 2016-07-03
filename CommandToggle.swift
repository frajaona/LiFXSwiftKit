//
//  CommandToggle.swift
//  LiFXController
//
//  Created by Fred Rajaona on 25/12/2015.
//  Copyright © 2015 Fred Rajaona. All rights reserved.
//

import Foundation

final class CommandToggle: Command {
    
    var sequenceNumber: UInt8 = 0
    var sourceNumber: UInt32 = 0
    
    private var transmitProtocolHandler: TransmitProtocolHandler!
    
    private var completed = false
    
    private var message: LiFXMessage!
    
    func initCommand(transmitProtocolHandler: TransmitProtocolHandler) {
        self.transmitProtocolHandler = transmitProtocolHandler
        message = LiFXMessage(messageType: LiFXMessage.MessageType.LightGetPower, sequenceNumber: sequenceNumber, sourceNumber: sourceNumber,targetAddress: (UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0)), messagePayload: nil)
    }
    
    func getMessage() -> LiFXMessage {
        return message
    }
    
    func onNewMessage(message: LiFXMessage) {
        switch message.messageType {
        case LiFXMessage.MessageType.LightStatePower:
            let powerLevel = LiFXMessage.getIntValue(fromData: message.payload!)
            if powerLevel > 0 {
                self.message = LiFXMessage(messageType: LiFXMessage.MessageType.LightSetPower, sequenceNumber:  transmitProtocolHandler.getNextTransmitSequenceNumber(), sourceNumber: sourceNumber,targetAddress: (UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0)), messagePayload: [UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0)])
            } else {
                self.message = LiFXMessage(messageType: LiFXMessage.MessageType.LightSetPower, sequenceNumber:  transmitProtocolHandler.getNextTransmitSequenceNumber(), sourceNumber: sourceNumber, targetAddress: (UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0)), messagePayload: [UInt8(255), UInt8(255), UInt8(0), UInt8(0), UInt8(0), UInt8(0)])
            }
            execute()
            completed = true
            
        default:
            break
        }
    }
    
    func isComplete() -> Bool {
        return completed
    }
    
    func getProtocolHandler() -> TransmitProtocolHandler {
        return transmitProtocolHandler
    }
    
}