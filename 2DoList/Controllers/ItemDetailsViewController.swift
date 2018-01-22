//
//  ItemDetailsViewController.swift
//  2DoList
//
//  Created by Marko Tribl on 1/13/18.
//  Copyright © 2018 Marko Tribl. All rights reserved.
//

import UIKit

class ItemDetailsViewController: UIViewController {

    var storageController: StorageController?
    var selectedItem: Item?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = selectedItem?.title!
    }

    

}
