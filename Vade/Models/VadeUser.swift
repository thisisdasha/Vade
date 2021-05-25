//
//  VadeUser.swift
//  Vade
//
//  Created by Egor on 17.11.2020.
//

import Foundation
import Firebase

class VadeUser {
    private var name = "default"
    private var email = "default"
    private var firestoreID = "default"
    private var sex = "default"
    private var birthday = "default"
    private var weight = "default"
    private var growth = "default"
    private var photoURL: URL?
    
    static var shared = VadeUser()
    
    private init() { }
    
    func getName() -> String {
        return name
    }
    
    func getEmail() -> String {
        return email
    }
    
    func getWeight() -> String {
        return weight
    }
    
    func getFirestoreID() -> String {
        return firestoreID
    }
    
    func getSex() -> String {
        return sex
    }
    
    func getBirthday() -> String {
        return birthday
    }
    
    func getGrowth() -> String {
        return growth
    }
    
    func getPhotoURL() -> URL? {
        print("\nIN FUNC func getPhotoURL")
        if photoURL != nil {
            return photoURL
        } else {
            // get url from firebase
            var newPhotoUrl: URL?
            let db = Firestore.firestore()
            let docRef = db.collection("users").document(firestoreID)
            
            docRef.getDocument { (document, error) in
                let data = document?.data()?["photoURL"]
                newPhotoUrl =  URL(string: data as! String)
//                print("🟨photoURL🟨\(newPhotoUrl)")
            }
            // MARK: - блок кода выполняется после завершения ф-ии!
//            print("🟩newPhotoUrl🟩\(String(describing: newPhotoUrl))")
            return newPhotoUrl
        }
    }
    
    func setName(name: String) {
        self.name = name
    }
    
    func setEmail(email: String) {
        self.email = email
    }
    
    func setBirthday(date: String) {
        self.birthday = date
    }
    
    func setFirestoreID(id: String) {
        self.firestoreID = id
    }
    
    func setSex(sex: String) {
        self.sex = sex
    }
    
    func setWeight(weight: String) {
        self.weight = weight
    }
    
    func setGrowth(growth: String) {
        self.growth = growth
    }
    
    func setPhotoURL(photoURL: URL){
        self.photoURL = photoURL
    }
}
