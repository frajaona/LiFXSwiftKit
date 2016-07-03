//
//  OffAll.swift
//  LiFXController
//
//  Created by Fred Rajaona on 04/10/2015.
//  Copyright © 2015 Fred Rajaona. All rights reserved.
//

import Foundation

class OffAll: NSScriptCommand {
    override func performDefaultImplementation() -> AnyObject? {
        print("running OffAll command")
        LiFXDeviceManager.sharedInstance.switchOffDevices()
        return nil
    }
}