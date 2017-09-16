//
//  UrlHelper.swift
//  CabFinder
//
//  Created by Dhirendra Verma on 22/07/17.
//  Copyright © 2017 Dhirendra Verma. All rights reserved.
//

import Foundation
import Alamofire

class URLHelper{
	static func get(baseUrl:String, url: String,parameters: [String: Any]?, headers: [String: String]?, callback: @escaping (DataResponse<Any>) -> Void){
	Alamofire.request(baseUrl + url, method: .get, parameters: parameters, headers: headers).responseJSON(completionHandler: {
		response in
		callback(response)
		})
	}
}
