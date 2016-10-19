//
//  CommentsViewController.swift
//  HaxorNews
//
//  Created by Tate Allen on 10/19/16.
//  Copyright © 2016 Tate Allen. All rights reserved.
//

import UIKit

class CommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var commentsTableView: UITableView!
    var story: ItemData?
    var dataSource = [ItemData]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Trying to load...")
        HNDataLoader.instance.loadCommentTree(item: self.story!) {
            print("Loaded all comments!")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "comment_cell", for: indexPath) as! CommentsTableViewCell
        return cell
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
