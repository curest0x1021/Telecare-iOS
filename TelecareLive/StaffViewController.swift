//
//  StaffViewController.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 10/7/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class StaffViewController : RestViewController, UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var navTitle: UINavigationItem!
    
    var refreshControl = UIRefreshControl()
    
    var conversations:[Conversation] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tabBarController?.hidesBottomBarWhenPushed = true
        navigationController?.navigationBar.titleTextAttributes?["ForegroundColorAttributeName"] = UIColor.white
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(self.refreshData), for: UIControlEvents.valueChanged)
        self.tableView?.addSubview(refreshControl)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.refreshData()
        navTitle.title = "Staff"
    }
    
    override func refreshData(){
        // tell refresh control it can stop showing up now
        if self.refreshControl.isRefreshing
        {
            self.refreshControl.endRefreshing()
        }
        
        restManager?.getAllStaffConversations(callback: refreshTable)
    }
    
    func refreshTable(restData: JSON){
        self.conversations = []
        
        for(_,jsonSub) in restData["data"] {
            if(jsonSub["staff_conversation"] != nil){
                if(jsonSub["staff_conversation"] == "0"){
                    continue
                }
            }
            conversations.append(ConversationManager.getConversationUsing(json: jsonSub))
        }
        
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let conversation = conversations[indexPath.row]
        
        let cell:ConversationCell = self.tableView.dequeueReusableCell(withIdentifier: "ConversationCell")! as! ConversationCell
        let person = conversation.person
        let fullname = person?.fullName!
        
        cell.nameField.text = fullname
        cell.profileImage.image = person?.userImage?.af_imageRoundedIntoCircle()
        
        return cell
    }
    
    // MARK: - Segue Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(sender)
        print("ABOVE IS THE SENDER")
        switch segue.identifier! {
        case "staffMessage" :
            let destination = segue.destination as? AVCRestViewController
            let row = (tableView.indexPathForSelectedRow?.row)!
            destination?.delegate = self
            destination?.currentEid = conversations[row].entityId
            destination?.currentConversation = conversations[row]
        default:break
        }
    }
}
