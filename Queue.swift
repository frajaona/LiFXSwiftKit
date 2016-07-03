//
//  Queue.swift
//  LiFXController
//
//  Created by Fred Rajaona on 21/12/2015.
//  Copyright © 2015 Fred Rajaona. All rights reserved.
//

import Foundation

class Queue<T> {
    private var items = [T]()
    
    func enQueue(item: T) {
        items.append(item)
    }
    
    func deQueue() -> T? {
        return items.removeFirst()
    }
    
    func isEmpty() -> Bool {
        return items.isEmpty
    }
    
    func peek() -> T? {
        return items.first
    }
    
    func size() -> Int {
        return items.count
    }
}