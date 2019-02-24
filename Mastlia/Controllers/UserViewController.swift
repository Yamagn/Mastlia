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

class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var avater: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var screenName: UILabel!
    @IBOutlet weak var followCount: UIButton!
    @IBOutlet weak var followersCount: UIButton!
    @IBOutlet weak var note: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var user = Account()
    var dataList: [Status] = []
    var id: String = ""
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var data = dataList[indexPath.row]
        print(data)
        guard let reblog = data.reblog else {
            let cell: TootCell = tableView.dequeueReusableCell(withIdentifier: "TootCell", for: indexPath) as! TootCell
            cell.retCount.text = String(data.reblogsCount)
            cell.repCount.text = String(data.mentions.count)
            cell.favCount.text = String(data.favouritesCount)
            //        cell.tootContent.text = data.content
            let attributedString = NSAttributedString.parseHTML2Text(sourceText: "<b><font size=5>" + data.content + "</b>")
            cell.tootContent.attributedText = attributedString
            cell.userID.text = "@" + data.account.username
            cell.userName.text = data.account.displayName
            print(data.account.avatar)
            cell.userImage.setImage(fromUrl: data.account.avatar)
            cell.id = data.id
            cell.user.domain = self.user.domain
            cell.user.accessToken = self.user.accessToken
            cell.isFavorited = data.favourited ?? false
            cell.isRebloged = data.reblogged ?? false
            cell.judge()
            
            return cell
        }
        let cell: ReblogCell = tableView.dequeueReusableCell(withIdentifier: "ReblogCell", for: indexPath) as! ReblogCell
        
        cell.reblogedUser.text = data.account.username + "さんがブーストしました"
        cell.retCount.text = String(reblog.reblogsCount)
        cell.repCount.text = String(reblog.mentions.count)
        cell.favCount.text = String(reblog.favouritesCount)
        //        cell.tootContent.text = data.content
        let attributedString = NSAttributedString.parseHTML2Text(sourceText: "<b><font size=5>" + reblog.content + "</b>")
        cell.tootContent.attributedText = attributedString
        cell.userID.text = "@" + reblog.account.username
        cell.userName.text = reblog.account.displayName
        print(reblog.account.avatar)
        cell.userImage.setImage(fromUrl: reblog.account.avatar)
        cell.id = reblog.id
        cell.user.domain = self.user.domain
        cell.user.accessToken = self.user.accessToken
        cell.isFavorited = reblog.favourited ?? false
        cell.isRebloged = reblog.reblogged ?? false
        cell.judge()
        
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tootNib = UINib(nibName: "TootCell", bundle: nil)
        tableView.register(tootNib, forCellReuseIdentifier: "TootCell")
        let reblogNib = UINib(nibName: "ReblogCell", bundle: nil)
        tableView.register(reblogNib, forCellReuseIdentifier: "ReblogCell")
        
        let realm = try! Realm()
        let users = realm.objects(Account.self)
        user = users[0]
        
        let infoReq = Accounts.currentUser()
        var client = Client(baseURL: "https://" + user.domain)
        client.accessToken = user.accessToken
        
        client.run(infoReq) { result in
            if let account = result.value {
                DispatchQueue.main.async {
                    self.id = account.id
                    self.avater.setImage(fromUrl: account.avatar)
                    self.headerImage.setImage(fromUrl: account.header)
                    self.userName.text = account.displayName
                    self.screenName.text = "@" + account.username
                    self.followCount.setTitle("\(account.followingCount)フォロー", for: .normal)
                    self.followersCount.setTitle("\(account.followersCount)フォロワー", for: .normal)
                    let attributedString = NSAttributedString.parseHTML2Text(sourceText: "<font size=5>" + account.note)
                    self.note.attributedText = attributedString
                    let statusesReq = Accounts.statuses(id: account.id)
                    client.run(statusesReq) { result in
                        print(result)
                        if let statuses = result.value {
                            self.dataList = statuses
                        } else {
                            DispatchQueue.main.async {
                                let controller = UIAlertController(title: nil, message: "タイムラインを取得できませんでした", preferredStyle: .alert)
                                controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                                self.present(controller, animated: true, completion: nil)
                                return
                            }
                        }
                    }
                    self.tableView.reloadData()
                }
            } else {
                let controller = UIAlertController(title: nil, message: "情報を取得できませんでした", preferredStyle: .alert)
                controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(controller, animated: true, completion: nil)
                return
            }
        }
        // Do any additional setup after loading the view.
    }
    
    func refreshTL() {
        print(id)
        var client = Client(baseURL: "https://" + user.domain)
        client.accessToken = user.accessToken
        let statusesReq = Accounts.statuses(id: id)
        client.run(statusesReq) { result in
            print(result)
            if let statuses = result.value {
                self.dataList = statuses
            } else {
                let controller = UIAlertController(title: nil, message: "タイムラインを取得できませんでした", preferredStyle: .alert)
                controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(controller, animated: true, completion: nil)
                return
            }
        }
        tableView.reloadData()
    }
    
    @IBAction func moveFollowList(_ sender: Any) {
        // TODO: -
    }
    
    @IBAction func moveFollwerList(_ sender: Any) {
        // TODO: -
    }
}
