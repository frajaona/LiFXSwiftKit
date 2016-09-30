//
//  ToggleAll.swift
//  LiFXController
//
//  Created by Fred Rajaona on 25/12/2015.
//  Copyright © 2015 Fred Rajaona. All rights reserved.
//

import Foundation

class ToggleAll: NSScriptCommand {
    override func performDefaultImplementation() -> Any? {
        print("running ToggleAll command")
        LiFXDeviceManager.sharedInstance.toggleDevices()
        return nil
    }
}
