//
//  OlaCabPricing.swift
//  CabFinder
//
//  Created by Dhirendra Verma on 22/07/17.
//  Copyright © 2017 Dhirendra Verma. All rights reserved.
//

import Foundation
import Alamofire

class OlaCabPrice{
	var cabType:String
	var totalDistance:Double
	var travlingTime:String
	var fare:Int
	
	init(data:Dictionary<String, Any>) {
		
		self.cabType = data["category"] as! String
		if self.cabType == "share"{
			self.totalDistance = 0.0
			self.travlingTime = ""
			let estimatedPrice = (data["fares"] as! Array<Dictionary<String, Any>>)[0]["cost"] as! Int
			self.fare = estimatedPrice
		}else if self.cabType == "outstation"{
			self.totalDistance = 0.0
			self.travlingTime = ""
			self.fare = 0
		}else{
			self.totalDistance = data["distance"] as! Double
			let price = data["amount_max"] as! Int
			self.fare = price
			let time = data["travel_time_in_minutes"] as! Int
			if time <= 60{
				self.travlingTime = "\(time) Minutes"
			}else{
				let minutes:Int = (time % 60)
				let hours:Int = time / 60
				self.travlingTime = "\(hours) Hour \(minutes) Minutes"
			} 
		}
	}
	
	static func fetchOlaPricingData(baseUrl:String, url:String, parameters:[String:Float], callback:@escaping ([OlaCabPrice]?,Error?) -> Void) {
		var result:[OlaCabPrice] = []
		let header = ["X-APP-TOKEN":"\(Constants.olaAppTOKEN)"]
		URLHelper.get(baseUrl: baseUrl, url: url, parameters:parameters , headers: header, callback: {
			response in
			if response.error != nil{
				callback(nil, response.error)
			}else{
				if response.result.value == nil {
					Alert.commonAlert(title: "No Cabs", message: "Ola Cab Details Not Available For this Path")
				}else{
					var respData = response.result.value
					respData = (respData as! Dictionary<String, Any>)["ride_estimate"]
					if respData == nil {
						Alert.error(message: "No Ola Cabs Found")
					}else{
						for data in respData as! Array<Any> {
							result.append(OlaCabPrice(data: data as! Dictionary<String, Any>))
						}
						callback(result, nil)
					}
				}
			}
		})
	}
}
