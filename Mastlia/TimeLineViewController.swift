//
//  TimeLineViewController.swift
//  Mastlia
//
//  Created by ymgn on 2018/11/23.
//  Copyright © 2018 ymgn. All rights reserved.
//

import UIKit

class TimeLineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var dataList: [Toots] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        let tootNib = UINib(nibName: "TootCell", bundle: nil)
        tableView.register(tootNib, forCellReuseIdentifier: "TootCell")
        
        reloadListDatas()
    }
    
    func reloadListDatas() {
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TootCell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! TootCell
        
        let data = dataList[indexPath.row]
        cell.retCount.text = String(data.reblogs_count)
        cell.repCount.text = String(data.replies_count)
        cell.favCount.text = String(data.favorites_count)
        cell.tootContent.text = data.content
        cell.userID.text = data.account.username
        cell.userName.text = data.account.display_name
        cell.userImage.setImage(fromUrl: data.account.avatar)
        
        return cell
    }
}

extension UIImageView {
    public func setImage(fromUrl url: URL) {
        URLSession.shared.dataTask(with: URLRequest(url: url)) {(data, response, error) in
            guard let data = data, let _ = response, error == nil else {
                return
            }
            DispatchQueue.main.async(execute: {
                self.image = UIImage(data: data)
            })
        }.resume()
    }
}
