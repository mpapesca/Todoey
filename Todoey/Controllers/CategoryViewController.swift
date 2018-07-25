//
//  TableViewController.swift
//  Todoey
//
//  Created by Michael on 7/19/18.
//  Copyright © 2018 michael papesca. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {

    
    // MARK: - Class Variables
    let realm = try! Realm()
    var categories: Results<Category>?
    @IBOutlet weak var searchBar: UISearchBar!
    var textField = UITextField()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       //tableView.rowHeight = 80.0
         loadCategories()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        
//        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller Does Not Exist!")}
//        
//        guard let navBarColor = UIColor(hexString: "1D9BF6") else { fatalError() }
//        
//        navBar.barTintColor = navBarColor
//        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
//        
//        searchBar.barTintColor = navBar.barTintColor
//        
//    }

    //MARK: - UITableView Data Source Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let topVisibleIndexPath: IndexPath = self.tableView.indexPathsForVisibleRows![0]
        print(topVisibleIndexPath.row)
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = self.categories?[indexPath.row] {
            cell.textLabel?.text = category.name
            cell.backgroundColor = UIColor(hexString: category.color!)
            cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        } else {
            cell.textLabel?.text = "No categories added yet..."
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    // MARK: - UITableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "GoToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    
    // MARK: - Add New Items

    @IBAction func addButtonClicked(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            // User clicked add item button on UIAlert
            
            
            let newCategory = Category()
            newCategory.name = self.textField.text!
            newCategory.color = RandomFlatColor().hexValue()
            
            self.save(category: newCategory)
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "New Category..."
            self.textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - Persistent Data Methods
    
    func save(category: Category) {

        do {
            try realm.write{
                realm.add(category)
            }
        } catch {
            print("Error saving context: \(error)")
        }

    }
    
    func loadCategories() {

        categories = realm.objects(Category.self)
        
        tableView.reloadData()

    }
    
    // MARK: - SwipeTableViewController Override Functions
    
    override func swipeCellWasDeleted(at indexPath: IndexPath) {
        super.swipeCellWasDeleted(at: indexPath)
        if let category = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(category)
                }
            } catch {
                print("Error deleting category: \(error)")
            }
        }
    }
    
}

// MARK: - Searchbar Delegate Extension
extension CategoryViewController: UISearchBarDelegate {
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if let currentCategories = categories {
            categories = currentCategories.filter("name MATCHES %@", searchBar.text!)
        }
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchBar.text!.count <= 0) {
            loadCategories()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    
}
