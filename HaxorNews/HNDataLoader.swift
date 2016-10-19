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
                for (index, id) in ids.enumerated() {
                    stories!.append(ItemData(itemID: id, rank: index))
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
    
    func loadCommentTree(item: ItemData, completionBlock: @escaping () -> ()) {
        let items = Queue<ItemData>()
        items.append(newElement: item)
        
        let totalComments = item.descendentsCount!
        var count = 0
        let dq = DispatchQueue(label: "com.tateallen.commentlock")
        while !items.isEmpty() {
            let i = items.dequeue()!
            Alamofire.request(hnBaseURL.appendingPathComponent("item/\(i.itemID).json")!).responseJSON(completionHandler: { (response: DataResponse) in
                if let json = response.result.value {
                    let dict = json as! [String: AnyObject]
                    i.setAllFields(dict: dict)
                    dq.sync {
                        count += 1
                        for subItem in i.children! {
                            items.append(newElement: subItem)
                        }
                    }
                }
                
                if count >= totalComments {
                    completionBlock()
                }
            })
        }
        
        
//        if let children = item.children {
//            for child in children {
//                if !child.fullyLoaded {
//                    Alamofire.request(hnBaseURL.appendingPathComponent("item/\(child.itemID).json")!).responseJSON(completionHandler: { (response: DataResponse) in
//                        if let json = response.result.value {
//                            let dict = json as! [String: AnyObject]
//                            child.setAllFields(dict: dict)
//                            
//                            self.loadCommentTree(item: child, completionBlock: { (items: [ItemData]?) in
//                                
//                            })
//                        }
//                    })
//                }
//            }
//        }
    }
}
