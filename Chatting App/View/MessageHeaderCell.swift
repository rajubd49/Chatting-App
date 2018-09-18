//
//  MessageHeaderCell.swift
//  Chatting App
//
//  Created by Raju on 9/14/18.
//  Copyright © 2018 Raju. All rights reserved.
//

import UIKit

class MessageHeaderCell: UICollectionReusableView {
    
    
    let headerLabel = HeaderLabel()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(headerLabel)

        //HeaderLabel Constrain
        headerLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        headerLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
