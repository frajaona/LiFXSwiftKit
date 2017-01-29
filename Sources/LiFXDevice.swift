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

public class LiFXDevice {
    
    static let maxPowerLevel = 65535
    static let minPowerLevel = 0

    enum Service: Int {
        case udp = 1
    }
    
    fileprivate let sourceNumber = 12345 as UInt32
    
    fileprivate var generatedSequence: UInt8 = 0
    
    fileprivate let transmitProtocolHandler: TransmitProtocolHandler
    
    fileprivate let commandQueue = Queue<Command>()
    
    fileprivate var currentCommand: Command?
    
    let port: Int
    let service: UInt8
    let address: String
    public var label: String?
    var group: LiFXGroup?
    
    var stateMessage: LiFXMessage!
    
	var powerLevel = 0 {
		didSet {
			powerLevelProperty.value = powerLevel
		}
	}
	    
	public let powerLevelProperty = Property(value: 0)
    
    var hue = 0 {
        didSet {
            hueProperty.value = hue
        }
    }
    public let hueProperty = Property(value: 0)
    
    var saturation = 0 {
        didSet {
            saturationProperty.value = hue
        }
    }
    public let saturationProperty = Property(value: 0)
    
    var brightness = 0 {
        didSet {
            brightnessProperty.value = hue
        }
    }
    public let brightnessProperty = Property(value: 0)
    
    var kelvin = 0 {
        didSet {
            kelvinProperty.value = hue
        }
    }
    public let kelvinProperty = Property(value: 0)
    
    public var uid: String {
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
        transmitProtocolHandler = TransmitProtocolHandler(socket: session.udpSocket.udpSocket!, address: self.address)
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
    
    func setBrightness(_ brightness: Int) {
        let command = CommandSetColor(transmitProtocolHandler: transmitProtocolHandler, sourceNumber: sourceNumber)
        
        _ = command.setBrightness(brightness)
        execute(command)
    }
    
    fileprivate func execute(_ command: Command) {
        if let c = currentCommand , !c.isComplete() {
            commandQueue.enQueue(c)
        } else {
            currentCommand = command
            command.execute()
        }
    }
    
    func onNewMessage(_ message: LiFXMessage) {
        switch message.messageType {
        case LiFXMessage.MessageType.lightStatePower:
            powerLevel = LiFXMessage.getIntValue(fromData: message.payload!)
            
        case LiFXMessage.MessageType.deviceStateGroup:
            let g = LiFXGroup(fromData: message.payload!)
            if g.valid {
                group = g
            }
            
        case LiFXMessage.MessageType.deviceStateLabel:
            label = LiFXMessage.getStringValue(fromData: message.payload!)
            Log.debug("Device Label is \(label)")
            
        case LiFXMessage.MessageType.lightState:
            let info = LiFXLightInfo(fromData: message.payload!)
            label = info.label
            powerLevel = info.power
            hue = info.hue
            saturation = info.saturation
            brightness = info.brightness
            kelvin = info.kelvin
            
        case LiFXMessage.MessageType.ack:
            if sourceNumber == message.getSourceNumber() {
                transmitProtocolHandler.handleReceivedAckNotification(message.getSequenceNumber())
            }
            
        default:
            break
        }
        if let pendingCommand = currentCommand , pendingCommand.sourceNumber == message.getSourceNumber() {
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
