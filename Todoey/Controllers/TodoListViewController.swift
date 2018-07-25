//
//  ViewController.swift
//  Todoey
//
//  Created by Michael on 7/14/18.
//  Copyright © 2018 michael papesca. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {

    
    // MARK: - Class Variables
    let realm = try! Realm()
    var items: Results<Item>?
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var addButton: UIBarButtonItem!
    var textField = UITextField()
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    // MARK: - Standard Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor(hexString: selectedCategory!.color!)?.darken(byPercentage: 100.0)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let colorHexCode = selectedCategory?.color else { fatalError() }
        
        updateNavBar(withHexCode: colorHexCode)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withHexCode: "1D9BF6")
    }
    
    func updateNavBar(withHexCode colorHexCode: String) {
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller Does Not Exist!")}
        guard let navBarColor = UIColor(hexString: colorHexCode) else { fatalError() }
        let foregroundColor = ContrastColorOf(navBarColor, returnFlat: true)
        
        // Set background colors
        navBar.barTintColor = navBarColor
        searchBar.barTintColor = navBarColor
        
        // Set foreground colors
        navBar.tintColor = foregroundColor
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: foregroundColor]
        navBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: foregroundColor]
        addButton.tintColor = foregroundColor
        
        
    }
    
    //MARK: - UITableView Data Source Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = self.items?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            
            let percent = CGFloat(indexPath.row+1)/CGFloat(self.items!.count+2)
            
            cell.backgroundColor = UIColor(hexString: selectedCategory!.color!)?.darken(byPercentage: percent)
            cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        } else {
            cell.textLabel?.text = "No items added yet..."
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    
    
    // MARK: - UITableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = items?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error updating item done attribute: \(error)")
            }
        }
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    // MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {

        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // User clicked add item button on UIAlert
            
            if let category = self.selectedCategory {
                do {
                try self.realm.write {
                    let newItem = Item()
                    newItem.title = self.textField.text!
                    newItem.dateCreated = Date() 
                    category.items.append(newItem)
                }
                }catch {
                    print("Error saving item: \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "New Item..."
            self.textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - Persistent Data Methods
    
    func save(item: Item) {

        do {
            try realm.write{
                realm.add(item)
            }
        } catch {
            print("Error saving context: \(error)")
        }

    }
    
    func loadItems() {
        
        if let category = selectedCategory {
            items = category.items.sorted(byKeyPath: "title", ascending: true)
        }

        tableView.reloadData()

    }
    
    // MARK: - SwipeTableViewController Override Functions
    
    override func swipeCellWasDeleted(at indexPath: IndexPath) {
        super.swipeCellWasDeleted(at: indexPath)
        if let item = self.items?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(item)
                }
            } catch {
                print("Error deleting item: \(error)")
            }
        }
    }
    
}

// MARK: - Searchbar Delegate Extension
extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        items = items?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if (searchBar.text!.count <= 0) {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
        
    }
    
}
