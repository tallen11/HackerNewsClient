//
//  MainTableViewCell.swift
//  HaxorNews
//
//  Created by Tate Allen on 10/18/16.
//  Copyright © 2016 Tate Allen. All rights reserved.
//

import UIKit

protocol MainTableViewCellDelegate {
    func viewComments(indexPath: IndexPath)
}

class MainTableViewCell: UITableViewCell {
    
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var authorTimeLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var commentsContainer: UIView!
    var indexPath: IndexPath!
    var delegate: MainTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tgr = UITapGestureRecognizer(target: self, action: #selector(MainTableViewCell.commentsTapped))
        self.commentsContainer.isUserInteractionEnabled = true
        self.commentsContainer.addGestureRecognizer(tgr)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func commentsTapped(sender: UITapGestureRecognizer) {
        self.delegate?.viewComments(indexPath: self.indexPath)
    }
}
