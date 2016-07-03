//
//  CommandSetColor.swift
//  LiFXController
//
//  Created by Fred Rajaona on 27/12/2015.
//  Copyright © 2015 Fred Rajaona. All rights reserved.
//

import Foundation

final class CommandSetColor: Command {
    
    var sequenceNumber: UInt8 = 0
    var sourceNumber: UInt32 = 0
    
    private var hue = 0
    private var saturation = 0
    private var brightness = 0
    private var kelvin = 0
    
    var setHue = false
    var setSaturation = false
    var setBrightness = false
    var setKelvin = false
    
    private var transmitProtocolHandler: TransmitProtocolHandler!
    
    private var message: LiFXMessage!
    
    private var completed = false
    
    func initCommand(transmitProtocolHandler: TransmitProtocolHandler) {
        self.transmitProtocolHandler = transmitProtocolHandler
        message = LiFXMessage(messageType: LiFXMessage.MessageType.LightGet, sequenceNumber: sequenceNumber, sourceNumber: sourceNumber,targetAddress: (UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0)), messagePayload: nil)
    }
    
    func setHue(hue: Int) -> CommandSetColor {
        setHue = true
        self.hue = hue
        return self
    }
    
    func setSaturation(saturation: Int) -> CommandSetColor {
        setSaturation = true
        self.saturation = saturation
        return self
    }
    
    func setBrightness(brightness: Int) -> CommandSetColor {
        setBrightness = true
        self.brightness = brightness
        return self
    }
    
    func setKelvin(kelvin: Int) -> CommandSetColor {
        setKelvin = true
        self.kelvin = kelvin
        return self
    }
    
    private func getPayload() -> [UInt8] {
        let data = NSMutableData()
        var byte8 = 0
        data.appendBytes(&byte8, length: 1)
        var byte16 = hue.littleEndian
        data.appendBytes(&byte16, length: 2)
        
        byte16 = saturation.littleEndian
        data.appendBytes(&byte16, length: 2)
        
        byte16 = brightness.littleEndian
        data.appendBytes(&byte16, length: 2)
        
        byte16 = kelvin.littleEndian
        data.appendBytes(&byte16, length: 2)
        
        var byte32 = 0
        data.appendBytes(&byte32, length: 4)
        
        var payload = [UInt8](count: data.length, repeatedValue: 0)
        data.getBytes(&payload, length: data.length)
        return payload
    }
    
    func getMessage() -> LiFXMessage {
        return message
    }
    
    func getProtocolHandler() -> TransmitProtocolHandler {
        return transmitProtocolHandler
    }
    
    func onNewMessage(message: LiFXMessage) {
        switch message.messageType {
        case LiFXMessage.MessageType.LightState:
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
                self.message = LiFXMessage(messageType: LiFXMessage.MessageType.LightSetColor, sequenceNumber:  transmitProtocolHandler.getNextTransmitSequenceNumber(), sourceNumber: sourceNumber,targetAddress: (UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0)), messagePayload: getPayload())
                
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