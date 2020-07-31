//
//  DirectionView.swift
//  MachineManagment
//
//  Created by julerrie on 2020/06/19.
//  Copyright © 2020 julerrie. All rights reserved.
//

import Foundation
import UIKit

class DirectionView: UIView {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var directionImage: UIImageView!
    
    @IBOutlet weak var managementId: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    var userName: String = ""
    var deviceId: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    public func commonInit() {
        Bundle.main.loadNibNamed("DirectionView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.layer.cornerRadius = 10
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.managementId.text = self.deviceId
        self.nameLabel.text = self.userName
        
    }
    
    public func updateImage(name: String) {
        self.directionImage.image = UIImage(systemName: name)
    }
}
