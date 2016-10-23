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
    var dataSource = [(item: ItemData, level: Int)]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Avenir Next", size: 20)!]
        self.navigationItem.title = "Comments"
        self.commentsTableView.alpha = 0.0
        
        HNDataLoader.loadTopLevelComments(item: self.story!) {
            for comment in self.story!.children! {
                self.dataSource.append((item: comment, level: 1))
            }
            
            self.dataSource.sort(by: { (data1: (item: ItemData, level: Int), data2: (item: ItemData, level: Int)) -> Bool in
                return data1.item.rank < data2.item.rank
            })
            
            DispatchQueue.main.async {
                // self.commentsTableView.reloadSections([0], with: .bottom)
                self.commentsTableView.reloadData()
                self.commentsTableView.fadeIn(duration: 0.25, delay: 0.0, completion: nil)
            }
        }
        
        // self.commentsTableView.rowHeight = UITableViewAutomaticDimension
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
        
        let data = self.dataSource[indexPath.row].item
        let level = self.dataSource[indexPath.row].level
        if let deleted = data.deleted, deleted {
            cell.infoLabel.text = "[deleted]"
            cell.timeLabel.text = ""
            cell.contentLabel.text = ""
        } else {
            cell.infoLabel.text = "\(data.author ?? "unknown")"
            cell.timeLabel.text = "\(data.time!.elapsedTimePretty()) ago"
            cell.contentLabel.attributedText = data.text ?? NSAttributedString(string: "error loading...")
        }
        
        cell.setIndent(level: level)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.loadSubComments(parentIndexPath: indexPath)
        self.commentsTableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func loadSubComments(parentIndexPath: IndexPath) {
        let item = self.dataSource[parentIndexPath.row].item
        let level = self.dataSource[parentIndexPath.row].level
        let ip = IndexPath(row: parentIndexPath.row, section: parentIndexPath.section)
        HNDataLoader.loadTopLevelComments(item: item) {
            for sub in item.children!.reversed() {
                self.dataSource.insert((item: sub, level: level + 1), at: ip.row + 1)
                self.commentsTableView.beginUpdates()
                self.commentsTableView.insertRows(at: [IndexPath(row: ip.row + 1, section: 0)], with: .bottom)
                self.commentsTableView.endUpdates()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68.0
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
