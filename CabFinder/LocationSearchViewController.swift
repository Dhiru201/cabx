//
//  LocationSearchViewController.swift
//  CabFinder
//
//  Created by Dhirendra Verma on 16/08/17.
//  Copyright © 2017 Dhirendra Verma. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import SwiftyJSON

enum Location{
	case startLocation
	case destinationLocation
}

class CustomPlace{
	var name: String?
	var coordinate: CLLocationCoordinate2D?
	init(name: String, coordinate: CLLocationCoordinate2D) {
		self.name = name
		self.coordinate = coordinate
	}
}

class FromToLocation{
	var fromLocation: String?
	var destLocation: String?
	var startPlace: CustomPlace?
	var endPlace: CustomPlace?
}


class LocationSearchViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, GMSAutocompleteViewControllerDelegate {

	
	@IBOutlet var headerView: UIView!
	@IBOutlet var destLabelView: UIView!
	@IBOutlet var fromLabelView: UIView!
	@IBOutlet weak var destLabel: UILabel!
	@IBOutlet weak var fromLabel: UILabel!
	@IBOutlet weak var googleMap: GMSMapView!
	@IBOutlet weak var findButton: UIButton!

	var location = FromToLocation()
	var locationManager = CLLocationManager()
	var locationSelected = Location.startLocation
	var start_latitude:CLLocationDegrees?
	var start_longitude:CLLocationDegrees?
	var end_latitude:CLLocationDegrees?
	var end_longitude:CLLocationDegrees?
	var isLocationPermission:Bool?
	
	override func viewDidLoad() {
        super.viewDidLoad()
		self.currentLocationPermission()
		self.clearText()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		self.navTitleViewSettings()
		self.setUpGoogleMap()
		self.setShadow()
	}
	
	
	@IBAction func fromPointCurrentLoc(_ sender: UIButton) {
		locationSelected = .startLocation
		self.setCurrentLocation()
	}
	
	@IBAction func destPointCurrentLoc(_ sender: UIButton) {
		locationSelected = .destinationLocation
		self.setCurrentLocation()
	}

	
	@IBAction func find(_ sender: UIButton) {
		if (self.start_latitude == nil) && (self.end_latitude == nil) {
			Alert.inputError(message: "Please Enter Locations")
		}else if (self.start_latitude != nil) && (self.end_latitude == nil) {
			Alert.inputError(message: "Please Enter Desination Location")
		}else if (self.start_latitude == nil) && (self.end_latitude != nil){
			Alert.inputError(message: "Please Enter Start Location")
		}else{
			if self.fromLabel.text == self.destLabel.text {
				Alert.inputError(message: "From and Desination Address cannot be same")
			}else{
				let storyboard = UIStoryboard(name: "Main", bundle: nil)
				let vc = storyboard.instantiateViewController(withIdentifier: "CabDetailsViewController") as! CabDetailsViewController
				vc.from = self.location.fromLocation!
				vc.dest = self.location.destLocation!
				
				if self.start_latitude != nil{
					vc.start_latitude = Float(self.start_latitude!)
				}
				if self.start_longitude != nil{
					vc.start_longitude = Float(self.start_longitude!)
				}
				if self.end_latitude != nil{
					vc.end_latitude = Float(self.end_latitude!)
				}
				if self.end_longitude != nil{
					vc.end_longitude = Float(self.end_longitude!)
				}
				self.present(vc, animated: true, completion: nil)
			}
		}
	}
	
	@objc internal func fromLabelPressed() {
		self.locationSelected = Location.startLocation
		self.openAutoCompleteController()
	}
	
	@objc internal func destLabelPressed() {
		self.locationSelected = Location.destinationLocation
		self.openAutoCompleteController()
	}
	
	
	
//	MARK : Delegates
	
	func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
		Alert.error(message: error.localizedDescription)
	}
	
	
	func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
		// Change map location
		let c_place = CustomPlace(name: place.name, coordinate: place.coordinate)
		self.setPointersAndPath(place: c_place)
		self.dismiss(animated: true, completion: nil)
	}
	
	
	func wasCancelled(_ viewController: GMSAutocompleteViewController) {
		self.dismiss(animated: true, completion: nil)
	}
	
	func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
	}
	
	func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
		UIApplication.shared.isNetworkActivityIndicatorVisible = false
	}
	
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		googleMap.isMyLocationEnabled = true
		locationManager.stopUpdatingLocation()
	}
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status == .authorizedWhenInUse {
			locationManager.startUpdatingLocation()
			isLocationPermission = true
		}
	}

	
	
}



	



