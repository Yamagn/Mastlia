//
//  TootCell.swift
//  Mastlia
//
//  Created by ymgn on 2018/11/23.
//  Copyright © 2018 ymgn. All rights reserved.
//

import UIKit

class TootCell: UITableViewCell {
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userID: UILabel!
    @IBOutlet weak var tootContent: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var repCount: UILabel!
    @IBOutlet weak var retCount: UILabel!
    @IBOutlet weak var favCount: UILabel!
    @IBAction func onReplyTapped(_ sender: Any) {
    }
    @IBAction func onBoostTapped(_ sender: Any) {
    }
    @IBAction func onFavTapped(_ sender: Any) {
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
