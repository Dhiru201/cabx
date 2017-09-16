//
//  CabxNavBar.swift
//  CabFinder
//
//  Created by Dhirendra Verma on 16/08/17.
//  Copyright © 2017 Dhirendra Verma. All rights reserved.
//

import UIKit

class CabxNavBarTitleView: UIView{

	var shouldSetupConstraints = true
	var fromLabel:CabUILabel?
	var destLabel:CabUILabel?
	var titleValue: String?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		let labelView = UIView(frame: self.frame)
		self.backgroundColor = Constants.themeColor
		let title:UILabel = UILabel(frame: CGRect(x: 0, y: 39, width: frame.width, height: 26))
		title.textAlignment = NSTextAlignment.center
		title.text = "CabX"
		title.font = UIFont(name:"Helvetica", size: 26)

		labelView.addSubview(title)
		labelView.addSubview(fromLabel!)
		self.setPlaceHolders()
		labelView.addSubview(destLabel!)
		self.addSubview(labelView)
		self.dropShadow(shadowRadius: 5, shadowOpacity: 0.5, offSet: CGSize(width: -1, height: 3))
	}
	
	func setPlaceHolders(){
		if self.fromLabel?.text == nil{
			self.fromLabel?.text = " From"
		}
		if self.destLabel?.text == nil{
			self.destLabel?.text = " Destination"
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func updateConstraints() {
		if(shouldSetupConstraints) {
			// AutoLayout constraints
			shouldSetupConstraints = false
		}
		super.updateConstraints()
	}
}
