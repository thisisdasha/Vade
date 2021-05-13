//
//  SignUpViewController.swift
//  Vade
//
//  Created by Egor on 03.10.2020.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    // outlets for text fields and button
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.hideKeyboardWhenTappedAround()

        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(imageTap)
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        profileImageView.clipsToBounds = true
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
    }
    
    @objc func openImagePicker(_ sender: Any) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    override func viewDidLayoutSubviews() {
        setUpElements()
    }
    
    // for hide keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func setUpElements()
    {
        Utilities.styleTextField(firstNameTextField)
        Utilities.styleTextField(lastNameTextField)
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(signUpButton)
    }
    
    // validate all text fields values are correct
    func validateFields() -> String?
    {
        // Check that all fields are filled in
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        {
            return "Please, fill in all fields!"
        }
        
        // Check if the password is secure
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if !Utilities.isPasswordValid(cleanedPassword) {
            return "Please make sure your password at least 8 chars, contains a number, upper and lowercase symbols"
        }
        
        return nil
    }
    
    // signInButton action
    @IBAction func signUpTapped(_ sender: Any) {
        let error = validateFields()
        
        if error != nil {
            self.showAlert(title: "Sign Up failed", message: error!)
        }
        else {
            // clean all fields from tabs or spaces
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // create user with email and password
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                if err != nil {
                    self.showAlert(title: "Sign Up failed", message: err!.localizedDescription)
                }
                else {
                    // success!
                    
                    let db = Firestore.firestore()
                    self.upload(currentUserID: result!.user.uid, photo: self.profileImageView.image!) { url in
                        
                        if url != nil {
                            VadeUser.shared.setPhotoURL(photoURL: url!)
                        }
                        db.collection("users").document((result?.user.uid)!).setData([
                            "name": firstName + " " + lastName,
                            "email": email,
                            "last_visit": Utilities.getCurrentDateAndTime(),
                            "uid": result!.user.uid,
                            "photoURL": url?.absoluteString ?? ""
                        ])
                        
                    }

                    
                    
                    // set data for app vade user
                    VadeUser.shared.setName(name: firstName + " " + lastName)
                    VadeUser.shared.setEmail(email: email)
                    VadeUser.shared.setFirestoreID(id: result!.user.uid)
                    
                    
                    Transitor.transitionToHealthDataVC(view: self.view, storyboard: self.storyboard, uid: result!.user.uid)
                }
            }
        }
    }
    
    func upload(currentUserID: String, photo: UIImage, completion: @escaping ((_ url:URL?)->())) {
        let ref = Storage.storage().reference().child("avatars").child(currentUserID)
        
        guard let imageData = profileImageView.image?.jpegData(compressionQuality: 0.5) else { return }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        ref.putData(imageData, metadata: metadata){ metadata, error in
            guard let _ = metadata else {
                completion(nil)
                return
            }
            ref.downloadURL { url, error in
                guard let url = url else {
                    completion(nil)
                    return
                }
                completion(url)
            }
        }
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.profileImageView.image = pickedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
}
