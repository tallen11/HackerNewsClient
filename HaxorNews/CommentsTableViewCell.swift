//
//  CommentsTableViewCell.swift
//  HaxorNews
//
//  Created by Tate Allen on 10/19/16.
//  Copyright © 2016 Tate Allen. All rights reserved.
//

import UIKit

class CommentsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var infoIndexContraint: NSLayoutConstraint!
    @IBOutlet weak var contentIndexContraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setIndent(level: Int) {
        if level == 1 {
            infoIndexContraint.constant = 8
            contentIndexContraint.constant = 8
        } else {
            let indent = level * 20
            infoIndexContraint.constant = CGFloat(indent)
            contentIndexContraint.constant = CGFloat(indent)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
