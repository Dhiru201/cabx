//
//  extensions.swift
//  CabFinder
//
//  Created by Dhirendra Verma on 16/08/17.
//  Copyright © 2017 Dhirendra Verma. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps


extension LocationSearchViewController{
	internal func setUpGoogleMap(){
		locationManager = CLLocationManager()
		locationManager.delegate = self
		locationManager.requestWhenInUseAuthorization()
		locationManager.startUpdatingLocation()
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.startMonitoringSignificantLocationChanges()
		self.googleMap.delegate = self
		self.googleMap.isMyLocationEnabled = true
		self.googleMap.settings.myLocationButton = true
		self.googleMap.padding = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
		self.googleMap.settings.zoomGestures = true
		self.googleMap.settings.allowScrollGesturesDuringRotateOrZoom = false
	}
	
	internal func setPointersAndPath(place: CustomPlace!){
		let camera = GMSCameraPosition.camera(withLatitude: (place.coordinate?.latitude)!, longitude: (place.coordinate?.longitude)!,zoom: 15.0)
		// set address & coordinates
		if locationSelected == .startLocation {
			self.setStartPointDetails(place: place)
		}else{
			self.setEndPointDetails(place: place)
		}
		self.googleMap.camera = camera
		if self.location.startPlace != nil && self.location.endPlace != nil{
			self.drawPathOnMap()
		}
	}
	
	internal func setStartPointDetails(place: CustomPlace!){
		self.location.fromLocation = place.name
		self.start_latitude = place.coordinate?.latitude
		self.start_longitude = place.coordinate?.longitude
		self.location.startPlace = place
		self.setFromText(place.name)
		self.createStartPoint()
	}
	
	internal func setEndPointDetails(place: CustomPlace!){
		self.location.destLocation = place.name
		self.end_latitude = place.coordinate?.latitude
		self.end_longitude = place.coordinate?.longitude
		self.location.endPlace = place
		self.setDestText(place.name)
		self.createEndPoint()
	}

	
	internal func clearText(){
		self.setFromText(nil)
		self.setDestText(nil)
	}
	
	internal func currentLocationPermission(){
		if isLocationPermission == true{
			locationManager.startUpdatingLocation()
			print("location permission granted")
			let camera = GMSCameraPosition.camera(withLatitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!, zoom: 15.0)
			self.googleMap.camera = camera
		}else{
			print("location permission not granted")
			let camera = GMSCameraPosition.camera(withLatitude:23.4497913,longitude: 78.3333057, zoom: 5.0)
			self.googleMap.camera = camera
		}
	}
	
	internal func setCurrentLocation() {
		if isLocationPermission == true {
			let place = self.getPlace()
			self.setPointersAndPath(place: place)
		}else{
			Alert.permissionAlert(title: "Location Access Request", message: "The location permission was not authorized.")
		}
	}
	
	internal func getPlace() -> CustomPlace{
		locationManager.startUpdatingLocation()
		let location = CLLocationCoordinate2D(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!)
		return CustomPlace(name: "Current Location", coordinate: location)
	}
	
	
	
	internal func openAutoCompleteController(){
		let autoCompleteController = GMSAutocompleteViewController()
		autoCompleteController.delegate = self as GMSAutocompleteViewControllerDelegate
		let filter = GMSAutocompleteFilter()
		filter.country = "IN"  //appropriate country code
		autoCompleteController.autocompleteFilter = filter
		self.present(autoCompleteController, animated: true, completion: nil)
	}
	
	
	internal func setFromText(_ labelMessage: String?){
		self.setLabel(label: self.fromLabel, labelMessage: labelMessage, defaultMessage: " Enter Pickup Location")
	}
	
	internal func setDestText(_ labelMessage: String?){
		self.setLabel(label: self.destLabel, labelMessage: labelMessage, defaultMessage: " Enter Drop Location")
	}
	
	
	// MARK: Create Pointer and Draw path
	
	internal func createStartPoint(){
		self.createPointerOnMap(place: self.location.startPlace!, marker: #imageLiteral(resourceName: "fromPointer"))
		let camera = GMSCameraPosition.camera(withLatitude: self.start_latitude!, longitude:self.start_longitude!, zoom: 15.0)
		self.googleMap.camera = camera
	}
	
	internal func createEndPoint(){
		self.createPointerOnMap(place: self.location.endPlace!, marker: #imageLiteral(resourceName: "destPointer"))
		let camera = GMSCameraPosition.camera(withLatitude: self.end_latitude!, longitude:self.end_longitude!, zoom: 15.0)
		self.googleMap.camera = camera
	}
	
	
	internal func drawPathOnMap(){
		self.googleMap.clear()
		self.createStartPoint()
		self.createEndPoint()
		var region:GMSVisibleRegion = GMSVisibleRegion()
		region.nearLeft = CLLocationCoordinate2DMake(self.start_latitude!, self.start_longitude!)
		region.farRight = CLLocationCoordinate2DMake(self.end_latitude!,self.end_longitude!)
		let bounds = GMSCoordinateBounds(coordinate: region.nearLeft,coordinate: region.farRight )
		let zoomCamera = googleMap.camera(for: bounds, insets:UIEdgeInsets.init(top: 40, left: 40, bottom: 90, right: 40))
		self.googleMap.camera = zoomCamera!
		drawPath(start_latitude: start_latitude!, start_longitude: start_longitude!, end_latitude: end_latitude!, end_longitude: end_longitude!)
	}
	
	internal func createPointerOnMap(place: CustomPlace, marker:UIImage?) {
		let pointer =  GMSMarker()
		pointer.position = CLLocationCoordinate2DMake((place.coordinate?.latitude)!, (place.coordinate?.longitude)!)
		pointer.title = place.name
		pointer.icon = marker
		pointer.map = self.googleMap
		var region:GMSVisibleRegion = GMSVisibleRegion()
		if self.start_latitude != nil{
			region.nearLeft = CLLocationCoordinate2DMake(self.start_latitude!, self.start_longitude!)
		}
		if self.end_latitude != nil{
			region.farRight = CLLocationCoordinate2DMake(self.end_latitude!,self.end_longitude!)
		}
		let bounds = GMSCoordinateBounds(coordinate: region.nearLeft,coordinate: region.farRight)
		let camera = googleMap.camera(for: bounds, insets:UIEdgeInsets.zero)
		googleMap.camera = camera!;
	}
	
	
	
	internal func drawPath(start_latitude: CLLocationDegrees, start_longitude: CLLocationDegrees, end_latitude: CLLocationDegrees, end_longitude: CLLocationDegrees){
		if (self.start_longitude != nil) && self.end_latitude != nil {
			GMap.getRoute(start_latitude: start_latitude, start_longitude: start_longitude, end_latitude: end_latitude, end_longitude: end_longitude, callback: {
				routes in
				for route in routes{
					GMap.drawRoute(route: route, map: self.googleMap)
				}
			})
		}
	}
	
	
	// MARK: UIView visual changes
	
	internal func setLabel(label: UILabel, labelMessage: String?, defaultMessage: String? = nil){
		if labelMessage == nil{
			label.text = defaultMessage!
			label.textColor = Constants.placeHolderColor
			label.font = UIFont(name:"HelveticaNeue-Thin", size: 18)
		}else {
			label.text = labelMessage!
			if labelMessage ==  "Current Location" {
				label.textColor = Constants.currentLocColor
			}else{
				label.textColor = Constants.labelTextColor
			}
		}
	}
	
	internal func navTitleViewSettings(){
		self.destLabelView.layer.cornerRadius = 5
		self.fromLabelView.layer.cornerRadius = 5
		self.fromLabel.isUserInteractionEnabled = true
		let fromGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.fromLabelPressed))
		self.fromLabel.addGestureRecognizer(fromGestureRecognizer)
		self.destLabel.isUserInteractionEnabled = true
		let destGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.destLabelPressed))
		self.destLabel.addGestureRecognizer(destGestureRecognizer)
		self.navigationController?.hidesBarsOnSwipe = true
	}
	
	
	internal func setShadow(){
		self.headerView.dropShadow(shadowRadius: 2, shadowOpacity: 0.3, offSet: CGSize(width: 0, height: 2))
		self.findButton.dropShadow(shadowRadius: 2, shadowOpacity: 0.5, offSet: CGSize(width: 0, height: 2))
	}
	
}

extension UIView {
	
	func dropShadow(shadowRadius:Float, shadowOpacity: Float, offSet:CGSize) {
		self.layer.masksToBounds = false
		self.layer.shadowColor = UIColor.black.cgColor
		self.layer.shadowOpacity = shadowOpacity
		self.layer.shadowOffset = offSet
		self.layer.shadowRadius = CGFloat(shadowRadius)
		self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
		self.layer.shouldRasterize = true
		self.layer.rasterizationScale = UIScreen.main.scale
	}
}

extension UIColor {
	convenience init(red: Int, green: Int, blue: Int) {
		assert(red >= 0 && red <= 255, "Invalid red component")
		assert(green >= 0 && green <= 255, "Invalid green component")
		assert(blue >= 0 && blue <= 255, "Invalid blue component")
		self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
	}
	convenience init(netHex:Int) {
		self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
	}
}

extension UILabel{
	
	func stripCorner(radius: CGFloat){
		self.layer.cornerRadius = radius
		self.clipsToBounds = true
	}
	
	func addImage(imageName: String, afterLabel bolAfterLabel: Bool = false){
		let attachment: NSTextAttachment = NSTextAttachment()
		attachment.image = UIImage(named: imageName)
		let attachmentString: NSAttributedString = NSAttributedString(attachment: attachment)
		if (bolAfterLabel){
			let strLabelText: NSMutableAttributedString = NSMutableAttributedString(string: self.text!)
			strLabelText.append(attachmentString)
			self.attributedText = strLabelText
		}else{
			let strLabelText: NSAttributedString = NSAttributedString(string: self.text!)
			let mutableAttachmentString: NSMutableAttributedString = NSMutableAttributedString(attributedString: attachmentString)
			mutableAttachmentString.append(strLabelText)
			self.attributedText = mutableAttachmentString
		}
	}
	
	func removeImage(){
		let text = self.text
		self.attributedText = nil
		self.text = text
	}
}

