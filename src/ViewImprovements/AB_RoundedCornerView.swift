//
//  AB_RoundedCornerView.swift
//  AB_Framework
//
//  Created by phoebe on 6/25/15.
//  Copyright (c) 2015 BeckCo. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class AB_RoundedCornerView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 0
    {
        didSet
        {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0
    {
        didSet
        {
            layer.borderWidth = borderWidth
        }
    }

    @IBInspectable var borderColor: UIColor?
    {
        didSet
        {
            layer.borderColor = borderColor?.CGColor
        }
    }
}