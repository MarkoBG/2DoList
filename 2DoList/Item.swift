//
//  Item.swift
//  2DoList
//
//  Created by Marko Tribl on 12/24/17.
//  Copyright © 2017 Marko Tribl. All rights reserved.
//

import Foundation


// U Swiftu 4 postoji jedan protocol koji zamenjuje Encodabel & Decodable
// Codable protokol

class Item: Codable {
    var title: String = ""
    var done: Bool = false
    
    init(title: String, done: Bool) {
        self.title = title
        self.done = done
    }
}
