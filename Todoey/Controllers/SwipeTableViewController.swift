//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by Michael on 7/22/18.
//  Copyright © 2018 michael papesca. All rights reserved.
//

import UIKit
import SwipeCellKit
import ChameleonFramework

class SwipeTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        tableView.backgroundColor = FlatBlack()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        
        return cell
    }
    
    func swipeCellWasDeleted(at indexPath: IndexPath) {
    }
    
}


// MARK: - SwipeCell Delegate Extension
extension SwipeTableViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            
            self.swipeCellWasDeleted(at: indexPath)
            
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
    
}
