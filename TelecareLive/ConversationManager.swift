//
//  ConversationManager.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 10/1/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class ConversationManager : ModelManager{
    static func populateMessagesForConversation(conversation: Conversation){
        restManager?.getAllMessages(conversation: conversation, callback: finishGettingAllMessages)
    }
    
    static func finishGettingAllMessages(conversation: Conversation, restData: JSON){
        var messages: [Message] = []
        
        // FINISH THIS OUT
        print(restData)
        print("ABOVE IS REST DATA FROM MESSAGES")
        
        for (_, subJson) in restData["data"]["messages"] {
            messages.append(ConversationManager.getMessageUsing(json: subJson))
        }
        
        conversation.messages = messages
        
        currentRestController?.refreshData()
    }
    
    static func getConversationUsing(json: JSON)-> Conversation{
        let conversation = Conversation()
        
        conversation.entityId = json["eid"].string!
        conversation.organizationId = json["organization_id"].string!
        conversation.recipientId = json["user_id"].string!
        conversation.status = json["status"].string!
        conversation.lastActivity = json["last_activity"].string!
        
        let person = Person()
        person.fullName = json["user_full_name"].string!
        person.birthdate = Date.init(timeIntervalSince1970: TimeInterval(json["user_birthdate"].string!)!)
        
        var userImage: UIImage?
        switch json["user_image"].type {
        case .string:
            let image = UIImageView()
            image.setImageFromURl(stringImageUrl: json["user_image"].string!)
            userImage = image.image!
            person.userImageUrl = json["user_image"].string!
        case .array:
            person.userImageUrl = ""
        default:break
        }
        
        if(userImage == nil){
            userImage = UIImage(named: "Default")
        }
        
        person.userImage = userImage
        
        conversation.person = person
        
        return conversation
    }
    
    static func getMessageUsing(json: JSON) -> Message {
        let message = Message()
        
        message.message = json["message_text"].string!
        message.messageDate = Date.init(timeIntervalSince1970: TimeInterval(json["created"].string!)!)
        message.isCurrentUsers = (self.appDelegate.currentlyLoggedInPerson?.email == json["name"].string!)
        message.isUnread = (json["unread"].string! == "0")
        message.isConsultMessage = (json["consult_id"].string! != "0")
        message.eid = json["eid"].string!
        message.name = json["name"].string!
        
        return message
    }
}
