//
//  Extensions.swift
//  HaxorNews
//
//  Created by Tate Allen on 10/19/16.
//  Copyright © 2016 Tate Allen. All rights reserved.
//

import Foundation
import UIKit

extension Date {
    
    func elapsedTimePretty() -> String {
        let interval = abs(self.timeIntervalSinceNow)
        let dict = [
            "seconds": interval.truncatingRemainder(dividingBy: 60),
            "minutes": (interval / 60).truncatingRemainder(dividingBy: 60),
            "hours": (interval / 3600),
            "days": (interval / (3600 * 24))
        ]
        
        var smallestWholeString = "seconds"
        var smallestWhole = dict[smallestWholeString]!
        for d in dict.keys {
            let component = dict[d]!
            if Int(component) > 0 && component < smallestWhole {
                smallestWhole = component
                smallestWholeString = d
            }
        }
        
        let final = Int(round(smallestWhole))
        if final == 1 {
            smallestWholeString = smallestWholeString.substring(to: smallestWholeString.index(before: smallestWholeString.endIndex))
        }
        
        return "\(final) \(smallestWholeString) ago"
    }
}

extension UITableView {
    
    func fadeIn(duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: ((Bool) -> Void)? = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.alpha = 1.0
            }, completion: completion)  }
    
    func fadeOut(duration: TimeInterval = 1.0, delay: TimeInterval = 3.0, completion: ((Bool) -> Void)? = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.alpha = 0.0
            }, completion: completion)
    }
}
