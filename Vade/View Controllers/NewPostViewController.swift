//
//  NewPostViewController.swift
//  Vade
//
//  Created by Daria Tokareva on 28.02.2021.
//

import UIKit
import Firebase
import Network

class NewPostViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var placeHolderLabel: UILabel!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var postButton: UIButton!
    
    
    @IBAction func tappedBackButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tappedPostButton(_ sender: Any) {
        
    
        //MARK: - TRY save posts
        let postRef = Database.database().reference().child("posts").childByAutoId()
        let postObject = [
            "author" : [
                "userid" : VadeUser.shared.getFirestoreID(),
                "username" : VadeUser.shared.getName()
            ],
            "text" : textView.text ?? "",
            "timestamp" : [".sv":"timestamp"]
        ] as [String : Any]
        
        postRef.setValue(postObject) { (error , ref) in
            if error == nil {
                self.dismiss(animated: true)
            } else {
                // Handle the error
            }
        }
    
        
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
//        textView.resignFirstResponder()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            super.dismiss(animated: flag, completion: completion)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backButton.tintColor = UIColor.gray
        postButton.layer.cornerRadius = postButton.bounds.height / 2
        
        textView.delegate = self
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Remove underline
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeHolderLabel.isHidden = !textView.text.isEmpty
    }
}
