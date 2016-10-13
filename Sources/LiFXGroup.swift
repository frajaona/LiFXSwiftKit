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

struct LiFXGroup {
    
    fileprivate static let groupByteCount = 16
    fileprivate static let labelByteCount = 32
    fileprivate let dataSize = LiFXGroup.groupByteCount + LiFXGroup.labelByteCount
    
    let group: [UInt8]
    let label: String
    let valid: Bool
    
    init(fromData bytes: [UInt8]) {
        var valid = false
        var label: String? = nil
        var group: [UInt8]? = nil
        if bytes.count >= dataSize {
            group = [UInt8](repeating: 0, count: LiFXGroup.groupByteCount)
            for i in 0..<LiFXGroup.groupByteCount {
                group![i] = bytes[i]
            }
            let labelArray: [UInt8] = Array(bytes[LiFXGroup.groupByteCount...LiFXGroup.groupByteCount + LiFXGroup.labelByteCount])
            label = LiFXMessage.getStringValue(fromData: labelArray)
            if let index = label?.characters.index(of: "\0") {
                label = label?.substring(to: index)
            }
            valid = label != nil
        }
        print("Label group is \(label)")
        self.group = group ?? [UInt8]()
        self.label = label ?? ""
        self.valid = valid
    }
}
