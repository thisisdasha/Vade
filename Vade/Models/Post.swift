//
//  Post.swift
//  Vade
//
//  Created by Daria Tokareva on 26.02.2021.
//

import Foundation

class Post {
    var id: String
    var author: String
    var text: String
    var createdAt: Date
    
    
    init(id: String, author: String, text: String, timestamp: Double) {
        self.id = id
        self.author = author
        self.text = text
        self.createdAt = Date(timeIntervalSince1970: timestamp / 1000)
    }
}
