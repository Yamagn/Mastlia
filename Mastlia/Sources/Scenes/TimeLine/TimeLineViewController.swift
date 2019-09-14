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
    var selectContent: Status? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
        
        let realm = try! Realm()
        
        let users = realm.objects(Account.self)
        if users.isEmpty {
            performSegue(withIdentifier: "moveLoginView", sender: nil)
            return
        }
        user = users[0]
        let tootNib = UINib(nibName: "TootCell", bundle: nil)
        tableView.register(tootNib, forCellReuseIdentifier: "TootCell")
        let reblogNib = UINib(nibName: "ReblogCell", bundle: nil)
        tableView.register(reblogNib, forCellReuseIdentifier: "ReblogCell")
        initializePullToRefresh()
        reloadListDatas()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func postToot(_ sender: Any) {
        performSegue(withIdentifier: "moveToot", sender: nil)
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
        if dataList.isEmpty {
            let controller = UIAlertController(title: nil, message: "タイムラインを取得できませんでした", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(controller, animated: true, completion: nil)
            return UITableViewCell()
        }
        let data = dataList[indexPath.row]
        print(data)
        guard let reblog = data.reblog else {
            let cell: TootCell = tableView.dequeueReusableCell(withIdentifier: "TootCell", for: indexPath) as! TootCell
            cell.retCount.text = String(data.reblogsCount)
            cell.repCount.text = String(data.mentions.count)
            cell.favCount.text = String(data.favouritesCount)
            let attributedString = data.content.convertHTML(withFont: UIFont.systemFont(ofSize: 30.0), align: .left)
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
        let attributedString = reblog.content.convertHTML(withFont: UIFont.systemFont(ofSize: 30.0), align: .left)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectContent = dataList[indexPath.row]
        if selectContent != nil {
            let detailStoryBoard: UIStoryboard = UIStoryboard(name: "Detail", bundle: nil)
            let detaiViewController: DetailViewController = detailStoryBoard.instantiateViewController(withIdentifier: "Detail") as! DetailViewController
            detaiViewController.catchToot = selectContent
            self.navigationController?.pushViewController(detaiViewController, animated: true)
        }
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

extension String {
    func convertHTML(withFont: UIFont? = nil, align: NSTextAlignment = .left) -> NSAttributedString {
        if let data = self.data(using: .utf8, allowLossyConversion: true), let attributedText = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil) {
            let style = NSMutableParagraphStyle()
            style.alignment = align
            
            let fullRange = NSRange(location: 0, length: attributedText.length)
            let mutableAttributeText = NSMutableAttributedString(attributedString: attributedText)
            
            if let font = withFont {
                mutableAttributeText.addAttribute(.paragraphStyle, value: style, range: fullRange)
                mutableAttributeText.enumerateAttribute(.font, in: fullRange, options: .longestEffectiveRangeNotRequired, using: { attribute, range, _ in
                    if let attributeFont = attribute as? UIFont {
                        let traits: UIFontDescriptor.SymbolicTraits = attributeFont.fontDescriptor.symbolicTraits
                        var newDescriptor = attributeFont.fontDescriptor.withFamily(font.familyName)
                        if (traits.rawValue & UIFontDescriptor.SymbolicTraits.traitBold.rawValue) != 0 {
                            newDescriptor = newDescriptor.withSymbolicTraits(.traitBold)!
                        }
                        if (traits.rawValue & UIFontDescriptor.SymbolicTraits.traitItalic.rawValue) != 0 {
                            newDescriptor = newDescriptor.withSymbolicTraits(.traitItalic)!
                        }
                        let scaledFont = UIFont(descriptor: newDescriptor, size: attributeFont.pointSize)
                        mutableAttributeText.addAttribute(.font, value: scaledFont, range: range)
                    }
                })
            }
            return mutableAttributeText
        }
        return NSAttributedString(string: self)
    }
}

