//
//  Session.swift
//  LiFXController
//
//  Created by Fred Rajaona on 22/09/2015.
//  Copyright © 2015 Fred Rajaona. All rights reserved.
//

import Foundation

protocol Session {
    func start()
    func stop()
    func isConnected() -> Bool
}