//
//  Socket.swift
//  LiFXController
//
//  Created by Fred Rajaona on 09/02/2016.
//  Copyright © 2016 Fred Rajaona. All rights reserved.
//

import Foundation

protocol Socket {
    
    func openConnection() -> Bool
    func closeConnection()
    func isConnected() -> Bool
    func sendMessage<T: Message>(message: T, address: String)
}