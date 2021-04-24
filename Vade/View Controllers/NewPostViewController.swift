//
//  NewPostViewController.swift
//  Vade
//
//  Created by Daria Tokareva on 28.02.2021.
//

import UIKit
import FirebaseDatabase

class NewPostViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var placeHolderLabel: UILabel!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var postButton: UIButton!
    
    
    @IBAction func tappedBackButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tappedPostButton(_ sender: Any) {
        
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
//        textView.resignFirstResponder()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            super.dismiss(animated: flag, completion: completion)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backButton.tintColor = UIColor.systemBlue
        postButton.layer.cornerRadius = postButton.bounds.height / 2
        
        textView.delegate = self
        
        //test database
        let ref = Database.database().reference()
        
        //read data
//        ref.child("someid/name").observeSingleEvent(of: .value) { (snapshot) in
//            let name = snapshot.value as? String
//            print(name)
//        }
        ref.child("-MXDnGxOntZ1pC448fh0").removeValue()
        
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
