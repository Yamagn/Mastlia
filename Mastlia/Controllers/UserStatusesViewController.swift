//
//  UserStatusesViewController.swift
//  Mastlia
//
//  Created by ymgn on 2019/06/07.
//  Copyright © 2019 ymgn. All rights reserved.
//

import UIKit
import MastodonKit
import RealmSwift

class UserStatusesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var dataList: [Status] = []
    var param: MastodonKit.Account?
    var user: Account = Account()
    var id = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let realm = try! Realm()
        user = realm.objects(Account.self).first!
        let client = Client(baseURL: "https://" + user.domain)
        
        guard let account = param else {
            let controller = UIAlertController(title: nil, message: "投稿を取得できませんでした", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(controller, animated: true, completion: nil)
            return
        }
        id = account.id
        let tootNib = UINib(nibName: "TootCell", bundle: nil)
        tableView.register(tootNib, forCellReuseIdentifier: "TootCell")
        let reblogNib = UINib(nibName: "ReblogCell", bundle: nil)
        tableView.register(reblogNib, forCellReuseIdentifier: "ReblogCell")
        refreshTL()


    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = dataList[indexPath.row]
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
    
    func refreshTL() {
        var client = Client(baseURL: "https://" + user.domain)
        client.accessToken = user.accessToken
        let statusesReq = Accounts.statuses(id: id)
        client.run(statusesReq) { result in
            print(result)
            if let statuses = result.value {
                self.dataList = statuses
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                let controller = UIAlertController(title: nil, message: "タイムラインを取得できませんでした", preferredStyle: .alert)
                controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(controller, animated: true, completion: nil)
                return
            }
        }
    }

}
