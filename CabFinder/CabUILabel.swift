//
//  CabUILabel.swift
//  CabFinder
//
//  Created by Dhirendra Verma on 16/08/17.
//  Copyright © 2017 Dhirendra Verma. All rights reserved.
//

import UIKit


class CabUILabel: UILabel{

	@IBInspectable var topInset: CGFloat = 0.0
	@IBInspectable var bottomInset: CGFloat = 5.0
	@IBInspectable var leftInset: CGFloat = 10.0
	@IBInspectable var rightInset: CGFloat = 5.0
	@IBInspectable var isPlaceHolder = false

	override open var attributedText: NSAttributedString?{
		didSet {
			updateText()
		}
	}
	
	func updateText(){
		if self.text == nil || self.text == "" {
			self.text = "TEMP"
			self.textColor = Constants.placeHolderColor
		}else{
			self.textColor = Constants.labelTextColor
		}
	}
}

