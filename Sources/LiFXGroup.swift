//
//  LiFXGroup.swift
//  LiFXController
//
//  Created by Fred Rajaona on 26/12/2015.
//  Copyright © 2015 Fred Rajaona. All rights reserved.
//

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
