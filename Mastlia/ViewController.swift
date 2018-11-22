//
//  ViewController.swift
//  Mastlia
//
//  Created by ymgn on 2018/11/22.
//  Copyright © 2018 ymgn. All rights reserved.
//

import UIKit
import MastodonKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func registButton(_ sender: Any) {
        let client = Client(baseURL: "https://mstdn.maud.io")
        
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


}

