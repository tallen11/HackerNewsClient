//
//  MainTableViewController.swift
//  HaxorNews
//
//  Created by Tate Allen on 10/18/16.
//  Copyright © 2016 Tate Allen. All rights reserved.
//

import UIKit
import SafariServices

class MainTableViewController: UITableViewController, MainTableViewCellDelegate {
    
    private var dataSource = [ItemData]()
    private var allStories = [ItemData]()
    private var lastIndexLoaded = 0
    private let batchSize = 30
    private var loading = false
    private var itemsToLoad = 0
    private var itemsLoaded = 0
    private var freshlyLoadedStories = [ItemData]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Avenir Next", size: 20)!]
        self.navigationController?.navigationBar.topItem?.title = "Hacker News"
        
        HNDataLoader.instance.loadTopStories { (stories: [ItemData]?) in
            if let stories = stories {
                for i in 0..<stories.count {
                    self.allStories.append(stories[i])
                }
                
                self.loadNextBatch()
            }
        }
    }
    
    private func loadNextBatch() {
        if self.lastIndexLoaded == self.allStories.count - 1 {
            return
        }
        
        self.itemsToLoad = min(self.batchSize, self.allStories.count - (self.lastIndexLoaded + 1))
        self.loading = true
        self.itemsLoaded = 0
        for i in max(self.lastIndexLoaded-1, 0)..<self.itemsToLoad + self.lastIndexLoaded {
            HNDataLoader.instance.fullyLoadItem(item: self.allStories[i], completionBlock: { (story: ItemData?) in
                if let story = story {
                    self.dataSource.append(story)
                }
                
                self.itemsLoaded += 1
                if self.itemsLoaded == self.itemsToLoad {
                    self.loading = false
                    self.dataSource.sort(by: { (item1: ItemData, item2: ItemData) -> Bool in
                        return item1.rank < item2.rank
                    })
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            })
        }
        
        self.lastIndexLoaded += self.itemsToLoad
    }
    
    func viewComments(indexPath: IndexPath) {
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommentsViewController") as! CommentsViewController
//        let data = dataSource[indexPath.row]
//        vc.url = data.url
//        vc.text = data.text
//        vc.commentIDs = data.children
//        self.present(vc, animated: true, completion: nil)
        
        self.performSegue(withIdentifier: "view_comments", sender: indexPath)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "main_cell", for: indexPath) as! MainTableViewCell

        let data = self.dataSource[indexPath.row]
        cell.rankLabel.text = "\(data.rank+1)"
        cell.titleLabel.text = data.title
        cell.urlLabel.text = "(\(data.url?.host ?? "text"))"
        cell.authorTimeLabel.text = "by \(data.author ?? "unknown") \(data.time!.elapsedTimePretty())"
        cell.scoreLabel.text = "\(data.score ?? 0) ▴" // ↑
        cell.commentsLabel.text = "\(data.descendentsCount ?? 0)"
        cell.indexPath = indexPath
        cell.delegate = self
        
        if indexPath.row + 5 >= lastIndexLoaded && !self.loading {
            self.loadNextBatch()
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = self.dataSource[indexPath.row]
        if let url = data.url {
            let safari = SFSafariViewController(url: url as URL)
            self.present(safari, animated: true, completion: nil)
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "view_comments" {
            if let indexPath = sender as? IndexPath {
                let data = self.dataSource[indexPath.row]
                let vc = segue.destination as! CommentsViewController
                vc.story = data
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "view_comments" && !(sender is IndexPath) {
            return false
        }
        
        return true
    }
    
//    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        let action = UITableViewRowAction(style: .default, title: "View Comments") { (action: UITableViewRowAction, indexPath: IndexPath) in
//            print("kek")
//        }
//        
//        action.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
//        
//        return [action]
//    }
//    
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        
//    }
}
