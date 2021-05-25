//
//  TrainViewController.swift
//  Vade
//
//  Created by Daria Tokareva on 25.05.2021.
//

import UIKit
import MapKit

class TrainViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        checkLocationEnable()
    }
    
    func setupManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationEnable() {
        if CLLocationManager.locationServicesEnabled(){
            setupManager()
        } else {
            let alert = UIAlertController(title: "Geolocation service is disabled!", message: "Want to turn it on?", preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "Settings", style: .default){ alert in
                if let url = URL(string: "App-prefs:LOCATION_SERVICES"){
                    UIApplication.shared.open(url)
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel , handler: nil )
            alert.addAction(settingsAction)
            alert.addAction(cancelAction)
             
            present(alert, animated: true, completion: nil)
        }
    }
}
extension TrainViewController: CLLocationManagerDelegate {
    
}
