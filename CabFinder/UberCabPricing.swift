//
//  CabPricing.swift
//  CabFinder
//
//  Created by Dhirendra Verma on 22/07/17.
//  Copyright © 2017 Dhirendra Verma. All rights reserved.
//

import Alamofire

class UberCabPrice{
	var cabType:String
	var totalDistance:Double
	var travlingTime:String
	var fare:Int
		
	init(data:Dictionary<String, Any>) {
		self.cabType = (data["display_name"] as! String)
		self.totalDistance = (data["distance"] as! Double)
		let cost = (data["high_estimate"] as! Int)
		self.fare = cost
		let totalTime = (data["duration"]as! Int)
		if totalTime < 3600{
			self.travlingTime = "\((totalTime/60)%60) Minutes"
		}else{
			let minutes:Int = (totalTime / 60) % 60
			let hours:Int = totalTime / 3600
			self.travlingTime = "\(hours) Hour \(minutes) Minutes"
		}
	}
		
	static func fetchUberPricingData(baseUrl:String, url:String,parameters:[String:Float], callback:@escaping ([UberCabPrice]?, Error?) -> Void) {
		var result:[UberCabPrice] = []
		let header = ["Content-Type": "application/json","Authorization":"Token \(Constants.uberServerToken) ","Accept-Language":"en_EN"]
		URLHelper.get(baseUrl:baseUrl, url: url, parameters: parameters, headers: header, callback: {
			response in
			if response.error != nil{
				callback(nil, response.error)
			}else{
				if response.result.value == nil {
					Alert.commonAlert(title: "No Cabs", message: "Uber Cabs Details Not Available For this Path")
				}else{
					var respData = response.result.value
					respData = (respData as! Dictionary<String, Any>)["prices"]
					if respData == nil {
						Alert.error(message: "No Uber Cabs Found")
					}else{
						for data in respData as! Array<Any> {
							result.append(UberCabPrice(data: data as! Dictionary<String, Any>))
						}
						callback(result, nil)
					}
				}
			}
		})
	}
}
