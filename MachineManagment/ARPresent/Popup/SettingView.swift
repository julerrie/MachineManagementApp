//
//  SettingView.swift
//  MachineManagment
//
//  Created by julerrie on 2020/05/14.
//  Copyright © 2020 julerrie. All rights reserved.
//

import Foundation
import UIKit

class SettingView: UIView {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var worldMapNameLabel: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    
    var setWorldMapNamp: ((String) -> Void)?
    
    var closeView: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    public func commonInit() {
        Bundle.main.loadNibNamed("SettingView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.layer.cornerRadius = 10
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.confirmButton.isEnabled = false
        self.worldMapNameLabel.addTarget(self, action: #selector(textFieldDidChange) , for: .editingChanged)
    }
    
    
    @IBAction func tapConfirmButton(_ sender: Any) {
        self.worldMapNameLabel.resignFirstResponder()
        self.setWorldMapNamp?(worldMapNameLabel.text ?? "")
    }
    
    
    @IBAction func tapCancleButton(_ sender: Any) {
        self.closeView?()
        self.removeFromSuperview()
    }
    
    
    @objc
    func textFieldDidChange() {
        if self.worldMapNameLabel.text?.isEmpty ?? true {
            self.confirmButton.isEnabled = false
        } else {
            self.confirmButton.isEnabled = true
        }
    }
    
    
}

