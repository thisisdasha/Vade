//
//  Train.swift
//  Vade
//
//  Created by Daria Tokareva on 11.06.2021.
//

import Foundation

class Train {
    private var distance = 0.0
    private var duration = 0
    private var timestamp: Date?
    private var locations: [Location] = []
    
    static var shared = Train()
    
    private init() { }
    
    func getDistance() -> Double {
        return distance
    }
    
    func getDutation() -> Int {
        return duration
    }
    
    func getTimestamp() -> Date {
        return timestamp!
    }
    
    func getLocations() -> [Location] {
        return locations
    }
    
    func setDistance(distance: Double) {
        self.distance = distance
    }
    
    func setDuration(duration: Int) {
        self.duration = duration
    }
    
    func setTimestamp(timestamp: Date) {
        self.timestamp = timestamp
    }
    
    func addToLocations(locationObject: Location) {
        locations.append(locationObject)
    }
}
