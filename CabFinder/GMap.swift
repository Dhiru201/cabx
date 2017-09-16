//
//  GMap.swift
//  CabFinder
//
//  Created by Dhirendra Verma on 16/09/17.
//  Copyright © 2017 Dhirendra Verma. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import Alamofire
import SwiftyJSON

class GMap{
	
	internal static func getRoute(start_latitude:CLLocationDegrees, start_longitude:CLLocationDegrees, end_latitude:CLLocationDegrees, end_longitude:CLLocationDegrees, callback: @escaping ([JSON]) -> ()){
		
		let origin = "\(start_latitude),\(start_longitude)"
		let destination = "\(end_latitude),\(end_longitude)"
		let url = Constants.googleMapPathURL(origin: origin, destination: destination)
		Alamofire.request(url).responseJSON { response in
			let json = JSON(data: response.data!)
			let routes = json["routes"].arrayValue
			callback(routes)
		}
	}
	
	internal static func drawRoute(route:(JSON), map: GMSMapView){
		let routeOverviewPolyline = route["overview_polyline"].dictionary
		let points = (routeOverviewPolyline?["points"]?.stringValue)!
		let path = GMSPath.init(fromEncodedPath: points)
		let polyline = GMSPolyline.init(path: path)
		polyline.geodesic = true
		polyline.map = map
		
		//dotted path style
		let styles = [GMSStrokeStyle.solidColor(.clear),
		              GMSStrokeStyle.solidColor(.black)]
		let lengths: [NSNumber] = [60, 60]
		polyline.spans = GMSStyleSpans(polyline.path!, styles, lengths,GMSLengthKind.rhumb)
		polyline.strokeWidth = 3
	}
	
}
