//
//  LiFXDevice.swift
//  LiFXController
//
//  Created by Fred Rajaona on 19/09/2015.
//  Copyright © 2015 Fred Rajaona. All rights reserved.
//

import Foundation

class LiFXDevice {
    
    static let maxPowerLevel = 65535
    static let minPowerLevel = 0

    enum Service: Int {
        case UDP = 1
    }
    
    private let sourceNumber = 12345 as UInt32
    
    private var generatedSequence: UInt8 = 0
    
    private let transmitProtocolHandler: TransmitProtocolHandler
    
    private let commandQueue = Queue<Command>()
    
    private var currentCommand: Command?
    
    let port: Int
    let service: UInt8
    let address: String
    var label: String?
    var group: LiFXGroup?
    
    var stateMessage: LiFXMessage!
    
    var powerLevel = 0
    
    var hue = 0
    var saturation = 0
    var brightness = 0
    var kelvin = 0
    
    var uid: String {
        return address + ":" + port.description
    }
    
    init(fromMessage message: LiFXMessage, address: String, session: LiFXSession) {
        self.address = address
        stateMessage = message
        var payload = message.payload!
        service = payload[0]
        var value = 0
        for index in 1...4 {
            value += Int(payload[index]) << ((index - 1) * 8)
        }
        port = value
        transmitProtocolHandler = TransmitProtocolHandler(socket: session.udpSocket!, address: self.address)
    }
    
    func switchOn() {
        let command = CommandSwitchOn(transmitProtocolHandler: transmitProtocolHandler, sourceNumber: sourceNumber)
        execute(command)
    }
    
    func switchOff() {
        let command = CommandSwitchOff(transmitProtocolHandler: transmitProtocolHandler, sourceNumber: sourceNumber)
        execute(command)
    }
    
    func toggle() {
        let command = CommandToggle(transmitProtocolHandler: transmitProtocolHandler, sourceNumber: sourceNumber)
        execute(command)
    }
    
    func getPower() {
        let command = CommandGetPower(transmitProtocolHandler: transmitProtocolHandler, sourceNumber: sourceNumber)
        execute(command)
    }
    
    func getInfo() {
        let command = CommandGetLightInfo(transmitProtocolHandler: transmitProtocolHandler, sourceNumber: sourceNumber)
        execute(command)
    }
    
    func getLabel() {
        let command = CommandGetLabel(transmitProtocolHandler: transmitProtocolHandler, sourceNumber: sourceNumber)
        execute(command)
    }
    
    func getGroup() {
        let command = CommandGetGroup(transmitProtocolHandler: transmitProtocolHandler, sourceNumber: sourceNumber)
        execute(command)
    }
    
    func setBrightness(brightness: Int) {
        let command = CommandSetColor(transmitProtocolHandler: transmitProtocolHandler, sourceNumber: sourceNumber)
        
        command.setBrightness(brightness)
        execute(command)
    }
    
    private func execute(command: Command) {
        if let c = currentCommand where !c.isComplete() {
            commandQueue.enQueue(c)
        } else {
            currentCommand = command
            command.execute()
        }
    }
    
    func onNewMessage(message: LiFXMessage) {
        switch message.messageType {
        case LiFXMessage.MessageType.LightStatePower:
            powerLevel = LiFXMessage.getIntValue(fromData: message.payload!)
            
        case LiFXMessage.MessageType.DeviceStateGroup:
            let g = LiFXGroup(fromData: message.payload!)
            if g.valid {
                group = g
            }
            
        case LiFXMessage.MessageType.DeviceStateLabel:
            label = LiFXMessage.getStringValue(fromData: message.payload!)
            print("Device Label is \(label)")
            
        case LiFXMessage.MessageType.LightState:
            let info = LiFXLightInfo(fromData: message.payload!)
            label = info.label
            powerLevel = info.power
            hue = info.hue
            saturation = info.saturation
            brightness = info.brightness
            kelvin = info.kelvin
            
        case LiFXMessage.MessageType.Ack:
            if sourceNumber == message.getSourceNumber() {
                transmitProtocolHandler.handleReceivedAckNotification(message.getSequenceNumber())
            }
            
        default:
            break
        }
        if let pendingCommand = currentCommand where pendingCommand.sourceNumber == message.getSourceNumber() {
            currentCommand?.onNewMessage(message)
        }
        if let command = currentCommand {
            if command.isComplete() {
                handleNextCommand()
            }
        } else {
            handleNextCommand()
        }
    }
    
    func handleNextCommand() {
        if commandQueue.size() > 0 {
            currentCommand = commandQueue.deQueue()
            if currentCommand != nil {
                execute(currentCommand!)
            }
        } else {
            currentCommand = nil
        }
    }
    
}
