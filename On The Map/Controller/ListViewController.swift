//
//  ListViewController.swift
//  On The Map
//
//  Created by Saeed Khader on 01/12/2019.
//  Copyright © 2019 Saeed Khader. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - UI properties
    
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        UdacityClient.getStudentLocations(completion: handleGetStudentLocationsResponse(studentLocations:error:))
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name(rawValue: "updateData"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    // MARK: - Main Functions
    
    @IBAction func logoutTapped(_ sender: Any) {
        UdacityClient.logout { (success, error) in
            if success {
                self.dismiss(animated: true, completion: nil)
            } else {
                print(error ?? "error")
            }
        }
    }
    
    @IBAction func myLocationTapped(_ sender: Any) {
        let inputVC = storyboard?.instantiateViewController(withIdentifier: "inputView") as! InputViewController
        if UdacityClient.Auth.objectId == "" {
            present(inputVC, animated: true, completion: nil)
        } else {
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
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - functions
    
    @objc func reloadData() {
        tableView.reloadData()
    }
    
    // MARK: - TableViewDelegate

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        OTMModel.studentLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let studentLocation = OTMModel.studentLocations[indexPath.row]
        if studentLocation.objectId == OTMModel.myLocation?.objectId {
            cell.imageView?.tintColor = #colorLiteral(red: 0, green: 0.7109496593, blue: 0.9146520495, alpha: 1)
        }
        cell.detailTextLabel?.text = studentLocation.mediaURL
        cell.textLabel?.text = "\(studentLocation.firstName) \(studentLocation.lastName)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let app = UIApplication.shared
        app.open(URL(string: OTMModel.studentLocations[indexPath.row].mediaURL)!, completionHandler: { (success) in
            if !success {
                self.showAlert(title: "Invalid URL", message: "The student URL is not valid")
            }
        })
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func showAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: self)
    }

}
