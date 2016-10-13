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

final class CommandSetColor: Command {
    
    var sequenceNumber: UInt8 = 0
    var sourceNumber: UInt32 = 0
    
    fileprivate var hue = 0
    fileprivate var saturation = 0
    fileprivate var brightness = 0
    fileprivate var kelvin = 0
    
    var setHue = false
    var setSaturation = false
    var setBrightness = false
    var setKelvin = false
    
    fileprivate var transmitProtocolHandler: TransmitProtocolHandler!
    
    fileprivate var message: LiFXMessage!
    
    fileprivate var completed = false
    
    func initCommand(_ transmitProtocolHandler: TransmitProtocolHandler) {
        self.transmitProtocolHandler = transmitProtocolHandler
        message = LiFXMessage(messageType: LiFXMessage.MessageType.lightGet, sequenceNumber: sequenceNumber, sourceNumber: sourceNumber,targetAddress: (UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0)), messagePayload: nil)
    }
    
    func setHue(_ hue: Int) -> CommandSetColor {
        setHue = true
        self.hue = hue
        return self
    }
    
    func setSaturation(_ saturation: Int) -> CommandSetColor {
        setSaturation = true
        self.saturation = saturation
        return self
    }
    
    func setBrightness(_ brightness: Int) -> CommandSetColor {
        setBrightness = true
        self.brightness = brightness
        return self
    }
    
    func setKelvin(_ kelvin: Int) -> CommandSetColor {
        setKelvin = true
        self.kelvin = kelvin
        return self
    }
    
    fileprivate func getPayload() -> [UInt8] {
        let data = NSMutableData()
        var byte8 = 0
        data.append(&byte8, length: 1)
        var byte16 = hue.littleEndian
        data.append(&byte16, length: 2)
        
        byte16 = saturation.littleEndian
        data.append(&byte16, length: 2)
        
        byte16 = brightness.littleEndian
        data.append(&byte16, length: 2)
        
        byte16 = kelvin.littleEndian
        data.append(&byte16, length: 2)
        
        var byte32 = 0
        data.append(&byte32, length: 4)
        
        var payload = [UInt8](repeating: 0, count: data.length)
        data.getBytes(&payload, length: data.length)
        return payload
    }
    
    func getMessage() -> LiFXMessage {
        return message
    }
    
    func getProtocolHandler() -> TransmitProtocolHandler {
        return transmitProtocolHandler
    }
    
    func onNewMessage(_ message: LiFXMessage) {
        switch message.messageType {
        case LiFXMessage.MessageType.lightState:
            if message.getSequenceNumber() == sequenceNumber {
                let info = LiFXLightInfo(fromData: message.payload!)
                if !setHue {
                    hue = info.hue
                }
                if !setSaturation {
                    saturation = info.saturation
                }
                if !setBrightness {
                    brightness = info.brightness
                }
                if !setKelvin {
                    kelvin = info.kelvin
                }
                self.message = LiFXMessage(messageType: LiFXMessage.MessageType.lightSetColor, sequenceNumber:  transmitProtocolHandler.getNextTransmitSequenceNumber(), sourceNumber: sourceNumber,targetAddress: (UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0)), messagePayload: getPayload())
                
                execute()
                completed = true
            }
        
        default:
            break
        }
    }
    
    func isComplete() -> Bool {
        return completed
    }
}
