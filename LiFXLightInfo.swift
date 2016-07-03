//
//  LiFXLightInfo.swift
//  LiFXController
//
//  Created by Fred Rajaona on 26/12/2015.
//  Copyright © 2015 Fred Rajaona. All rights reserved.
//

import Foundation

struct LiFXLightInfo {
    
    let hue: Int
    let saturation: Int
    let brightness: Int
    let kelvin: Int
    let power: Int
    let label: String
    
    init(fromData bytes: [UInt8]) {
        var index = 0
        hue = LiFXMessage.getIntValue(fromData: [bytes[index + 1], bytes[index + 2]])
        index += 2
        saturation = LiFXMessage.getIntValue(fromData: [bytes[index + 1], bytes[index + 2]])
        index += 2
        brightness = LiFXMessage.getIntValue(fromData: [bytes[index + 1], bytes[index + 2]])
        index += 2
        kelvin = LiFXMessage.getIntValue(fromData: [bytes[index + 1], bytes[index + 2]])
        index += 2
        index += 2
        power = LiFXMessage.getIntValue(fromData: [bytes[index + 1], bytes[index + 2]])
        index += 2
        let labelArray: [UInt8] = Array(bytes[index...index + 32])
        label = LiFXMessage.getStringValue(fromData: labelArray) ?? ""
    }
}