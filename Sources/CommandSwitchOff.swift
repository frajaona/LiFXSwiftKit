//
//  CommandSwitchOff.swift
//  LiFXController
//
//  Created by Fred Rajaona on 25/12/2015.
//  Copyright © 2015 Fred Rajaona. All rights reserved.
//

import Foundation

final class CommandSwitchOff: Command {
    
    var sequenceNumber: UInt8 = 0
    var sourceNumber: UInt32 = 0
    
    fileprivate var transmitProtocolHandler: TransmitProtocolHandler!
    
    fileprivate var message: LiFXMessage!
    
    func initCommand(_ transmitProtocolHandler: TransmitProtocolHandler) {
        self.transmitProtocolHandler = transmitProtocolHandler
        message = LiFXMessage(messageType: LiFXMessage.MessageType.lightSetPower, sequenceNumber: sequenceNumber, sourceNumber: sourceNumber, targetAddress: (UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0)), messagePayload: [UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0)])
    }
    
    func getMessage() -> LiFXMessage {
        return message
    }
    
    func getProtocolHandler() -> TransmitProtocolHandler {
        return transmitProtocolHandler
    }
}
