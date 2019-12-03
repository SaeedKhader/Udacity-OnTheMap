//
//  MapViewController.swift
//  On The Map
//
//  Created by Saeed Khader on 01/12/2019.
//  Copyright © 2019 Saeed Khader. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    // MARK: - UI Properties
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: - Properties
    
    var myLocation : MKAnnotation?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self

        UdacityClient.getStudentLocations(completion: handleGetStudentLocationsResponse(studentLocations:error:))
 
        NotificationCenter.default.addObserver(self, selector: #selector(updateAnnotations), name: NSNotification.Name(rawValue: "updateData"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateAnnotations()
    }
    
    // MARK: - Main Functions
    
    @IBAction func logoutTapped(_ sender: Any) {
        UdacityClient.logout { (success, error) in
            if success {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.showAlert(title: "Logout Failure", message: error!.localizedDescription)
            }
        }
    }
    
    @IBAction func myLocationTapped(_ sender: Any) {
        let inputVC = storyboard?.instantiateViewController(withIdentifier: "inputView") as! InputViewController
        if UdacityClient.Auth.objectId == "" {
            present(inputVC, animated: true, completion: nil)
        } else {
            mapView.selectedAnnotations = []
            mapView.selectAnnotation(myLocation!, animated: true)
            let alertVC = UIAlertController(title: nil, message: "You Already Posted a Student Location. Would You Like to Overwrite Your Current Location?", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertVC.addAction(UIAlertAction(title: "Overwrite", style: .default, handler: { (alertAction) in
                inputVC.isNewLocation = false
                self.present(inputVC, animated: true, completion: nil)
            }))
            show(alertVC, sender: self)
        }
    }
    
    
    // MARK: - Handel Response Functions
    
    func handleGetStudentLocationsResponse(studentLocations: [StudentLocation], error: Error?) {
        if let error = error {
            showAlert(title: "Locations Failure", message: error.localizedDescription)
        } else {
            OTMModel.studentLocations = studentLocations
            self.updateAnnotations()
        }
    }
    
    
    // MARK: - functions
    
    @objc func updateAnnotations() {
        
        let allAnnotations = mapView.annotations
        mapView.removeAnnotations(allAnnotations)
  
        var annotations = [MKAnnotation]()
        
        for location in OTMModel.studentLocations {
            
            let annotation = createAnnotation(location: location)
            
            annotations.append(annotation)
            
            if let myLocation = OTMModel.myLocation {
                if location.objectId == myLocation.objectId {
                    self.myLocation = annotation
                }
            }
        }
        
        self.mapView.addAnnotations(annotations)
        
    }
    
    func createAnnotation(location: StudentLocation) -> MKAnnotation{
        let lat = CLLocationDegrees(location.latitude)
        let long = CLLocationDegrees(location.longitude)
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "\(location.firstName) \(location.lastName)"
        annotation.subtitle = location.mediaURL
        return annotation
    }
    
    
    func showAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: self)
    }
    
    // MARK: - MKMapViewDelegate


        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            let pinView = MKPinAnnotationView()
            pinView.annotation = annotation
            pinView.canShowCallout = true
            pinView.pinTintColor = annotation.isEqual(myLocation) ? #colorLiteral(red: 0, green: 0.7109496593, blue: 0.9146520495, alpha: 1) : #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            pinView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            pinView.animatesDrop = true

            return pinView
        }

        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            if control == view.rightCalloutAccessoryView {
                let app = UIApplication.shared
                if let toOpen = view.annotation?.subtitle! {
                    app.open(URL(string: toOpen)!, completionHandler: { (success) in
                        if !success {
                            self.showAlert(title: "Invalid URL", message: "The student URL is not valid")
                        }
                    })
                }
            }
        }
         
}

