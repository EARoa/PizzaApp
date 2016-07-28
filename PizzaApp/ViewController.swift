//
//  ViewController.swift
//  PizzaApp
//
//  Created by Efrain Ayllon on 7/27/16.
//  Copyright © 2016 Efrain Ayllon. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate,MKMapViewDelegate {
    
    var locations = [PizzaLocations]()

    
    
    @IBOutlet weak var mapView :MKMapView!
    var locationManager :CLLocationManager!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiSetup()
        mapSetup()

    }
    
    
    private func apiSetup() {
        let theAPI = "https://dl.dropboxusercontent.com/u/20116434/locations.json"
        guard let url = NSURL(string: theAPI) else {
            fatalError("Invalid URL")
        }
        let session = NSURLSession.sharedSession()
        session.dataTaskWithURL(url) { (data :NSData?, response :NSURLResponse?, error :NSError?) in
            guard let jsonResult = NSString(data: data!, encoding: NSUTF8StringEncoding) else {
                fatalError("Unable to format data")
            }
            let pizzaResponse = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [AnyObject]
            
            
            
            for item in pizzaResponse {
                let locations = PizzaLocations()
                locations.name = item.valueForKey("name") as! String
                locations.latitude = item.valueForKey("latitude") as! Double
                locations.longitude = item.valueForKey("longitude") as! Double
                locations.photoUrl = item.valueForKey("photoUrl") as! String
                self.locations.append(locations)
//                print(locations.name)
            


            }
            dispatch_async(dispatch_get_main_queue(), {
            
                for items in self.locations {
                    print ("Lat: \(items.latitude), Long: \(items.longitude)")
    
                let pinAnnotation = MKPointAnnotation()
                pinAnnotation.title = items.name
                pinAnnotation.coordinate = CLLocationCoordinate2D(latitude: items.latitude, longitude: items.longitude)
    
    
                self.mapView.addAnnotation(pinAnnotation)

                    
                    
                }
            })
            
            }.resume()
    }
    
    private func mapSetup(){
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.mapView.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
    }
    
    
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        
        if let annotationView = views.first {
            
            if let annotation = annotationView.annotation {
                if annotation is MKUserLocation {
                    
                    let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 250, 250)
                    self.mapView.setRegion(region, animated: true)
                }
            }
        }
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        var pizzaAnnotationView = self.mapView.dequeueReusableAnnotationViewWithIdentifier("PizzaAnnotationView")
        
        if pizzaAnnotationView == nil {
            pizzaAnnotationView = PizzaAnnotationView(annotation: annotation, reuseIdentifier: "PizzaAnnotationView")
        }
        
        pizzaAnnotationView?.canShowCallout = true
        
        let pizzaImageView = UIImageView(image: UIImage(contentsOfFile: "pizza"))

        return pizzaAnnotationView
        
    }
    
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

