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
    var currentTrain = Train.shared
    private var timer: Timer?
    private var seconds = 0
    private var distance = Measurement(value: 0, unit: UnitLength.meters)
    private var locationList: [CLLocation] = []

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
        let formattedDistance = FormatDisplay.distance(distance)
        let formattedPace = FormatDisplay.pace(distance: distance, seconds: seconds, outputUnit: UnitSpeed.minutePerMile)
        
        timeLabel.text = "\(formattedTime)"
        distanceLabel.text = "\(formattedDistance)"
        paceLabel.text = "\(formattedPace)"
    }
    
    @IBAction func stopButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Finish your workout?", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            self.stopTrain()
            self.saveTrain()
            self.performSegue(withIdentifier: "TrainDetailViewController", sender: nil)
        }
        let discardAction = UIAlertAction(title: "Discard", style: .destructive) { _ in
            self.stopTrain()
        }
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        alert.addAction(discardAction)

        present(alert, animated: true, completion: nil)
    }
    
    private func stopTrain() {
        startButton.isHidden = false
        stopButton.isHidden = true
        timer?.invalidate()
        timeLabel.text = "00:00:00"
        distanceLabel.text = "0.00"
        paceLabel.text = "00:00"
        caloriesLabel.text = "0"
        mapView.removeOverlays(mapView.overlays)
        mapView.delegate = nil
        
        locationManager.stopUpdatingLocation()
    }
    
    @IBAction func startButtonTapped(_ sender: Any) {
        mapView.delegate = self
        startButton.isHidden = true
        stopButton.isHidden = false
        mapView.removeOverlays(mapView.overlays)
        
        seconds = 0
        distance = Measurement(value: 0, unit: UnitLength.meters)
        locationList.removeAll()
        updateDisplay()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
          self.eachSecond()
        }
        locationManager.startUpdatingLocation()
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
    
    private func saveTrain() {
        currentTrain.setDistance(distance: distance.value)
        currentTrain.setDuration(duration: seconds)
        currentTrain.setTimestamp(timestamp: Date())
        
        for location in locationList {
            let locationObj = Location(latitude: location.coordinate.latitude,
                                       longitude: location.coordinate.longitude,
                                       timestamp: location.timestamp)
            currentTrain.addToLocations(locationObject: locationObj)
        }
    }
}
extension TrainViewController: CLLocationManagerDelegate {
    
    //updates coordinates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 500, longitudinalMeters: 500)
            mapView.setRegion(region, animated: true)
        }
        
        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
            
            if let lastLocation = locationList.last {
                let delta = newLocation.distance(from: lastLocation)
                distance = distance + Measurement(value: delta, unit: UnitLength.meters)
                let coordinates = [lastLocation.coordinate, newLocation.coordinate]
                mapView.addOverlay(MKPolyline(coordinates: coordinates, count: 2))
                let region = MKCoordinateRegion(center: newLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
                mapView.setRegion(region, animated: true)
            }
            
            locationList.append(newLocation)
        }
    }

    //when user change authorization
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkAuthorization()
    }
}
extension TrainViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    guard let polyline = overlay as? MKPolyline else {
      return MKOverlayRenderer(overlay: overlay)
    }
    let renderer = MKPolylineRenderer(polyline: polyline)
    renderer.strokeColor = .orange
    renderer.lineWidth = 5
    return renderer
  }
}
