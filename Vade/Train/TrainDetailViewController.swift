//
//  TrainDetailViewController.swift
//  Vade
//
//  Created by Daria Tokareva on 07.06.2021.
//

import UIKit
import MapKit

class TrainDetailViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        backButton.tintColor = UIColor.gray
        configureView()
    }
    
    private func configureView() {
        let distance = Measurement(value: Train.shared.getDistance(), unit: UnitLength.meters)
        let seconds = Train.shared.getDutation()
        let formattedDistance = FormatDisplay.distance(distance)
        let formattedDate = FormatDisplay.date(Train.shared.getTimestamp())
        let formattedTime = FormatDisplay.time(seconds)
        let formattedPace = FormatDisplay.pace(distance: distance, seconds: seconds, outputUnit: UnitSpeed.minutePerMile)
        
        distanceLabel.text = "Distance:  \(formattedDistance)"
        dateLabel.text = formattedDate
        timeLabel.text = "Time: \(formattedTime)"
        paceLabel.text = "Pace: \(formattedPace)"
        
        loadMap()
    }
    
    private func mapRegion() -> MKCoordinateRegion? {
        if Train.shared.getLocations().count == 0 {
            return nil
        }
        let locations = Train.shared.getLocations()
        let latitude = locations.map { location -> Double in
            let location = location
            return location.latitude
        }
        let longitude = locations.map { location -> Double in
            let location = location
            return location.longitude
        }
        let maxLong = longitude.max()!
        let minLong = longitude.min()!
        let maxLat = latitude.max()!
        let minLat = latitude.min()!
        
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLong + maxLong) / 2)
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.3, longitudeDelta: (maxLong - minLong) * 1.3)
        
        return MKCoordinateRegion(center: center, span: span)
    }
    
    private func polyLine() -> MKPolyline {
        if Train.shared.getLocations().count == 0 {
            return MKPolyline()
        }
        let locations = Train.shared.getLocations()
        let coords: [CLLocationCoordinate2D] = locations.map { location in
            let location = location
            return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        }
        return MKPolyline(coordinates: coords, count: coords.count)
    }
    
    private func loadMap() {
        if Train.shared.getLocations().count == 0 {
            let alert = UIAlertController(title: "Error", message: "Sorry, this train has no locations saved", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alert, animated: true)
            return
        }
        let region = mapRegion()
        
        mapView.setRegion(region!, animated: true)
        mapView.addOverlay(polyLine())
    }
}

extension TrainDetailViewController: MKMapViewDelegate {
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

