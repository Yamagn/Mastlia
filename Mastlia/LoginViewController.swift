//
//  LoginViewController.swift
//  Mastlia
//
//  Created by ymgn on 2018/11/23.
//  Copyright © 2018 ymgn. All rights reserved.
//

import UIKit
import MastodonKit

class LoginViewController: UIViewController {
    @IBOutlet weak var domain: UITextField!
    @IBOutlet weak var mail: UITextField!
    @IBOutlet weak var pass: UITextField!
    var responseJson = Dictionary<String, AnyObject>()
    
    @IBAction func onLoginButtonTapped(_ sender: Any) {
        if domain == nil {
            let controller = UIAlertController(title: nil, message: "正しく入力してください", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(controller, animated: true, completion: nil)
        }
        let client = Client(baseURL: "https://" + domain.text!)
        
        let request = Clients.register(clientName: "Mastlia", scopes: [.read, .write, .follow], website: "https://github.com/MastodonKit/MastodonKit")
        client.run(request) { result in
            if let application = result.value {
                print("id: \(application.id)")
                print("redirect uri: \(application.redirectURI)")
                print("client id: \(application.clientID)")
                print("client secret: \(application.clientSecret)")
            }
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
