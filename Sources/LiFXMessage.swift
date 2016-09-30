//
//  LiFXMessage.swift
//  LiFXController
//
//  Created by Fred Rajaona on 14/09/2015.
//  Copyright (c) 2015 Fred Rajaona. All rights reserved.
//

import Foundation


struct LiFXMessage: Message {
    
    fileprivate static let headerSize = 36 // bytes
    
    fileprivate static let noSource = (UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0))
    
    static func getIntValue(fromData bytes: [UInt8]) -> Int {
        var value = 0
        
        for index in 0...bytes.count - 1 {
            value += Int(bytes[index]) << (index * 8)
        }
        return value
    }
    
    static func getStringValue(fromData bytes: [UInt8]) -> String? {
        let data = NSData(bytes: UnsafePointer<UInt8>(bytes) , length: bytes.count)
        let size = bytes.index(of: 0) ?? bytes.count
        return String(data: data.subdata(with: NSMakeRange(0, size)), encoding: String.Encoding.utf8)
    }
    
    enum MessageType: UInt16 {
        case deviceGetService = 2
        case deviceStateService = 3
        case deviceGetHostInfo = 12
        case deviceStateHostInfo = 13
        
        case deviceSetPower = 22
        case deviceGetLabel = 23
        
        case deviceStateLabel = 25
        
        case ack = 45
        
        case deviceGetGroup = 51
        case deviceStateGroup = 53
        
        case lightGet = 101
        case lightSetColor = 102
        
        case lightState = 107
        
        case lightGetPower = 116
        case lightSetPower = 117
        case lightStatePower = 118
        
        case unknown = 10000
    }
    
    
    /* frame */
    var size: UInt16 {
        var result = UInt16(LiFXMessage.headerSize)
        if let p = payload {
            result += UInt16(p.count)
        }
        return result
    }
    
    fileprivate let proto = 1024
    fileprivate let addressable = 1
    fileprivate let tagged: Int
    fileprivate let origin = 0
    fileprivate var source = 0 as UInt32
    /* frame address */
    let target: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)
    fileprivate var reserved = [UInt8](repeating: 0, count: 6)
    fileprivate let res_required = 0
    fileprivate let ack_required = 1
    fileprivate var sequence: UInt8!
    /* protocol header */
    fileprivate let type: UInt16!
    /* variable length payload follows */
    
    var messageType: MessageType {
        if let mType = MessageType.init(rawValue: type) {
            return mType
        }
        return MessageType.unknown
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
    
    init(fromData data: Data) {
        let header = LiFXHeader(data: data)
        type = header.type
        target = header.target
        tagged = 1
        sequence = header.sequence
        source = header.source
        let payloadSize = Int(header.size) - LiFXMessage.headerSize
        if payloadSize > 0 {
            payload = [UInt8](repeating: 0, count: payloadSize)
            (data as NSData).getBytes(&payload!, range: NSMakeRange(LiFXMessage.headerSize, payload!.count))
        } else {
            payload = nil
        }
    }
    
    func getData() -> Data {
        
        var byte64 = 0 as UInt64
        var byte16 = 0 as UInt16
        var byte32 = 0 as UInt32
        var byte8 = 0 as UInt8
        
        let data = NSMutableData()
        
        //let bytes:[UInt8] = [0x24, 0x00, 0x00, 0x34, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00]
        
        // ****** Frame ******
        
        // Size
        byte16 = size
        data.append(&byte16, length: 2)
        
        // Origin - tagged - addressable - protocol
        let shiftFlag = (origin << 14) + (tagged << 13) + (addressable << 12)
        byte16 = UInt16(proto | shiftFlag).littleEndian
        data.append(&byte16, length: 2)
        
        // Source
        byte32 = source.littleEndian
        data.append(&byte32, length: 4)
        
        // ****** End Frame ******
        
        //-----------------------------------------------------------------------------
        
        // ****** Frame address ******
        
        // Target
        //byte64 = target.littleEndian
        byte8 = target.0
        data.append(&byte8, length: 1)
        byte8 = target.1
        data.append(&byte8, length: 1)
        byte8 = target.2
        data.append(&byte8, length: 1)
        byte8 = target.3
        data.append(&byte8, length: 1)
        byte8 = target.4
        data.append(&byte8, length: 1)
        byte8 = target.5
        data.append(&byte8, length: 1)
        byte8 = target.6
        data.append(&byte8, length: 1)
        byte8 = target.7
        data.append(&byte8, length: 1)
        
        // Reserved
        var reservedByte = reserved
        data.append(&reservedByte, length: 6)
        
        // Reserved = 0 - ack_required - res_required
        byte8 = UInt8((ack_required << 1) + (res_required))
        data.append(&byte8, length: 1)
        
        // Sequence
        byte8 = sequence
        data.append(&byte8, length: 1)
        
        // ****** End Frame address ******
        
        //-----------------------------------------------------------------------------
        
        // ****** Protocol header ******
        
        // Reserved
        byte64 = 0 as UInt64
        data.append(&byte64, length: 8)
        
        // Type
        byte16 = type.littleEndian
        data.append(&byte16, length: 2)
        
        // Reserved
        byte16 = 0 as UInt16
        data.append(&byte16, length: 2)
        
        //-----------------------------------------------------------------------------
        
        // ****** Payload ******
        if var p = payload {
            data.append(&p, length: p.count)
        }
        
        return data as Data
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

