//
//  ContentView.swift
//  test
//
//  Created by Karamjeet Singh Mann on 6/14/21.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    
    @State var timer: Timer?
    @State var locationFetcher = LocationFetcher()
    @State var trip:TripLocation = TripLocation()

    var body: some View {
        VStack {
            Button(action:{
                start()
            },label: {
                Text("Start Tracking")
            })
            Button(action:{
                stop()
            },label: {
                Text("Stop Tracking")
            })
        }
    
    }
    
    func start() {
        self.trip.tripID = "0"
        self.trip.startTime = "\(Date())"
        self.locationFetcher.start()
        self.timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { timer in
            if let location = self.locationFetcher.lastKnownLocation {
                self.trip.locations.append(Locations(latitude: "\(location.latitude)", longitude: "\(location.longitude)", timestamp: "\(Date())", accuracy: self.locationFetcher.manager.desiredAccuracy.description))
            } else {
                print("Your location is unknown")
            }
        })
    }
    
    func stop() {
        self.trip.endTime = "\(Date())"
        self.timer?.invalidate()
        self.locationFetcher.manager.stopUpdatingLocation()
        let locationsArr:[[String:AnyObject]] = self.trip.locations.map{
            ["latitude":$0.latitude as AnyObject,"longitude":$0.longitude as AnyObject,"timestamp":$0.timestamp as AnyObject,"accuracy":$0.accuracy as AnyObject]}
        let trip_:[String:AnyObject] = ["tripId":self.trip.tripID as AnyObject,
                                       "startTime":self.trip.startTime as AnyObject,
                                       "endTime":self.trip.endTime as AnyObject,
                                       "locations":locationsArr as AnyObject]
        
        UserDefaults.standard.setValue(trip_, forKey: "Trip")
        print(UserDefaults.standard.dictionary(forKey: "Trip") as? [String:AnyObject] ?? [])
    }

    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
class LocationFetcher: NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    var lastKnownLocation: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func start() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        manager.desiredAccuracy = 10.0
        manager.allowsBackgroundLocationUpdates = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastKnownLocation = locations.first?.coordinate
    }
}

struct TripLocation {
    var tripID:String = ""
    var startTime:String = ""
    var endTime:String = ""
    var locations:[Locations] = []
}

struct Locations {
    var latitude = ""
    var longitude = ""
    var timestamp = ""
    var accuracy = ""
}
