//
//  NotificationViewController.swift
//  Mastlia
//
//  Created by ymgn on 2018/12/05.
//  Copyright © 2018 ymgn. All rights reserved.
//

import UIKit
import MastodonKit
import RealmSwift

class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var dataList: [MastodonKit.Notification] = []
    var user: Account = Account()
    var selectContent: MastodonKit.Notification?
    private weak var refreshControl: UIRefreshControl!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = dataList[indexPath.row]
        if data.type != NotificationType.mention {
            let cell: NotificationCell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
            
            cell.fromUserAvatar.setImage(fromUrl: data.account.avatar)
            if let status = data.status {
                let attributedString = status.content.convertHTML(withFont: UIFont.systemFont(ofSize: 30.0), align: .left)
//                cell.tootContent.attributedText = attributedString
                cell.tootContent.text = attributedString.string
            }
            cell.judge(type: data.type, UserName: data.account.username)
            return cell
        } else {
            let status = data.status
            let cell: TootCell = tableView.dequeueReusableCell(withIdentifier: "TootCell", for: indexPath) as! TootCell
            cell.retCount.text = String(data.status!.reblogsCount)
            cell.repCount.text = String(data.status!.mentions.count)
            cell.favCount.text = String(data.status!.favouritesCount)
            let attributedString = data.status!.content.convertHTML(withFont: UIFont.systemFont(ofSize: 30.0), align: .left)
//            cell.tootContent.attributedText = attributedString
            cell.tootContent.text = attributedString.string
            cell.userID.text = "@" + data.account.username
            cell.userName.text = data.account.displayName
            print(data.account.avatar)
            cell.userImage.setImage(fromUrl: data.account.avatar)
            cell.id = data.status!.id
            cell.user.domain = self.user.domain
            cell.user.accessToken = self.user.accessToken
            cell.isFavorited = data.status!.favourited ?? false
            cell.isRebloged = data.status!.reblogged ?? false
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectContent = dataList[indexPath.row]
        if selectContent != nil {
            if selectContent?.type == NotificationType.follow {
                let userStoryBoard: UIStoryboard = UIStoryboard(name: "User", bundle: nil)
                let userViewController: UserViewController = userStoryBoard.instantiateViewController(withIdentifier: "User") as! UserViewController
                userViewController.account = selectContent?.account
                self.navigationController?.pushViewController(userViewController, animated: true)
            } else {
                let detailStroyBoard: UIStoryboard = UIStoryboard(name: "Detail", bundle: nil)
                let detailViewController: DetailViewController = detailStroyBoard.instantiateViewController(withIdentifier: "Detail") as! DetailViewController
                detailViewController.catchToot = selectContent?.status
                self.navigationController?.pushViewController(detailViewController, animated: true)
            }
        }
    }
    
    func reloadListDatas() {
        let req = Notifications.all()
        var client = Client(baseURL: "https://" + user.domain)
        client.accessToken = user.accessToken
        client.run(req) { result in
            if let notys = result.value {
                self.dataList = notys
                print(notys)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                let controller = UIAlertController(title: nil, message: "通知を取得できませんでした", preferredStyle: .alert)
                controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(controller, animated: true, completion: nil)
                return
            }
        }
        stopPullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
        
        let realm = try! Realm()
        let users = realm.objects(Account.self)
        user = users[0]
        if users.count == 0 {
            performSegue(withIdentifier: "moveLoginView", sender: nil)
            return
        }
        
        let notifyNib = UINib(nibName: "NotificationCell", bundle: nil)
        let tootNib = UINib(nibName: "TootCell", bundle: nil)
        tableView.register(notifyNib, forCellReuseIdentifier: "NotificationCell")
        tableView.register(tootNib, forCellReuseIdentifier: "TootCell")
        initializePullToRefresh()
        reloadListDatas()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func initializePullToRefresh() {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(onPullToRefresh(_:)), for: .valueChanged)
        tableView.addSubview(control)
        refreshControl = control
    }
    
    @objc private func onPullToRefresh(_ sender: AnyObject) {
        reloadListDatas()
    }
    
    private func stopPullToRefresh() {
        if let controller = refreshControl {
            if controller.isRefreshing {
                refreshControl.endRefreshing()
            }
        }
    }

}
