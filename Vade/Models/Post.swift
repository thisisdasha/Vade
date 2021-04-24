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
    
    init(id: String, author: String, text: String) {
        self.id = id
        self.author = author
        self.text = text
    }
}
