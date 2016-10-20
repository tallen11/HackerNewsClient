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
        
        HNDataLoader.instance.loadTopLevelComments(item: self.story!) {
            for comment in self.story!.children! {
                self.dataSource.append((item: comment, level: 1))
            }
            
            self.dataSource.sort(by: { (data1: (item: ItemData, level: Int), data2: (item: ItemData, level: Int)) -> Bool in
                return data1.item.rank < data2.item.rank
            })
            
            DispatchQueue.main.async {
                self.commentsTableView.reloadSections([0], with: .fade)
                // self.commentsTableView.reloadData()
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
            cell.timeLabel.text = data.time!.elapsedTimePretty()
            do {
                let str = (data.text ?? "error loading...") + String(format: "<style>body{font-family: '%@'; font-size:%fpx;}</style>", cell.contentLabel.font.fontName, cell.contentLabel.font.pointSize)
                let htmlText = try NSAttributedString(data: str.data(using: String.Encoding.unicode, allowLossyConversion: true)!, options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
                cell.contentLabel.attributedText = htmlText
            } catch {
                cell.contentLabel.text = data.text ?? "error loading..."
            }
            
            cell.setIndent(level: level)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.loadSubComments(parentIndexPath: indexPath)
    }
    
    private func loadSubComments(parentIndexPath: IndexPath) {
        let item = self.dataSource[parentIndexPath.row].item
        let level = self.dataSource[parentIndexPath.row].level
        let ip = IndexPath(row: parentIndexPath.row, section: parentIndexPath.section)
        HNDataLoader.instance.loadTopLevelComments(item: item) {
            for sub in item.children!.reversed() {
                self.dataSource.insert((item: sub, level: level + 1), at: ip.row + 1)
                self.commentsTableView.beginUpdates()
                self.commentsTableView.insertRows(at: [IndexPath(row: ip.row + 1, section: 0)], with: .automatic)
                self.commentsTableView.endUpdates()
            }
        }
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let data = self.dataSource[indexPath.row]
//        let font = UIFont(name: "Avenir Next", size: 12.0)
//        let text = (data.item.text ?? "") as NSString
//        var height: CGFloat = text.boundingRect(with: CGSize(width: tableView.frame.size.width, height: 100), options: ([.usesLineFragmentOrigin, .usesFontLeading]), attributes: [NSFontAttributeName: font], context: nil).size.height
//        return height + 10.0
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68.0
    }
    /*
     -(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
     {
     UIFont * font = [UIFont systemFontOfSize:15.0f];
     NSString *text = [getYourTextArray objectAtIndex:indexPath.row];
     CGFloat height = [text boundingRectWithSize:CGSizeMake(self.tableView.frame.size.width, maxHeight) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName: font} context:nil].size.height;
     
     return height + additionalHeightBuffer;
     }
    */
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
