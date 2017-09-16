//
//  Alerts.swift
//  CabFinder
//
//  Created by Dhirendra Verma on 18/08/17.
//  Copyright © 2017 Dhirendra Verma. All rights reserved.
//

import UIKit

struct Alert{
	
	
	static func error(message: String){
		commonAlert(title: "Error", message: message)
	}
	
	static func warning(message: String){
		commonAlert(title: "Warning", message: message)
	}
	
	static func inputError (message: String){
		commonAlert(title: "Input Error", message: message)
	}
	
	static func commonAlert(title: String, message: String){
		let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
		
		alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		if let window = UIApplication.shared.windows.last {
			window.rootViewController?.present(alertController, animated: true, completion: nil)
		}
	}
	
	static func permissionAlert(title: String, message: String){
		let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		alertController.addAction(cancelAction)
		let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
			if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
				UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
				}
			}
			alertController.addAction(openAction)
		if let window = UIApplication.shared.windows.last {
			window.rootViewController?.present(alertController, animated: true, completion: nil)
		}
	}
}
