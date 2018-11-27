//
//  TootCell.swift
//  Mastlia
//
//  Created by ymgn on 2018/11/23.
//  Copyright © 2018 ymgn. All rights reserved.
//

import UIKit
import MastodonKit
import RealmSwift

class TootCell: UITableViewCell {
    var user: Account = Account()
    var config = URLSessionConfiguration.default
    var session = URLSession()
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
    var id: String = ""
    @IBAction func onReplyTapped(_ sender: Any) {
    }
    @IBAction func onBoostTapped(_ sender: Any) {
        initialize()
        let client = Client(baseURL: "https://" + user.domain, accessToken: user.accessToken, session: session)
        let req = Statuses.reblog(id: id)
        client.run(req) { result in
            if let res = result.value {
                DispatchQueue.main.async {
                    self.retweetButton.tintColor = UIColor.green
                }
                print(res)
                return
            } else {
                return
            }
        }
    }
    @IBAction func onFavTapped(_ sender: Any) {
        initialize()
        let req = Statuses.favourite(id: id)
        let client = Client(baseURL: "https://" + user.domain, accessToken: user.accessToken, session: session)
        client.run(req) { result in
            if let res = result.value {
                DispatchQueue.main.async {
                    self.starButton.tintColor = UIColor.yellow
                }
                print(res)
                return
            } else {
                return
            }
        }
    }
    
    func initialize() {
        let realm: Realm = try! Realm()
        let users = realm.objects(Account.self)
        self.user = users[0]
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
