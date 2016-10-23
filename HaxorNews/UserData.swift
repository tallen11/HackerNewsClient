//
//  UserData.swift
//  HaxorNews
//
//  Created by Tate Allen on 10/22/16.
//  Copyright © 2016 Tate Allen. All rights reserved.
//

import Foundation
import UIKit

class UserData {
    
    var userID: String
    var delay: Int?
    var creationDate: Date?
    var karma: Int?
    var about: NSAttributedString?
    var submitted: [Int]?
    
    init(userID: String) {
        self.userID = userID
    }
    
    func setAllFields(dict: [String: AnyObject]) {
        self.delay = dict["delay"] as? Int
        self.creationDate = Date(timeIntervalSince1970: TimeInterval((dict["created"] as? Int)!))
        self.karma = dict["karma"] as? Int
        if let about = dict["about"] as? String {
            let str = about + String(format: "<style>body{font-family: '%@'; font-size:%fpx;}</style>", "Avenir Next", 17.0).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let htmlText = try! NSAttributedString(data: str.data(using: String.Encoding.unicode, allowLossyConversion: true)!, options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
            self.about = htmlText
        } else {
            self.about = nil
        }
        
        self.submitted = dict["submitted"] as? [Int]
    }
}
