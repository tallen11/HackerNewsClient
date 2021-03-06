//
//  ItemData.swift
//  HaxorNews
//
//  Created by Tate Allen on 10/18/16.
//  Copyright © 2016 Tate Allen. All rights reserved.
//

import Foundation
import UIKit

enum HNItemType {
    case Job
    case Story
    case Comment
    case Poll
    case PollOpt
}

class ItemData {
    
    var itemID: Int
    var rank: Int
    var fullyLoaded: Bool
    
    var title: String?
    var deleted: Bool?
    var dead: Bool?
    var url: NSURL?
    var text: NSAttributedString?
    var author: String?
    var descendentsCount: Int?
    var children: [ItemData]?
    var score: Int?
    var time: Date?
    var type: HNItemType?
    
    init(itemID: Int, rank: Int) {
        self.itemID = itemID
        self.rank = rank
        self.fullyLoaded = false
    }
    
    init(other: ItemData) {
        self.itemID = other.itemID
        self.rank = other.rank
        self.fullyLoaded = other.fullyLoaded
        self.title = other.title
        self.deleted = other.deleted
        self.dead = other.dead
        self.url = other.url
        self.text = other.text
        self.author = other.author
        self.descendentsCount = other.descendentsCount
        if let otherChildren = other.children {
            self.children = [ItemData]()
            for child in otherChildren {
                self.children!.append(ItemData(other: child))
            }
        } else {
            self.children = nil
        }
        
        self.score = other.score
        self.time = other.time
        self.type = other.type
    }
    
    func setAllFields(dict: [String: AnyObject]) {
        self.title = dict["title"] as? String
        if let url = dict["url"] as? String {
            self.url = NSURL(string: url)
        } else if let text = dict["text"] as? String {
            let str = text + String(format: "<style>body{font-family: '%@'; font-size:%fpx;}</style>", "Avenir Next", 12.0).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let htmlText = try! NSAttributedString(data: str.data(using: String.Encoding.unicode, allowLossyConversion: true)!, options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
            self.text = htmlText
        }
        
        self.deleted = dict["deleted"] as? Bool
        self.dead = dict["dead"] as? Bool
        self.author = dict["by"] as? String
        self.descendentsCount = dict["descendants"] as? Int
        self.score = dict["score"] as? Int
        self.time = Date(timeIntervalSince1970: TimeInterval((dict["time"] as? Int)!)) // Fix this!
        self.type = self.typeStringToItemType(str: dict["type"] as! String)! // Fix this too!
        self.children = [ItemData]()
        if let childrenItemIDs = dict["kids"] as? [Int] {
            for (index, id) in childrenItemIDs.enumerated() {
                self.children!.append(ItemData(itemID: id, rank: index))
            }
        }
        
        fullyLoaded = true;
    }
    
    private func typeStringToItemType(str: String) -> HNItemType? {
        if str == "job" {
            return HNItemType.Job
        } else if str == "story" {
            return HNItemType.Story
        } else if str == "comment" {
            return HNItemType.Comment
        } else if str == "poll" {
            return HNItemType.Poll
        } else if str == "pollopt" {
            return HNItemType.PollOpt
        } else {
            return nil
        }
    }
    
    private func trimQuotes(str: String) -> String {
        let range = Range<String.Index>(uncheckedBounds: (lower: str.index(after: str.startIndex), upper: str.index(before: str.endIndex)))
        let trimmed = str.substring(with: range)
        return trimmed
    }
}
