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