//
//  LiFXHeader.swift
//  LiFXSwiftKit
//
//  Created by Fred Rajaona on 03/07/2016.
//  Copyright © 2016 Fred Rajaona. All rights reserved.
//

import Foundation

struct LiFXHeader {
    /* frame */
    let size: UInt16
    let prtcl: UInt16
    let addressable: Bool
    let tagged: Bool
    let origin: UInt8
    let source: UInt32
    /* frame address */
    let target: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8) // 64 bits
    //let reserved: [UInt8] // 48 bits
    let res_required: Bool
    let ack_required: Bool
    //uint8_t  :6;
    let sequence: UInt8;
    /* protocol header */
    //uint64_t :64;
    let type: UInt16;
    //uint16_t :16;
    /* variable length payload follows */
    
    init(data: Data) {
        var byte16 = UInt16(0)
        (data as NSData).getBytes(&byte16, length: 2)
        size = byte16
        
        (data as NSData).getBytes(&byte16, range: NSMakeRange(2, 2))
        prtcl = byte16 & 0xFFF
        addressable = (byte16 >> 12) & 0x1 == 1
        tagged = (byte16 >> 13) & 0x1 == 1
        origin = UInt8((byte16 >> 14) & 0x3)
        
        var byte32 = UInt32(0)
        (data as NSData).getBytes(&byte32, range: NSMakeRange(4, 4))
        source = byte32
        
        var targetBuffer = [UInt8](repeating: 0, count: 8)
        (data as NSData).getBytes(&targetBuffer, range: NSMakeRange(8, 8))
        target = (targetBuffer[0], targetBuffer[1], targetBuffer[2], targetBuffer[3], targetBuffer[4], targetBuffer[5], targetBuffer[6], targetBuffer[7])
        
        var byte8 = UInt8(0)
        (data as NSData).getBytes(&byte8, range: NSMakeRange(22, 1))
        ack_required = (byte8 >> 1) & 0x1 == 1
        res_required = byte8 & 0x1 == 1
        
        (data as NSData).getBytes(&byte8, range: NSMakeRange(23, 1))
        sequence = byte8
        
        (data as NSData).getBytes(&byte16, range: NSMakeRange(32, 2))
        type = byte16
    }
    
}
