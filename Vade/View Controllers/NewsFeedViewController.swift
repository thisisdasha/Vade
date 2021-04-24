//
//  NewsFeedViewController.swift
//  Vade
//
//  Created by Daria Tokareva on 26.02.2021.
//

import UIKit

class NewsFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var myTableView = UITableView()
    let identifier = "postCell"
    let cellNib = UINib(nibName: "PostTableViewCell", bundle: nil)
    var posts = [
        Post(id: "1", author: "Author", text: "Some text"),
        Post(id: "2", author: "Author2", text: "Some text2")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createTable()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        navigationItem.backBarButtonItem = backItem
    }
    
    func createTable() {
        title = "News Feed"
        self.myTableView = UITableView(frame: view.bounds, style: .plain)
        myTableView.register(cellNib, forCellReuseIdentifier: identifier)
        myTableView.tableFooterView = UIView()
        self.myTableView.delegate = self
        self.myTableView.dataSource = self
        
        myTableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(myTableView)
        myTableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! PostTableViewCell
        cell.set(post: posts[indexPath.row])
        return cell
    }
}
