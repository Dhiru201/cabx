//
//  CabsTableViewCell.swift
//  CabFinder
//
//  Created by Dhirendra Verma on 17/08/17.
//  Copyright © 2017 Dhirendra Verma. All rights reserved.
//

import UIKit

class CabsTableViewCell: UITableViewCell {

	@IBOutlet weak var cabFare: UILabel!
	@IBOutlet weak var cabName: UILabel!
	@IBOutlet weak var cabTypeImage: UIImageView!
	@IBOutlet weak var distanceANDtime: UILabel!
	
	var uberData:UberCabPrice! {
		didSet {
			updateUberCell()
		}
	}
	
	var olaData:OlaCabPrice! {
		didSet {
			updateOlaCell()
		}
	}

	func updateUberCell(){
		self.cabName.text = self.uberData.cabType
		self.cabTypeImage.image = UIImage(named: self.uberData.cabType)
		self.cabFare.text = "Rs. \(self.uberData.fare)"
		let totalDistance = uberData.totalDistance
		let totalTime = uberData.travlingTime
		self.distanceANDtime.text = " \(totalDistance) Km. in \(totalTime)"
	}
	
	func updateOlaCell(){
		self.cabName.text = self.olaData.cabType
		self.cabTypeImage.image = UIImage(named: self.olaData.cabType)
		self.cabFare.text = "Rs. \(self.olaData.fare)"
		let totalDistance = olaData.totalDistance
		let totalTime = olaData.travlingTime
		if self.olaData.cabType ==  "share" {
			self.distanceANDtime.text = "For One Person"
		}else if self.olaData.cabType == "outstation" {
				  self.distanceANDtime.text = "For more Details Please Contact olacabs.com"
		}else{
			self.distanceANDtime.text = " \(totalDistance) Km. in \(totalTime)"
		}
	}
}
