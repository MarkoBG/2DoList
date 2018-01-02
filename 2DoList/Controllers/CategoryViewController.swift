//
//  CategoryViewController.swift
//  2DoList
//
//  Created by Marko Tribl on 12/27/17.
//  Copyright © 2017 Marko Tribl. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework


class CategoryViewController: SwipeTableViewController {
    
    var categories = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .white
        tableView.separatorStyle = .none
        loadCategories()
    }

    //MARK: TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        cell.detailTextLabel?.text = "(" + String(categories[indexPath.row].itemsCount) + ")"
        
        guard let hexColor = UIColor(hexString: categories[indexPath.row].color ?? "18AEFF") else {fatalError()}
        cell.backgroundColor = hexColor
        cell.textLabel?.textColor = ContrastColorOf(hexColor, returnFlat: true)
        cell.detailTextLabel?.textColor = ContrastColorOf(hexColor, returnFlat: true)
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
        destinationVC.selectedCategory = categories[indexPath.row]
        destinationVC.delegate = self
    }
    
    
    //MARK: Data Manipulation Methods
    
    func saveCategories() {
        do {
            try context.save()
        } catch {
            print("Error saving categories: \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error fetchnig from context: \(error)")
        }
        
        tableView.reloadData()
    }
    
    func updateCategory(at indexPath: IndexPath) {
        
    }
    
    //MARK: Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {

        context.delete(categories[indexPath.row])
        categories.remove(at: indexPath.row)
        
        saveCategories()
    }
    
    //MARK: Edit Category from Swipe
    override func editModelItem(at indexPath: IndexPath) {
        var textField = UITextField()
        guard let category = categories[indexPath.row].name else {return}
        let alert = UIAlertController(title: "Edit category: \(category)", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Edit", style: .default) { (action) in
            
            self.categories[indexPath.row].name = textField.text
            self.saveCategories()
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
            
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat.hexValue()
            newCategory.itemsCount = 0
            self.categories.append(newCategory)
            
            self.saveCategories()
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

