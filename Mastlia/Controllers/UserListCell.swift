//
//  UserListCell.swift
//  Mastlia
//
//  Created by ymgn on 2019/06/08.
//  Copyright © 2019 ymgn. All rights reserved.
//

import UIKit

class UserListCell: UITableViewCell {
    @IBOutlet weak var avater: UIImageView!
    @IBOutlet weak var screenName: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var note: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
