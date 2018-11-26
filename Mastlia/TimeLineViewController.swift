//
//  TimeLineViewController.swift
//  Mastlia
//
//  Created by ymgn on 2018/11/23.
//  Copyright © 2018 ymgn. All rights reserved.
//

import UIKit
import RealmSwift
import MastodonKit

class TimeLineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var user: Account = Account()
    var dataList: [Status] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realm = try! Realm()
        let users = realm.objects(Account.self)
        user = users[0]
        if users.count == 0 {
            performSegue(withIdentifier: "moveLoginView", sender: nil)
            return
        }

        let tootNib = UINib(nibName: "TootCell", bundle: nil)
        tableView.register(tootNib, forCellReuseIdentifier: "TootCell")
        
        reloadListDatas()
    }
    
    func reloadListDatas() {
        let req = Timelines.home(range: .default)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let client = Client(baseURL: "https://" + self.user.domain, accessToken: self.user.accessToken, session: session)
        client.run(req) { result in
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TootCell = tableView.dequeueReusableCell(withIdentifier: "TootCell", for: indexPath) as! TootCell
        let data = dataList[indexPath.row]
        print(data)
        cell.retCount.text = String(data.reblogsCount)
        cell.repCount.text = String(data.mentions.count)
        cell.favCount.text = String(data.favouritesCount)
        cell.tootContent.text = data.content
        cell.userID.text = data.account.username
        cell.userName.text = data.account.displayName
        print(data.account.avatar)
        cell.userImage.setImage(fromUrl: data.account.avatar)
        
        return cell
    }
}

extension UIImageView {
    public func setImage(fromUrl url: String) {
        URLSession.shared.dataTask(with: URLRequest(url: URL(string: url)!)) {(data, response, error) in
            guard let data = data, let _ = response, error == nil else {
                return
            }
            DispatchQueue.main.async(execute: {
                self.image = UIImage(data: data)
            })
        }.resume()
    }
}
