//
//  InputViewController.swift
//  On The Map
//
//  Created by Saeed Khader on 01/12/2019.
//  Copyright © 2019 Saeed Khader. All rights reserved.
//

import UIKit
import MapKit

class InputViewController: UIViewController, UITextFieldDelegate {

    // MARK: - UI Properties
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var buttomConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttomConstraint2: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    var mapString = ""
    var latitude: Double!
    var longitude: Double!
    
    var isNewLocation = true
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotificaiton()
    }
    
    // MARK: - Main Functions

    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func findTapped(_ sender: Any) {
        textField.resignFirstResponder()
        activityIndicator.startAnimating()
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = textField.text
        let search = MKLocalSearch(request: searchRequest)
        
        search.start(completionHandler: handleMapSearchResponse(response:error:))
    }
    
    @IBAction func submitTapped(_ sender: Any) {
        textField.resignFirstResponder()
        activityIndicator.startAnimating()
        if isNewLocation {
            UdacityClient.postStudentLocation(mapString: mapString, mediaURL: textField.text ?? "", latitude: latitude, longitude: longitude, completion: handlePostStudentLocationResponse(success:error:))
        } else {
            UdacityClient.updateStudentLocation(mapString: mapString, mediaURL: textField.text ?? "", latitude: latitude, longitude: longitude, completion: handleUpdateStudentLocationResponse(success:error:))
        }
    }
    
    // MARK: - Handle Responses Functions
    
    func handlePostStudentLocationResponse(success: Bool, error: Error?) {
        if success {
            self.dismiss(animated: true) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateData"), object: nil)
            }
        } else {
            showAlert(title: "Post Location Failure", message: error!.localizedDescription)
        }
        self.activityIndicator.stopAnimating()
    }
    
    func handleUpdateStudentLocationResponse(success: Bool, error: Error?) {
        if success {
            print("success")
            self.dismiss(animated: true) {
                print("notifaction Update")
                 NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateData"), object: nil)
            }
        } else {
            showAlert(title: "Overwrite Failure", message: error!.localizedDescription)
        }
        self.activityIndicator.stopAnimating()
    }
    
    func handleMapSearchResponse(response: MKLocalSearch.Response?, error: Error?) {
        guard let response = response else {
            self.showAlert(title: "Location not found", message: "Sorry, can't find \(self.textField.text ?? "this location")")
            return
        }
        
        let annotations = self.mapView.annotations
        self.mapView.removeAnnotations(annotations)
        
        self.latitude = response.boundingRegion.center.latitude
        self.longitude = response.boundingRegion.center.longitude
        self.mapString = self.textField.text ?? ""
        
        let coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        
        self.activityIndicator.stopAnimating()
        
        self.createAnnotation(coordinate: coordinate)
        self.locationFounded()
    }
    
    // MARK: - functions
    
    func createAnnotation(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.title = self.textField.text
        annotation.coordinate = coordinate
        self.mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        self.mapView.setRegion(MKCoordinateRegion(center: coordinate, span: span), animated: true)
    }
    
    func locationFounded() {
        UIView.animate(withDuration: 0.5) {
            self.titleLabel.text = "Enter a link to Share here"
            self.textField.text = ""
            self.textField.placeholder = "A link to share.."
            self.findButton.isHidden = true
            self.submitButton.isHidden = false
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: self)
    }
    
    // MARK: - Keyboard Behavour
        
    func subscribeToKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotificaiton() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if self.buttomConstraint.constant == 15 {
            self.buttomConstraint.constant = getKeyboardHeight(notification)
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
        if self.buttomConstraint2.constant == 15 {
            self.buttomConstraint2.constant = getKeyboardHeight(notification)
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.buttomConstraint.constant = 15
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        self.buttomConstraint2.constant = 15
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    
    // MARK: - TextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }

}
