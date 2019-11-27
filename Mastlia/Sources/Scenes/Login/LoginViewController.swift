//
//  LoginViewController.swift
//  Mastlia
//
//  Created by ymgn on 2018/11/23.
//  Copyright © 2018 ymgn. All rights reserved.
//

import UIKit
import MastodonKit
import RealmSwift
import SVProgressHUD

class LoginViewController: UIViewController {
    @IBOutlet weak var domain: UITextField!
    @IBOutlet weak var mail: UITextField!
    @IBOutlet weak var pass: UITextField!
    var responseJson = Dictionary<String, AnyObject>()
    var user: Account = Account()
    
    @IBAction func onLoginButtonTapped(_ sender: Any) {
        SVProgressHUD.show()
        if domain.text == nil || mail.text == nil || pass.text == nil {
            SVProgressHUD.dismiss()
            let controller = UIAlertController(title: nil, message: "正しく入力してください", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(controller, animated: true, completion: nil)
        }
        
        let domainText = domain.text!
        let mailText = mail.text!
        let passText = pass.text!
        let client = Client(baseURL: "https://" + domainText)
        
        let request = Clients.register(clientName: "Mastlia", scopes: [.read, .write, .follow], website: "https://github.com/MastodonKit/MastodonKit")
        client.run(request) { result in
            guard let application = result.value else {
                SVProgressHUD.dismiss()
                let controller = UIAlertController(title: nil, message: "入力された内容が正しくありませんでした", preferredStyle: .alert)
                controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(controller, animated: true, completion: nil)
                return
            }
            let loginRequest = Login.silent(clientID: application.clientID, clientSecret: application.clientSecret, scopes: [.read, .write, .follow], username: mailText, password: passText)
            client.run(loginRequest) { result in
                if let loginSettings = result.value {
                    DispatchQueue.main.async {
                        self.user.domain = domainText
                        self.user.mail = mailText
                        self.user.pass = passText
                        self.user.accessToken = loginSettings.accessToken
                        self.save(user: self.user)
                        SVProgressHUD.dismiss()
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    func save(user: Account) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(user)
            }
        } catch {
            SVProgressHUD.dismiss()
            let controller = UIAlertController(title: nil, message: "エラーが発生しました", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
