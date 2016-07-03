//
//  LiFXMessage.swift
//  LiFXController
//
//  Created by Fred Rajaona on 14/09/2015.
//  Copyright (c) 2015 Fred Rajaona. All rights reserved.
//

import Foundation


struct LiFXMessage: Message {
    
    private static let headerSize = 36 // bytes
    
    private static let noSource = (UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0))
    
    static func getIntValue(fromData bytes: [UInt8]) -> Int {
        var value = 0
        
        for index in 0...bytes.count - 1 {
            value += Int(bytes[index]) << (index * 8)
        }
        return value
    }
    
    static func getStringValue(fromData bytes: [UInt8]) -> String? {
        let data = NSData(bytes: bytes , length: bytes.count)
        let size = bytes.indexOf(0) ?? bytes.count
        return String(data: data.subdataWithRange(NSMakeRange(0, size)), encoding: NSUTF8StringEncoding)
    }
    
    enum MessageType: UInt16 {
        case DeviceGetService = 2
        case DeviceStateService = 3
        case DeviceGetHostInfo = 12
        case DeviceStateHostInfo = 13
        
        case DeviceSetPower = 22
        case DeviceGetLabel = 23
        
        case DeviceStateLabel = 25
        
        case Ack = 45
        
        case DeviceGetGroup = 51
        case DeviceStateGroup = 53
        
        case LightGet = 101
        case LightSetColor = 102
        
        case LightState = 107
        
        case LightGetPower = 116
        case LightSetPower = 117
        case LightStatePower = 118
        
        case Unknown = 10000
    }
    
    
    /* frame */
    var size: UInt16 {
        var result = UInt16(LiFXMessage.headerSize)
        if let p = payload {
            result += UInt16(p.count)
        }
        return result
    }
    
    private let proto = 1024
    private let addressable = 1
    private let tagged: Int
    private let origin = 0
    private var source = 0 as UInt32
    /* frame address */
    let target: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)
    private var reserved = [UInt8](count: 6, repeatedValue: 0)
    private let res_required = 0
    private let ack_required = 1
    private var sequence: UInt8!
    /* protocol header */
    private let type: UInt16!
    /* variable length payload follows */
    
    var messageType: MessageType {
        if let mType = MessageType.init(rawValue: type) {
            return mType
        }
        return MessageType.Unknown
    }
    
    var targetMACAddress: String {
        return "\(target.0):\(target.1):\(target.2):\(target.3):\(target.4):\(target.5)"
    }
    
    let payload: [UInt8]?
    
    init(messageType: MessageType, targetAddress: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8) = LiFXMessage.noSource, taggedBit: Bool = true) {
        type = messageType.rawValue
        target = targetAddress
        tagged = (taggedBit) ? 1 : 0
        sequence = 0//LiFXMessage.generatedSequence++
        payload = nil
    }
    
    init(messageType: MessageType, targetAddress: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8), messagePayload:[UInt8]?) {
        type = messageType.rawValue
        target = targetAddress
        tagged = 1
        sequence = 0
        payload = messagePayload
    }
    
    init(messageType: MessageType, sequenceNumber: UInt8, sourceNumber: UInt32, targetAddress: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8), messagePayload:[UInt8]?) {
        type = messageType.rawValue
        sequence = sequenceNumber
        source = sourceNumber
        target = targetAddress
        tagged = 1
        sequence = sequenceNumber
        payload = messagePayload
    }
    
    init(fromData data: NSData) {
        let header = LiFXHeader(data: data)
        type = header.type
        target = header.target
        tagged = 1
        sequence = header.sequence
        source = header.source
        let payloadSize = Int(header.size) - LiFXMessage.headerSize
        if payloadSize > 0 {
            payload = [UInt8](count: payloadSize, repeatedValue: 0)
            data.getBytes(&payload!, range: NSMakeRange(LiFXMessage.headerSize, payload!.count))
        } else {
            payload = nil
        }
    }
    
    func getData() -> NSData {
        
        var byte64 = 0 as UInt64
        var byte16 = 0 as UInt16
        var byte32 = 0 as UInt32
        var byte8 = 0 as UInt8
        
        let data = NSMutableData()
        
        //let bytes:[UInt8] = [0x24, 0x00, 0x00, 0x34, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00]
        
        // ****** Frame ******
        
        // Size
        byte16 = size
        data.appendBytes(&byte16, length: 2)
        
        // Origin - tagged - addressable - protocol
        let shiftFlag = (origin << 14) + (tagged << 13) + (addressable << 12)
        byte16 = UInt16(proto | shiftFlag).littleEndian
        data.appendBytes(&byte16, length: 2)
        
        // Source
        byte32 = source.littleEndian
        data.appendBytes(&byte32, length: 4)
        
        // ****** End Frame ******
        
        //-----------------------------------------------------------------------------
        
        // ****** Frame address ******
        
        // Target
        //byte64 = target.littleEndian
        byte8 = target.0
        data.appendBytes(&byte8, length: 1)
        byte8 = target.1
        data.appendBytes(&byte8, length: 1)
        byte8 = target.2
        data.appendBytes(&byte8, length: 1)
        byte8 = target.3
        data.appendBytes(&byte8, length: 1)
        byte8 = target.4
        data.appendBytes(&byte8, length: 1)
        byte8 = target.5
        data.appendBytes(&byte8, length: 1)
        byte8 = target.6
        data.appendBytes(&byte8, length: 1)
        byte8 = target.7
        data.appendBytes(&byte8, length: 1)
        
        // Reserved
        var reservedByte = reserved
        data.appendBytes(&reservedByte, length: 6)
        
        // Reserved = 0 - ack_required - res_required
        byte8 = UInt8((ack_required << 1) + (res_required))
        data.appendBytes(&byte8, length: 1)
        
        // Sequence
        byte8 = sequence
        data.appendBytes(&byte8, length: 1)
        
        // ****** End Frame address ******
        
        //-----------------------------------------------------------------------------
        
        // ****** Protocol header ******
        
        // Reserved
        byte64 = 0 as UInt64
        data.appendBytes(&byte64, length: 8)
        
        // Type
        byte16 = type.littleEndian
        data.appendBytes(&byte16, length: 2)
        
        // Reserved
        byte16 = 0 as UInt16
        data.appendBytes(&byte16, length: 2)
        
        //-----------------------------------------------------------------------------
        
        // ****** Payload ******
        if var p = payload {
            data.appendBytes(&p, length: p.count)
        }
        
        return data
    }
    
    func getSequenceNumber() -> UInt8 {
        return sequence
    }
    
    func getSourceNumber() -> UInt32 {
        return source
    }
    
    //var next: LiFXMessage?

}

func == <T:Equatable> (tuple1:(T, T, T, T, T, T, T, T),tuple2:(T, T, T, T, T, T, T, T)) -> Bool
{
    return (tuple1.0 == tuple2.0) && (tuple1.1 == tuple2.1)
        && (tuple1.2 == tuple2.2) && (tuple1.3 == tuple2.3)
        && (tuple1.4 == tuple2.4) && (tuple1.5 == tuple2.5)
        && (tuple1.6 == tuple2.6) && (tuple1.7 == tuple2.7)
}

func == (lhs: [UInt8]?, rhs: [UInt8]?) -> Bool {
    if lhs == nil && rhs == nil {
        return true
    } else if lhs == nil || rhs == nil {
        return false
    } else {
        return lhs! == rhs!
    }
}

func == (lhs: LiFXMessage, rhs: LiFXMessage) -> Bool {
    return lhs.type == rhs.type
        && lhs.target == rhs.target
        && lhs.tagged == rhs.tagged
        && lhs.sequence == rhs.sequence
        && lhs.size == rhs.size
        && lhs.payload == rhs.payload
}

extension LiFXMessage: Equatable {}

extension LiFXMessage: CustomStringConvertible {
    var description: String {
        return "type = \(self.type)(\(self.messageType)), sequence = \(self.sequence), size = \(self.size), source = \(self.source), target = \(self.target)\nPayload = \(self.payload)"
    }
}

