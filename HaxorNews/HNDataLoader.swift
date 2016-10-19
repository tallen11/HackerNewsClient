//
//  HNDataLoader.swift
//  HaxorNews
//
//  Created by Tate Allen on 10/18/16.
//  Copyright © 2016 Tate Allen. All rights reserved.
//

import Foundation
import Alamofire

class HNDataLoader {
    
    static let instance = HNDataLoader()
    private let hnBaseURL = NSURL(string: "https://hacker-news.firebaseio.com/v0")!
    
    private init() {
        
    }
    
    func loadTopStories(completionBlock: @escaping (_: [ItemData]?) -> ()) {
        Alamofire.request(hnBaseURL.appendingPathComponent("topstories.json")!).responseJSON { (response: DataResponse) in
            var stories: [ItemData]? = nil
            if let json = response.result.value {
                stories = [ItemData]()
                let ids = json as! [Int]
                for id in ids {
                    stories!.append(ItemData(itemID: id))
                }
            }
            
            completionBlock(stories)
        }
    }
    
    func fullyLoadStory(story: ItemData, completionBlock: @escaping (_: ItemData?) -> ()) {
        Alamofire.request(hnBaseURL.appendingPathComponent("item/\(story.itemID).json")!).responseJSON { (response: DataResponse) in
            if let json = response.result.value {
                let dict = json as! [String: AnyObject]
                story.setAllFields(dict: dict)
                completionBlock(story)
            } else {
                completionBlock(nil)
            }
        }
    }
}
