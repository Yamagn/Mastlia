//
//  UserViewController.swift
//  Mastlia
//
//  Created by ymgn on 2018/12/27.
//  Copyright © 2018 ymgn. All rights reserved.
//

import UIKit
import MastodonKit
import RealmSwift

class UserViewController: UIViewController {
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var avater: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var screenName: UILabel!
    @IBOutlet weak var followCount: UIButton!
    @IBOutlet weak var followersCount: UIButton!
    @IBOutlet weak var note: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var account: MastodonKit.Account?
    var id: String = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let realm = try! Realm()
        let user = realm.objects(Account.self).first!
        let infoReq = Accounts.currentUser()
        var client = Client(baseURL: "https://" + user.domain)
        client.accessToken = user.accessToken
        
        if self.account == nil {
            client.run(infoReq) { result in
                if let account = result.value {
                    DispatchQueue.main.async {
                        self.account = account
                        self.id = account.id
                        self.avater.setImage(fromUrl: account.avatar)
                        self.headerImage.setImage(fromUrl: account.header)
                        self.userName.text = account.displayName
                        self.screenName.text = "@" + account.username
                        self.followCount.setTitle("\(account.followingCount)フォロー", for: .normal)
                        self.followersCount.setTitle("\(account.followersCount)フォロワー", for: .normal)
                        let attributedString = NSAttributedString.parseHTML2Text(sourceText: "<font size=5>" + account.note)
                        self.note.attributedText = attributedString
                    }
                } else {
                    let controller = UIAlertController(title: nil, message: "情報を取得できませんでした", preferredStyle: .alert)
                    controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(controller, animated: true, completion: nil)
                    return
                }
            }
        } else {
            guard let account = self.account else {
                let controller = UIAlertController(title: nil, message: "情報を取得できませんでした", preferredStyle: .alert)
                controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(controller, animated: true, completion: nil)
                return
            }
            self.id = account.id
            self.avater.setImage(fromUrl: account.avatar)
            self.headerImage.setImage(fromUrl: account.header)
            self.userName.text = account.displayName
            self.screenName.text = "@" + account.username
            self.followCount.setTitle("\(account.followingCount)フォロー", for: .normal)
            self.followersCount.setTitle("\(account.followersCount)フォロワー", for: .normal)
            let attributedString = NSAttributedString.parseHTML2Text(sourceText: "<font size=5>" + account.note)
            self.note.attributedText = attributedString
        }
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewStatusesSegue" {
            let userStatusesView: UserStatusesViewController = segue.destination as! UserStatusesViewController
            userStatusesView.param = self.account
        }
    }
    
    
    @IBAction func moveFollowList(_ sender: Any) {
        // TODO: -
    }
    
    @IBAction func moveFollwerList(_ sender: Any) {
        // TODO: -
    }
    @IBAction func viewTweets(_ sender: Any) {
    }
    @IBAction func followUser(_ sender: Any) {
    }
}
