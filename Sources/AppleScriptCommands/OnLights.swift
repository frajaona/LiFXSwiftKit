//
//  OnLights.swift
//  LiFXController
//
//  Created by Fred Rajaona on 15/12/2015.
//  Copyright © 2015 Fred Rajaona. All rights reserved.
//

import Foundation

/******* AppleScript use ********
 
 tell application "LiFXController"
    onLights {"Lampadaire"}
 end tell
 
 *********************************/

class OnLights: NSScriptCommand {
    override func performDefaultImplementation() -> Any? {
        
        if let directArgument = directParameter, let arguments = directArgument as? [String] , arguments.count > 0 {
            print("running OnLights command with string args: \(directArgument)")
            if arguments[0] == "group" {
                for index in 1 ..< arguments.count {
                    LiFXDeviceManager.sharedInstance.switchOnGroup(arguments[index])
                }
            } else {
                for index in 0 ..< arguments.count {
                    LiFXDeviceManager.sharedInstance.switchOn(arguments[index])
                }
            }
        }
        return nil
    }
}
