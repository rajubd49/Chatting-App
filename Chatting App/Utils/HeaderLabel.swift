//
//  HeaderLabel.swift
//  Chatting App
//
//  Created by Raju on 9/7/18.
//  Copyright © 2018 Raju. All rights reserved.
//

import UIKit

class HeaderLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        textAlignment = .center
        font = UIFont.boldSystemFont(ofSize: 14)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        let originalContentSize = super.intrinsicContentSize
        let height = originalContentSize.height
        let width = originalContentSize.width
        layer.cornerRadius = height/2 + 8
        layer.masksToBounds = true
        
        return CGSize(width: width + 16, height: height + 16)
    }
}
