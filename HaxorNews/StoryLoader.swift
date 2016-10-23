//
//  StoryLoader.swift
//  HaxorNews
//
//  Created by Tate Allen on 10/22/16.
//  Copyright © 2016 Tate Allen. All rights reserved.
//

import Foundation

class StoryLoader {
    
    private var fullyLoadedStories = [ItemData]()
    private var allStories = [ItemData]()
    private var lastIndexLoaded = 0
    private let batchSize = 30
    private var loading = false
    private var itemsToLoad = 0
    private var itemsLoaded = 0
    
    func loadTopStoriesShallow(onFinished: @escaping (_ storiesLoaded: Int) -> ()) {
        guard !self.loading else {
            return
        }
        
        self.loading = true
        HNDataLoader.loadItemsShallowly(subPath: "topstories.json") { (items: [ItemData]?) in
            if let stories = items {
                self.fullyLoadedStories.removeAll(keepingCapacity: true)
                self.allStories.removeAll(keepingCapacity: true)
                self.lastIndexLoaded = 0
                self.itemsToLoad = 0
                self.itemsLoaded = 0
                self.allStories.append(contentsOf: stories)
                onFinished(stories.count)
            } else {
                onFinished(0)
            }
        }
    }
    
    /* Fully loads the next batch of shallowly loaded stories.
       Call will be ignored if another batch is being loaded already or
       if there are no shallowly loaded items to fully load or
       if all items have been fully loaded. */
    func loadNextBatch(onFinished: @escaping (_ items: [ItemData]) -> ()) {
        guard self.allStories.count > 0 || !self.loading || self.lastIndexLoaded == self.allStories.count - 1 else {
            return
        }
        
        self.loading = true
        self.itemsToLoad = min(self.batchSize, self.allStories.count - (self.lastIndexLoaded + 1))
        self.itemsLoaded = 0
        for i in max(self.lastIndexLoaded-1, 0)..<self.itemsToLoad + self.lastIndexLoaded {
            let story = self.allStories[i]
            HNDataLoader.loadItemFully(item: story, onFinished: { (success: Bool) in
                if success {
                    self.fullyLoadedStories.append(story)
                    self.itemsLoaded += 1
                    if self.itemsLoaded == self.itemsToLoad {
                        self.fullyLoadedStories.sort(by: { (item1: ItemData, item2: ItemData) -> Bool in
                            return item1.rank < item2.rank
                        })
                        
                        self.lastIndexLoaded += self.itemsToLoad
                        self.loading = false
                        onFinished(self.fullyLoadedStories)
                    }
                }
            })
        }
    }
    
    func refreshTopStories(onFinished: @escaping (_ items: [ItemData]) -> ()) {
        self.loadTopStoriesShallow { (storiesLoaded: Int) in
            self.loadNextBatch(onFinished: { (items: [ItemData]) in
                onFinished(items)
            })
        }
    }
    
    func shouldLoadNextBatch(row: Int, buffer: Int) -> Bool {
        return row + buffer >= self.lastIndexLoaded && !self.loading
    }
}
