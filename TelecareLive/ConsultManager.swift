//
//  ConsultManager.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 10/1/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit

class ConsultManager : ModelManager{
    static func getMessagesForConsult(consult: Consult) -> [Message]{
        return []
    }
    static func populateConsultsForConversation(conversation: Conversation){
        restManager?.getAllConsults(conversation: conversation, callback: self.finishGettingAllConsults)
    }
    
    static func finishGettingAllConsults(conversation: Conversation, restData: JSON){
        print(restData)
        var consults:[Consult] = []
        
        for(_,subJson) in restData["data"]{
            consults.append(ConsultManager.getConsultUsing(json: subJson))
        }
        
        conversation.consults = consults
        
        currentRestController?.refreshData()
    }
    
    static func getConsultUsing(json:JSON) -> Consult{
        let consult = Consult()
        consult.entityId = json["eid"].string!
        consult.issue = json["issue"].string!
        consult.organizationId = json["organization_id"].string!
        consult.status = json["status"].string!
        consult.userImageUrl = json["user_image"].string!
        consult.userId = json["uid"].string!
        
        // Refactor this at some point
        var userImage: UIImage?
        switch json["user_image"].type {
        case .string:
            let image = UIImageView()
            image.setImageFromURl(stringImageUrl: json["user_image"].string!)
            userImage = image.image!
            consult.userImageUrl = json["user_image"].string!
        case .array:
            consult.userImageUrl = ""
        default:break
        }
        
        if(userImage == nil){
            userImage = UIImage(named: "Default")
        }
        
        consult.userImage = userImage
        consult.birthdate = Date.init(timeIntervalSince1970: Double(json["user_birthdate"].string!)!)
        
        self.populateMessagesForConsult(consult: consult)
        
        return consult
    }
    
    static func populateMessagesForConsult(consult: Consult){
        restManager?.getAllConsultMessages(consult: consult, callback: self.finishGettingAllConsultMessages)
    }
    
    static func finishGettingAllConsultMessages(consult: Consult, restData: JSON){
        print(consult)
        print(restData)
        var messages:[Message] = []
        
        for(key,subJson) in restData["data"]["messages"]{
            print(subJson)
            messages.append(self.getConsultMessageUsing(json: subJson))
        }
        
        consult.messages = messages
        
        currentRestController?.refreshData()
    }
    
    static func getConsultMessageUsing(json:JSON)->Message{
        let message = Message()
        
        print(json)
        
        message.message = json["message_text"].string!
        message.messageDate = Date.init(timeIntervalSince1970: TimeInterval(json["created"].string!)!)
        message.isCurrentUsers = (self.appDelegate.currentlyLoggedInPerson?.userId == json["uid"].string!)
        message.isUnread = (json["unread"].string! == "0")
        message.isConsultMessage = (json["consult_id"].string! != "0")
        message.eid = json["eid"].string!
        message.name = json["name"].string!
        message.conversationId = json["conversation_id"].string!
        message.fileId = json["fid"].string!
        
        if json["message_image"].string != nil {
            message.mediaUrl = json["message_image"].string!
        }
        
        if json["filemime"].string != nil {
            message.fileMime = json["filemime"].string!
            message.hasMedia = true
            
            let imageView = UIImageView()
            
            switch json["filemime"].string! {
            case "image/png":
                imageView.setImageFromURl(stringImageUrl: message.mediaUrl!)
            case "image/jpg":
                imageView.setImageFromURl(stringImageUrl: message.mediaUrl!)
            case "image/jpeg":
                imageView.setImageFromURl(stringImageUrl: message.mediaUrl!)
            case "audio/ogg":
                imageView.image = UIImage(named: "AudioIcon")
                message.hasAudio = true
            case "application/octet-stream":
                imageView.image = UIImage(named: "AudioIcon")
                message.hasAudio = true
            case "audio/mp3":
                imageView.image = UIImage(named: "AudioIcon")
                message.hasAudio = true
            default:break
            }
            
            message.imageMedia = imageView.image
        }
        
        return message
    }
}
