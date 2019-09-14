//
//  Account.swift
//  Mastlia
//
//  Created by ymgn on 2018/11/23.
//  Copyright © 2018 ymgn. All rights reserved.
//

import Foundation
import RealmSwift

class Account: RealmSwift.Object{
    @objc dynamic var domain = ""
    @objc dynamic var mail = ""
    @objc dynamic var pass = ""
    @objc dynamic var accessToken = ""
}
