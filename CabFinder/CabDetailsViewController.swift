//
//  CabDetailsViewController.swift
//  CabFinder
//
//  Created by Dhirendra Verma on 17/08/17.
//  Copyright © 2017 Dhirendra Verma. All rights reserved.
//

import UIKit



class CabDetailsViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
	

	@IBOutlet var loaderView: UIView!
	@IBOutlet var loader: UIActivityIndicatorView!
	@IBOutlet var backButton: UIButton!
	@IBOutlet weak var addressLabel: UILabel!
	@IBOutlet weak var openAPP: UIButton!
	@IBOutlet weak var uberCabButton: UIButton!
	@IBOutlet weak var olaCabButton: UIButton!
	@IBOutlet weak var cabsTableView: UITableView!
	@IBOutlet var headerView: UIView!
	
	@IBOutlet var uberCheapest: UILabel!
	@IBOutlet var olaCheapest: UILabel!
	var isOlaApiCallInProgress = false
	var isUberApiCallInProgress = false
	var dest:String!
	var from:String!
	var uberData:Array<UberCabPrice> = []
	var olaData:Array<OlaCabPrice> = []
	var olaSelected:Bool = true
	var start_latitude:Float?
	var start_longitude:Float?
	var end_latitude:Float?
	var end_longitude:Float?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.addressLabel.text = ("\(self.from!) To \(self.dest!)")
		self.navigationController?.navigationBar.isHidden = true
	}

	override func viewWillAppear(_ animated: Bool) {
		self.initialSetup()
		self.uberCheapest.isHidden = true
		self.olaCheapest.isHidden = true
		loaderSettings(isHidden:false)
	}
	
	func toggleSelector(){
		if (self.olaData.count > 1) && (self.uberData.count > 1){
			if (self.olaData[0].fare < self.uberData[0].fare){
				self.uberCheapest.isHidden = true
				self.olaCheapest.isHidden = false
				self.olaDetails(olaCabButton)
			}else{
				self.uberDetails(uberCabButton)
				self.uberCheapest.isHidden = false
				self.olaCheapest.isHidden = true
			}
		}
	}
	
	func initialSetup(){
		self.olaData.removeAll()
		self.uberData.removeAll()
		self.fetchUberData()
		self.fetchOlaData()
		self.headerView.dropShadow(shadowRadius:  3, shadowOpacity: 0.3, offSet: CGSize(width: 0, height: 3))
		self.backButton.dropShadow(shadowRadius: 2, shadowOpacity: 0.3, offSet: CGSize(width: 0, height: 2))
		self.addressLabel.dropShadow(shadowRadius: 2, shadowOpacity: 0.3, offSet: CGSize(width: 0, height: 2))
		self.openAPP.setImage(UIImage(named: "olaLOGO"), for: .normal)
		self.openAPP.dropShadow(shadowRadius: 3, shadowOpacity: 0.3, offSet: CGSize(width: 0, height: 3))
	}
	
	func loaderSettings(isHidden:Bool){
		self.loader.layer.cornerRadius = 10
		self.loaderView.layer.cornerRadius = 10
		self.loaderView.isHidden = isHidden
	}
	
	@IBAction func uberDetails(_ sender: Any) {
		self.olaSelected = false
		self.cabsTableView.reloadData()
		self.uberCabButton.backgroundColor = Constants.selectedTabColor
		self.olaCabButton.backgroundColor = Constants.unselectedTabColor
		self.openAPP.setImage(UIImage(named: "uberLOGO"), for: .normal)
		if uberData.count == 0 && !self.isUberApiCallInProgress {
			self.fetchUberData()
		}else{
			cabsTableView.reloadData()
		}
	}
	
	@IBAction func olaDetails(_ sender: Any) {
		self.olaSelected = true
		self.cabsTableView.reloadData()
		self.olaCabButton.backgroundColor = Constants.selectedTabColor
		self.uberCabButton.backgroundColor = Constants.unselectedTabColor
		self.openAPP.setImage(UIImage(named: "olaLOGO"), for: .normal)
		if olaData.count == 0 && !self.isOlaApiCallInProgress {
			self.fetchOlaData()
		}else{
			cabsTableView.reloadData()
		}
	}
	
	@IBAction func openAPP(_ sender: Any) {
		let url:String!
		let deeplinkURL:String!
		if olaSelected {
			url = Constants.olaWebURL
			deeplinkURL = Constants.olaDeeplinkURL(pickup_lat: self.start_latitude!, pickup_long: self.start_longitude!, drop_lat: self.end_latitude!, drop_long: self.end_longitude!)
		}else{
			 url = Constants.uberWebURL
			deeplinkURL = Constants.uberDeeplinkURL(pickup_lat: self.start_latitude!, pickup_long: self.start_longitude!, drop_lat: self.end_latitude!, drop_long: self.end_longitude!)
			}
		
		// If app is installed, construct and open deep link.
		if UIApplication.shared.canOpenURL(URL(string: deeplinkURL)!) {
				UIApplication.shared.open(URL(string:deeplinkURL)!)
		} else {
			// No app, open the app store.
			UIApplication.shared.open(URL(string: url)!)
			}
	}
	
	
	private func fetchUberData(){
		if (self.start_latitude) != nil && (self.end_latitude != nil){
			self.isUberApiCallInProgress = true
			let parameter = ["start_latitude":self.start_latitude , "start_longitude": self.start_longitude, "end_latitude": self.end_latitude, "end_longitude":self.end_longitude]
			UberCabPrice.fetchUberPricingData(baseUrl: Constants.uberBaseURL, url: Constants.uberPricingURL, parameters: parameter as! [String : Float], callback: {
				cabDetails, error in
				self.processData(cabDetails: cabDetails, error: error, isOla: false)
			})
		}
	}
	
	private func fetchOlaData(){
		if (self.start_latitude) != nil && (self.end_latitude != nil){
			self.isOlaApiCallInProgress = true
			let parameter = ["pickup_lat": self.start_latitude! , "pickup_lng": self.start_longitude!, "drop_lat": self.end_latitude!, "drop_lng": self.end_longitude!]
			OlaCabPrice.fetchOlaPricingData(baseUrl: Constants.olaBaseURL, url: Constants.olaPricingURL, parameters: parameter, callback: {
				cabDetails,error in
				self.processData(cabDetails: cabDetails, error: error, isOla: true)
			})
		}
	}
	
	private func sortOlaData(){
		self.olaData = self.olaData.sorted(by: {($0.fare) < ($1.fare) })
	}
	
	private func sortUberData(){
		self.uberData = self.uberData.sorted(by: {($0.fare) < ($1.fare) })
	}
	
	private func sortData(isOla: Bool){
		if isOla{
			self.sortOlaData()
			self.isOlaApiCallInProgress = false
		}else{
			self.sortUberData()
			self.isUberApiCallInProgress = false
		}
		self.loaderSettings(isHidden: true)
	}
	
	private func processData(cabDetails:[Any]?,  error: Error?, isOla: Bool){
		if error != nil {
			Alert.error(message: error!.localizedDescription)
		}else if cabDetails != nil && (cabDetails!.count) > 0 {
			for cab in cabDetails!{
				if isOla{
					self.olaData.append(cab as! OlaCabPrice)
				}else{
					self.uberData.append(cab as! UberCabPrice)
				}
			}
			self.sortData(isOla: isOla)
			self.cabsTableView.reloadData()
			self.toggleSelector()
		}else{
			Alert.warning(message: "No Items found")
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 64
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		if olaSelected{
			return self.olaData.count
		}else{
			return self.uberData.count
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell" , for: indexPath) as! CabsTableViewCell
		cell.dropShadow(shadowRadius: 3, shadowOpacity: 0.3, offSet: CGSize(width: 0, height: 3))
		if olaSelected{
			cell.olaData = self.olaData[indexPath.section]
		}else{
			cell.uberData = self.uberData[indexPath.section]
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 20
	}
}


