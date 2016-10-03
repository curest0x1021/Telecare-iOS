//
//  Message.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 10/1/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation

class Message {
    var message:String? = ""
    var messageDate:Date? = Date()
    var isCurrentUsers:Bool? = false
    var isUnread:Bool? = true
    var isConsultMessage:Bool? = true
    var eid:String?
    var name:String?
}
