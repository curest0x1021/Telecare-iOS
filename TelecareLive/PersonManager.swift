//
//  PersonManager.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 10/1/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import SwiftyJSON

class PersonManager : ModelManager{
    
    static func getPeopleForLoggedInUser() -> [Person]{
        return []
    }
    
    static func getConversations(person:Person){
        restManager?.getAllConversations(person:person, callback: finishGetConversations)
    }
    
    static func finishGetConversations(person: Person, restData: JSON){
        print(restData)
        var conversations: [Conversation] = []
        
        for(_,jsonSub) in restData["data"] {
            conversations.append(ConversationManager.getConversationUsing(json: jsonSub))
        }
        
        person.conversations = conversations
        
        currentRestController?.refreshData()
    }
    
    static func getConsults(person:Person) -> [Consult]{
        return []
    }
    
    static func getPersonUsing(json: JSON) -> Person{
        let person = Person()
        
        person.fullName = json["data"]["user_full_name"].string!
        person.phone = json["data"]["user_phone"].string!
        person.email = json["data"]["mail"].string!
        
        var userImage: UIImage?
        switch json["data"]["user_image"].type {
            case .string:
                let image = UIImageView()
                image.setImageFromURl(stringImageUrl: json["data"]["user_image"].string!)
                userImage = image.image!
                person.userImageUrl = json["data"]["user_image"].string!
            case .array:
                person.userImageUrl = ""
        default:break
        }
        
        if(userImage == nil){
            userImage = UIImage(named: "Default")
        }
        
        person.userImage = userImage
        person.birthdate = Date.init(timeIntervalSince1970: Double(json["data"]["user_birthdate"].int!))
        person.notifications = (json["data"]["user_notifications"].int! == 1)
        person.isDoctor = (json["data"]["doctor"].int! == 1)
        person.lockCode = json["data"]["user_lock_code"].string!
        person.userId = json["data"]["uid"].string!
        
        PersonManager.getConversations(person: person)
        person.consults = PersonManager.getConsults(person: person)
        
        return person
    }
    
//    static func getPersonUsing(id: String) -> Person{
//        
//    }
}
