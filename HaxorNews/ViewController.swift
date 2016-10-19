//
//  ViewController.swift
//  HaxorNews
//
//  Created by Tate Allen on 10/18/16.
//  Copyright © 2016 Tate Allen. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Alamofire.request("https://hacker-news.firebaseio.com/v0/topstories.json").responseJSON { (response: DataResponse) in
            if let json = response.result.value {
                let a = json as! [Int]
                Alamofire.request("https://hacker-news.firebaseio.com/v0/item/\(a[0]).json").responseJSON(completionHandler: { (itemResponse: DataResponse) in
                    if let j = itemResponse.result.value {
                        print(j)
                    }
                })
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

