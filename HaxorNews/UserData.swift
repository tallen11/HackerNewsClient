//
//  UserData.swift
//  HaxorNews
//
//  Created by Tate Allen on 10/22/16.
//  Copyright © 2016 Tate Allen. All rights reserved.
//

import Foundation

class UserData {
    
    var userID: String
    var delay: Int?
    var creationDate: Date?
    var karma: Int?
    var about: String?
    var submitted: [Int]?
    
    init(userID: String) {
        self.userID = userID
    }
    
    func setAllFields(dict: [String: AnyObject]) {
        self.delay = dict["delay"] as? Int
        self.creationDate = Date(timeIntervalSince1970: TimeInterval((dict["created"] as? Int)!))
        self.karma = dict["karma"] as? Int
        self.about = dict["about"] as? String
        self.submitted = dict["submitted"] as? [Int]
    }
}
