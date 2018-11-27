//
//  APIController.swift
//  Mastlia
//
//  Created by ymgn on 2018/11/27.
//  Copyright © 2018 ymgn. All rights reserved.
//

import Foundation
import RealmSwift
import MastodonKit

class APIController {
    let user: Account
    var domain: String = ""
    func getTL() {
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
    init(user: Account) {
        self.user = user
        self.domain = user.domain
    }
}
