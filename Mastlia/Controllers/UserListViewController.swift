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
    var selectAccount: MastodonKit.Account?
    
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
        let attributedString = NSAttributedString.parseHTML2Text(sourceText: "<b><font size=5>" +  account.note + "</b>")
        cell.note.attributedText = attributedString
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUserDetail" {
            let userInfoView: UserViewController = segue.destination as! UserViewController
            userInfoView.account = selectAccount
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectAccount = accounts[indexPath.row]
        performSegue(withIdentifier: "showUserDetail", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userNib = UINib(nibName: "UserListCell", bundle: nil)
        tableView.register(userNib, forCellReuseIdentifier: "UserListCell")
        tableView.reloadData()
    }

}
