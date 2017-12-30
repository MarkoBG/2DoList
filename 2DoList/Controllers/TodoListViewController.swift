//
//  TodoListViewController.swift
//  2DoList
//
//  Created by Marko Tribl on 12/24/17.
//  Copyright © 2017 Marko Tribl. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    var selectedCategory: Category? {
        didSet {
            //Load items from context - core data
            loadItems()
        }
    }
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    //MARK: TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }

    //MARK: TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        // Call method to save changes of specific item of itemArray
        saveItems()
        
       
        
        // deselect the row when tap on the cell
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: Add New Items
    @IBAction func adduttonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Todo List Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            
            self.itemArray.append(newItem)
            
            // Call method to save newItem
            self.saveItems()

        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: Model manipulation methods
    func saveItems() {
        
        do {
           try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {

        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)

        if let additionalPredicate = predicate {
            let compaundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
            request.predicate = compaundPredicate
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
           itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }

        tableView.reloadData()
        
    }
    
    func deleteItem(item: Int) {
        
        context.delete(itemArray[item])
        itemArray.remove(at: item)

    }
}

//MARK: Search bar methods

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        //pravimo objekat "predicate" koji ce da izvrsi pretragu, prema tekstu koji unesemo u search bar
        //pretraga se vrsi tako sto se poredi da li tekst koji smo uneli se sadrzi u propertiju "title"
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.predicate = predicate
       
        //pravimo objekat "sortDescriptor" koji ce da sortira rezultate pretrage
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        
        request.sortDescriptors = [sortDescriptor]
        
        loadItems(with: request, predicate: predicate)
    }
    
    //Zelimo da kad se izbrise tekst iz search bara da se vratimo u prvobitno stanje
    //odnosno da se prikazu svi clanovi niza
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            
            loadItems()
            
            //kad se izbrise tekst iz search bara, vracamo se u prvobitno stanje, pre klika na search bar
            //odnosno search bar vise nije selektovan i keyboard nestaje sa ekrana
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
