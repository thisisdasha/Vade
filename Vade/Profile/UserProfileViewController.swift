//
//  UserProfileViewController.swift
//  Vade
//
//  Created by Daria Tokareva on 24.06.2021.
//

import UIKit

class UserProfileViewController: UIViewController {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setTitle()
        updateUsersData()
    }

    override func viewDidLayoutSubviews() {
        photoImageView.clipsToBounds = true
        photoImageView.layer.cornerRadius = photoImageView.bounds.height / 2
    }
    
    private func setTitle() {
        title = "Profile"
        self.navigationController!.title = "Profile"
        self.navigationController!.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.orange]
    }
    private func updateUsersData() {
        nameLabel.text = VadeUser.shared.getName()
        ageLabel.text = VadeUser.shared.getBirthday()
        weightLabel.text = VadeUser.shared.getWeight() + " kg"
        heightLabel.text = VadeUser.shared.getGrowth() + " cm"
        if VadeUser.shared.getPhotoURL() != nil {
            photoImageView.load(url: VadeUser.shared.getPhotoURL()!)
        }
        
        
//        print("url:\(VadeUser.shared.getPhotoURL())")
    }
}
