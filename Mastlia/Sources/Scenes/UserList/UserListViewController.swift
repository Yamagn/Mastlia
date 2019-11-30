//
//  UserListViewController.swift
//  Mastlia
//
//  Created by ymgn on 2019/06/08.
//  Copyright © 2019 ymgn. All rights reserved.
//

import UIKit
import MastodonKit

class UserListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var accounts: [MastodonKit.Account] = []
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let account = accounts[indexPath.row]
        let cell: UserListCell = tableView.dequeueReusableCell(withIdentifier: "UserListCell", for: indexPath) as! UserListCell
        cell.avater.setImage(fromUrl: account.avatar)
        cell.screenName.text = account.displayName
        cell.userName.text = "@" + account.username
        let attributedString = account.note.convertHTML(withFont: UIFont.systemFont(ofSize: 20.0), align: .left)
//        cell.note.attributedText = attributedString
        cell.note.text = attributedString.string
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let userStoryBoard: UIStoryboard = UIStoryboard(name: "User", bundle: nil)
        let userViewController: UserViewController = userStoryBoard.instantiateViewController(withIdentifier: "User") as! UserViewController
        userViewController.account = accounts[indexPath.row]
        self.navigationController?.pushViewController(userViewController, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let userNib = UINib(nibName: "UserListCell", bundle: nil)
        tableView.register(userNib, forCellReuseIdentifier: "UserListCell")
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
