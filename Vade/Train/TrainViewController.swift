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
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    
    
    let locationManager = LocationManager.shared
    var timer: Timer?
    private var seconds = 0
    var locationList: [CLLocation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startButton.layer.cornerRadius = startButton.layer.bounds.height / 2
        stopButton.layer.cornerRadius = stopButton.layer.bounds.height / 2
    }
    
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      timer?.invalidate()
      locationManager.stopUpdatingLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        checkLocationEnable()
    }
    
    func eachSecond() {
        seconds += 1
        updateDisplay()
    }
    func setupManager() {
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 10
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func updateDisplay() {
        let formattedTime = FormatDisplay.time(seconds)
        
        timeLabel.text = "\(formattedTime)"
    }
    
    @IBAction func startButtonTapped(_ sender: Any) {
        startButton.isHidden = true
        stopButton.isHidden = false
        seconds = 0
//        distance = Measurement(value: 0, unit: UnitLength.meters)
        locationList.removeAll()
        updateDisplay()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
          self.eachSecond()
        }
//        startLocationUpdates()
    }
    
    func checkAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
            break
        case .denied:
            showAlertLocation(title: "You have banned the use of the location", message: "Do you want to change this?", url: URL(string: UIApplication.openSettingsURLString))
            break
        case .restricted:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func showAlertLocation(title: String, message: String?, url: URL?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default){ alert in
            if let url = url {
                UIApplication.shared.open(url)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel , handler: nil )
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
         
        present(alert, animated: true, completion: nil)
    }
    
    func checkLocationEnable() {
        if CLLocationManager.locationServicesEnabled(){
            setupManager()
            checkAuthorization()
        } else {
            showAlertLocation(title: "Geolocation service is disabled!", message: "Want to turn it on?", url: URL(string: "App-prefs:LOCATION_SERVICES"))
        }
    }
}
extension TrainViewController: CLLocationManagerDelegate {
    
    //updates coordinates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last?.coordinate {
             let region = MKCoordinateRegion(center: location, latitudinalMeters: 5000, longitudinalMeters: 5000)
            mapView.setRegion(region, animated: true)
        }
        
        for newLocation in locations {
              let howRecent = newLocation.timestamp.timeIntervalSinceNow
              guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }

//              if let lastLocation = locationList.last {
//                let delta = newLocation.distance(from: lastLocation)
//                distance = distance + Measurement(value: delta, unit: UnitLength.meters)
//              }

              locationList.append(newLocation)
            }
    }

    //when user change authorization
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkAuthorization()
    }
}
