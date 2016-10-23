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
    
    private let storyLoader = StoryLoader()
    private var dataSource = [ItemData]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Avenir Next", size: 20)!]
        self.navigationController?.navigationBar.topItem?.title = "Hacker News"
        self.navigationController?.view.backgroundColor = UIColor.white
        self.tableView.alpha = 0.0
        self.refreshControl?.addTarget(self, action: #selector(MainTableViewController.refreshStories), for: .valueChanged)
        
        self.storyLoader.loadTopStoriesShallow { (storiesLoaded: Int) in
            self.storyLoader.loadNextBatch(onFinished: { (items: [ItemData]) in
                DispatchQueue.main.async {
                    self.dataSource.removeAll(keepingCapacity: true)
                    self.dataSource.append(contentsOf: items)
                    self.tableView.reloadData()
                    self.tableView.fadeIn(duration: 0.25, delay: 0.0, completion: nil)
                }
            })
        }
    }
    
    func refreshStories() {
        self.tableView.fadeOut(duration: 0.25, delay: 0.0) { (finished: Bool) in
            self.storyLoader.refreshTopStories(onFinished: { (items: [ItemData]) in
                DispatchQueue.main.async {
                    self.dataSource.removeAll(keepingCapacity: true)
                    self.dataSource.append(contentsOf: items)
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                    self.tableView.fadeIn(duration: 0.25, delay: 0.0, completion: nil)
                }
            })
        }
    }
    
    func viewComments(indexPath: IndexPath) {
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
        return self.dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "main_cell", for: indexPath) as! MainTableViewCell

        let data = self.dataSource[indexPath.row]
        cell.rankLabel.text = "\(data.rank)"
        cell.titleLabel.text = data.title ?? "Error loading..."
        cell.urlLabel.text = "(\(data.url?.host ?? "text story"))"
        cell.authorTimeLabel.text = "by \(data.author ?? "unknown") \(data.time?.elapsedTimePretty() ?? "")"
        cell.scoreLabel.text = "\(data.score ?? 0) ▴" //
        cell.commentsLabel.text = "\(data.descendentsCount ?? 0)"
        cell.indexPath = indexPath
        cell.delegate = self
        
        if self.storyLoader.shouldLoadNextBatch(row: indexPath.row, buffer: 5) {
            self.storyLoader.loadNextBatch(onFinished: { (items: [ItemData]) in
                DispatchQueue.main.async {
                    self.dataSource.removeAll(keepingCapacity: true)
                    self.dataSource.append(contentsOf: items)
                    self.tableView.reloadData()
                }
            })
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68.0
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "view_comments" {
            if let indexPath = sender as? IndexPath {
                let data = self.dataSource[indexPath.row]
                let vc = segue.destination as! CommentsViewController
                vc.story = ItemData(other: data)
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
