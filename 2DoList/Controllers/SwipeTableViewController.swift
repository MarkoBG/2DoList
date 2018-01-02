//
//  SwipeTableViewController.swift
//  2DoList
//
//  Created by Marko Tribl on 12/30/17.
//  Copyright © 2017 Marko Tribl. All rights reserved.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

         tableView.rowHeight = 65.0
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else {return nil}
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in

            self.updateModel(at: indexPath)
            
        }
        
        let editAction = SwipeAction(style: .default, title: "Edit") { (action, indexPath) in
            
            self.editModelItem(at: indexPath)
            
        }
        
        //customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")
        editAction.image = UIImage(named: "editItemFilled-icon")
        editAction.backgroundColor = .blue
        
        
        return [deleteAction, editAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive(automaticallyDelete: false)
   //     options.expansionStyle = .destructiveAfterFill
        
        return options
    }
    
    func updateModel(at indexPath: IndexPath) {
        //Update our data model
        
    }
    
    func editModelItem(at indexPath: IndexPath) {
        //Edit item in model
    }


}
