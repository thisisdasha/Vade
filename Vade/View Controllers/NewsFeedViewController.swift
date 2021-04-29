//
//  NewsFeedViewController.swift
//  Vade
//
//  Created by Daria Tokareva on 26.02.2021.
//

import UIKit
import Firebase

class NewsFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var myTableView = UITableView()
    let identifier = "postCell"
    let cellNib = UINib(nibName: "PostTableViewCell", bundle: nil)
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createTable()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        navigationItem.backBarButtonItem = backItem
    }
    
    func createTable() {
        title = "Vade"
        self.navigationController!.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.orange]
        
        
        self.myTableView = UITableView(frame: view.bounds, style: .plain)
        myTableView.register(cellNib, forCellReuseIdentifier: identifier)
        myTableView.tableFooterView = UIView()
        self.myTableView.delegate = self
        self.myTableView.dataSource = self
        
        myTableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(myTableView)
        myTableView.reloadData()
        observePosts()
    }
    
    func observePosts() {
        let postsRef = Database.database().reference().child("posts")
        
        postsRef.observe(.value, with: { snapshot in
            
            var tempPosts = [Post]()
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                    let dict = childSnapshot.value as? [String:Any],
                    let author = dict["author"] as? [String:Any],
                    let username = author["username"] as? String,
                    let text = dict["text"] as? String {
                    
                
                    let post = Post(id: childSnapshot.key, author: username, text: text)
                    tempPosts.insert(post, at: 0)
                }
            }
            
            self.posts = tempPosts
            self.myTableView.reloadData()
            
        })
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
