//
//  Category.swift
//  Todoey
//
//  Created by Michael on 7/22/18.
//  Copyright © 2018 michael papesca. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var color: String?
    let items = List<Item>()
}
