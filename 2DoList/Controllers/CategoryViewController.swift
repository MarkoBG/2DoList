//
//  CategoryViewController.swift
//  2DoList
//
//  Created by Marko Tribl on 12/27/17.
//  Copyright © 2017 Marko Tribl. All rights reserved.
//

import UIKit
import ChameleonFramework


class CategoryViewController: SwipeTableViewController {
    
    var categories = [Category]()

    var storageController: StorageController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarStyle(UIStatusBarStyleContrast)
        tableView.separatorStyle = .none
 
        categories = storageController.fetchData()
    }

    //MARK: TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        cell.detailTextLabel?.text = "(" + String(categories[indexPath.row].itemsCount) + ")"
        
        cell.textLabel?.textColor = UIColor.flatBlueDark
        cell.detailTextLabel?.textColor = UIColor.flatBlueDark
        return cell
    }
    
    //MARK: TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    //MARK: Prepare for segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        guard let indexPath = tableView.indexPathForSelectedRow else {return}
        destinationVC.storageController = storageController
        destinationVC.selectedCategory = categories[indexPath.row]
        destinationVC.delegate = self
    }

    //MARK: Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {

        storageController.delete(item: categories[indexPath.row])
        categories.remove(at: indexPath.row)
        tableView.reloadData()
    }
    
    //MARK: Edit Category from Swipe
    override func editModelItem(at indexPath: IndexPath) {
        var textField = UITextField()
        guard let category = categories[indexPath.row].name else {return}
        let alert = UIAlertController(title: "Edit category: \(category)", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Edit", style: .default) { (action) in
            
            self.categories[indexPath.row].name = textField.text
            self.storageController.save()
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.text = self.categories[indexPath.row].name
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: Add New Categories
   
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add category", style: .default) { (action) in
            
            let newCategory = Category(context: self.storageController.context)
            newCategory.name = textField.text!
            newCategory.color = UIColor.flatMint.hexValue()
            newCategory.itemsCount = 0
            self.categories.append(newCategory)
            
            self.storageController.save()
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add New Category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
}

//MARK: Implement Protocol ItemsCountProvider

extension CategoryViewController: ItemsCountProvider {
    
    func updateItemsCount() {
        tableView.reloadData()
    }
}

