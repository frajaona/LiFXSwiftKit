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
