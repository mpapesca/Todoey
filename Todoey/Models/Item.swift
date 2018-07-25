//
//  Item.swift
//  Todoey
//
//  Created by Michael on 7/22/18.
//  Copyright © 2018 michael papesca. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    var category = LinkingObjects(fromType: Category.self, property: "items")
}
