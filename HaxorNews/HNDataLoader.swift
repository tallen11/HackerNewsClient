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
    
    static let hnBaseURL = NSURL(string: "https://hacker-news.firebaseio.com/v0")!
    
    static func loadItemsShallowly(subPath: String, onFinished: @escaping (_ items: [ItemData]?) -> ()) {
        if let fullURL = hnBaseURL.appendingPathComponent(subPath) {
            Alamofire.request(fullURL).responseJSON(completionHandler: { (response: DataResponse) in
                if let json = response.result.value, let ids = json as? [Int] {
                    var items = [ItemData]()
                    items.append(contentsOf: ids.enumerated().map({ (offset: Int, element: Int) -> ItemData in
                        return ItemData(itemID: element, rank: offset + 1)
                    }))
                    onFinished(items)
                } else {
                    onFinished(nil)
                }
            })
        } else {
            onFinished(nil)
        }
    }
    
    static func loadItemFully(item: ItemData, onFinished: @escaping (_ success: Bool) -> ()) {
        if let fullURL = hnBaseURL.appendingPathComponent("item/\(item.itemID).json") {
            Alamofire.request(fullURL).responseJSON { (response: DataResponse) in
                if let json = response.result.value, let dict = json as? [String: AnyObject] {
                    item.setAllFields(dict: dict)
                    onFinished(true)
                } else {
                    onFinished(false)
                }
            }
        } else {
            onFinished(false)
        }
    }
    
    
    // Old code to be replaced...
    static func loadTopStories(completionBlock: @escaping (_: [ItemData]?) -> ()) {
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
    
    static func loadTopLevelComments(item: ItemData, onFinished: @escaping () -> ()) {
        if let children = item.children {
            let commentsToLoad = children.count
            var commentsLoaded = 0
            let lock = DispatchQueue(label: "com.tateallen.commentlock")
            for child in children {
                // if !child.fullyLoaded {
                    self.loadItemFully(item: child, onFinished: { (success: Bool) in
                        lock.sync {
                            commentsLoaded += 1
                            if commentsLoaded >= commentsToLoad {
                                onFinished()
                            }
                        }
                    })
                // }
            }
        }
    }
    
    static func loadCommentTree(item: ItemData, completionBlock: @escaping () -> ()) {
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
    }
}
