//
//  OffLights.swift
//  LiFXController
//
//  Created by Fred Rajaona on 29/12/2015.
//  Copyright © 2015 Fred Rajaona. All rights reserved.
//

import Foundation

/******* AppleScript use ********
 
 tell application "LiFXController"
    offLights {"group", "Chambre"}
 end tell
 
 *********************************/

class OffLights: NSScriptCommand {
    override func performDefaultImplementation() -> AnyObject? {
        
        if let directArgument = directParameter, let arguments = directArgument as? [String] where arguments.count > 0 {
            print("running OffLights command with string args: \(directArgument)")
            if arguments[0] == "group" {
                for index in 1 ..< arguments.count {
                    LiFXDeviceManager.sharedInstance.switchOffGroup(arguments[index])
                }
            } else {
                for index in 0 ..< arguments.count {
                    LiFXDeviceManager.sharedInstance.switchOff(arguments[index])
                }
            }
        }
        return nil
    }
}