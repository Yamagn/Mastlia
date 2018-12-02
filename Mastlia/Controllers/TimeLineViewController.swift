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
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var changeTLButton: UIBarButtonItem!
    private weak var refreshControl: UIRefreshControl!
    
    var user: Account = Account()
    var dataList: [Status] = []
    var isHome: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializePullToRefresh()
        
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
    
    @IBAction func postToot(_ sender: Any) {
        performSegue(withIdentifier: "moveToot", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moveToot" {
            let tootView: TootViewController = segue.destination as! TootViewController
            tootView.user = self.user as Account?
        }
    }
    
    @IBAction func changeTL(_ sender: Any) {
        if isHome {
            isHome = false
            self.navigationItem.title = "Public"
            changeTLButton.image = UIImage(named: "home.png")
            reloadListDatas()
        } else {
            isHome = true
            self.navigationItem.title = "Home"
            changeTLButton.image = UIImage(named: "public.png")
            reloadListDatas()
        }
    }
    
    func reloadListDatas() {
        DispatchQueue.main.async {
            self.indicator.startAnimating()
        }
        let req:Request<[Status]>
        if isHome {
            req = Timelines.home(range: .default)
        } else {
            req = Timelines.public(local: true, range: .default)
        }
        var client = Client(baseURL: "https://" + self.user.domain)
        client.accessToken = user.accessToken
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
        DispatchQueue.main.async {
            self.indicator.stopAnimating()
            self.stopPullToRefresh()
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

extension NSAttributedString {
    static func parseHTML2Text(sourceText text: String) -> NSAttributedString? {
        let encodeData = text.data(using: String.Encoding.utf8, allowLossyConversion: true)
        let attributedOptions = [
            NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html as AnyObject,
            NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue as AnyObject
        ]
        
        var attributedString: NSAttributedString?
        if let encodeData = encodeData {
            do {
                attributedString = try NSAttributedString(data: encodeData, options: attributedOptions, documentAttributes: nil)
            } catch _ {
                
            }
        }
        return attributedString
    }
}

