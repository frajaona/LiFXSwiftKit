//
//  OnAll.swift
//  LiFXController
//
//  Created by Fred Rajaona on 04/10/2015.
//  Copyright © 2015 Fred Rajaona. All rights reserved.
//

import Foundation

class OnAll: NSScriptCommand {
    override func performDefaultImplementation() -> Any? {
        print("running OnAll command")
        LiFXDeviceManager.sharedInstance.switchOnDevices()
        return nil
    }
}
