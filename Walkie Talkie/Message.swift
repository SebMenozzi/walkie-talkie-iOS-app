//
//  Message.swift
//  Walkie Talkie
//
//  Created by Sebastien Menozzi on 26/12/2019.
//  Copyright © 2019 Sebastien Menozzi. All rights reserved.
//

import Foundation

enum MessageSender {
    case ourself
    case someoneElse
}

struct Message {
    
    let message: String
    let senderUsername: String
    let messageSender: MessageSender

    init(message: String, messageSender: MessageSender, username: String) {
        self.message = message.withoutWhitespace()
        self.messageSender = messageSender
        self.senderUsername = username
    }
    
}
