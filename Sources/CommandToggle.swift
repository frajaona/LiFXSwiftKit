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

final class CommandToggle: Command {
    
    var sequenceNumber: UInt8 = 0
    var sourceNumber: UInt32 = 0
    
    fileprivate var transmitProtocolHandler: TransmitProtocolHandler!
    
    fileprivate var completed = false
    
    fileprivate var message: LiFXMessage!
    
    func initCommand(_ transmitProtocolHandler: TransmitProtocolHandler) {
        self.transmitProtocolHandler = transmitProtocolHandler
        message = LiFXMessage(messageType: LiFXMessage.MessageType.lightGetPower, sequenceNumber: sequenceNumber, sourceNumber: sourceNumber,targetAddress: (UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0)), messagePayload: nil)
    }
    
    func getMessage() -> LiFXMessage {
        return message
    }
    
    func onNewMessage(_ message: LiFXMessage) {
        switch message.messageType {
        case LiFXMessage.MessageType.lightStatePower:
            let powerLevel = LiFXMessage.getIntValue(fromData: message.payload!)
            if powerLevel > 0 {
                self.message = LiFXMessage(messageType: LiFXMessage.MessageType.lightSetPower, sequenceNumber:  transmitProtocolHandler.getNextTransmitSequenceNumber(), sourceNumber: sourceNumber,targetAddress: (UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0)), messagePayload: [UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0)])
            } else {
                self.message = LiFXMessage(messageType: LiFXMessage.MessageType.lightSetPower, sequenceNumber:  transmitProtocolHandler.getNextTransmitSequenceNumber(), sourceNumber: sourceNumber, targetAddress: (UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0)), messagePayload: [UInt8(255), UInt8(255), UInt8(0), UInt8(0), UInt8(0), UInt8(0)])
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
