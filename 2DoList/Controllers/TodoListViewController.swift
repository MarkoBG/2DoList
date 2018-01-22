//
//  TodoListViewController.swift
//  2DoList
//
//  Created by Marko Tribl on 12/24/17.
//  Copyright © 2017 Marko Tribl. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework

protocol ItemsCountProvider {
    func updateItemsCount()
}

class TodoListViewController: SwipeTableViewController {
    
    var itemArray = [Item]()
    
    var delegate: ItemsCountProvider?
    
    var storageController: StorageController!
    
    var selectedCategory: Category? {
        didSet {
            //Load items from context - core data
            loadItems()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!

    
    //MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .flatBlueDark
        Appearance.setGradiantColor(for: tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let hexColor = selectedCategory?.color else {return}
        title = selectedCategory!.name
 //       updateNavBar(withHexCode: hexColor)
        searchBar.barTintColor = UIColor(hexString: hexColor)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let items = itemArray.filter({!$0.done})
        updateCategory(itemsCount: Int16(items.count))
    }
    
    //MARK: Setup Nav Bar Methods
    private func updateNavBar(withHexCode hexCodeColorString: String) {
        guard let navBar = navigationController?.navigationBar else {return}
        guard let navBarColor = UIColor(hexString: hexCodeColorString) else {return}
        let contrastColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.barTintColor = navBarColor
        navBar.tintColor = contrastColor
        navBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: contrastColor]
    }
    
    //MARK: TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        //        cell.accessoryType = item.done ? .checkmark : .none
        
        cell.textLabel?.textColor = item.done ? .flatGray : UIColor.flatBlueDark
        cell.tintColor = UIColor.flatBlueDark
        cell.imageView?.image = item.done ? UIImage(named: "checked-icon") : UIImage(named: "unchecked-icon")
        cell.textLabel?.attributedText = item.title?.strikeThroughStyle(item.done)
        cell.imageView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(checkBoxImageTapped(recognizer:))))
        
        return cell
    }

    @objc func checkBoxImageTapped(recognizer: UITapGestureRecognizer) {
        let tapLocation = recognizer.location(in: tableView)
        guard let tapIndexPath = tableView.indexPathForRow(at: tapLocation) else {return}
        itemArray[tapIndexPath.row].done = !itemArray[tapIndexPath.row].done
        storageController.save()
        tableView.reloadData()
        print("ImageView tapped for cell: \(tapIndexPath.row)")
    }
    
    //MARK: TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        // Call method to save changes of specific item of itemArray
//        storageController.save()
//        tableView.reloadData()
        
        // deselect the row when tap on the cell
        
        performSegue(withIdentifier: "itemDetails", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ItemDetailsViewController
        guard let indexPath = tableView.indexPathForSelectedRow else {fatalError()}
        destinationVC.storageController = storageController
        destinationVC.selectedItem = itemArray[indexPath.row]
    }
    
    //MARK: Add New Items
    @IBAction func adduttonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new Todo List Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            let newItem = Item(context: self.storageController.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            
            self.itemArray.append(newItem)
            
            // Call method to save newItem
            self.storageController.save()
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: Model manipulation methods

    func loadItems(with request: NSFetchRequest<NSFetchRequestResult> = Item.fetchRequest(), predicate: NSPredicate? = nil) {

        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)

        if let additionalPredicate = predicate {
            let compaundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
            request.predicate = compaundPredicate
        } else {
            request.predicate = categoryPredicate
        }

        itemArray = storageController.fetchData(with: request)

        tableView.reloadData()
    }
    
    func updateCategory(itemsCount: Int16) {
        let request: NSFetchRequest<NSFetchRequestResult> = Category.fetchRequest()
        let predicate = NSPredicate(format: "name MATCHES %@", selectedCategory!.name!)
        request.predicate = predicate
        
        guard let category: Category = storageController.fetchData(with: request).first else {return}
        category.itemsCount = itemsCount
        storageController.save()
        delegate?.updateItemsCount()
    }
    
    //MARK: Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        storageController.delete(item: itemArray[indexPath.row])
        itemArray.remove(at: indexPath.row)
        tableView.reloadData()
    }
    
    //MARK: Edit Item from swipe
    
    override func editModelItem(at indexPath: IndexPath) {
        var textField = UITextField()
        guard let item = itemArray[indexPath.row].title else {return}
        let alert = UIAlertController(title: "Edit category: \(item)", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Edit", style: .default) { (action) in
            
            self.itemArray[indexPath.row].title = textField.text
            self.storageController.save()
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.text = self.itemArray[indexPath.row].title
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

//MARK: Search bar methods

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request: NSFetchRequest<NSFetchRequestResult> = Item.fetchRequest()
        
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

