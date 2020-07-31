//
//  selectView.swift
//  MachineManagment
//
//  Created by julerrie on 2020/05/13.
//  Copyright © 2020 julerrie. All rights reserved.
//

import Foundation
import UIKit
import ARKit

class SelectView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var selectTableView: UITableView!
    
    @IBOutlet weak var worldMapButton: UIButton!
    
    @IBOutlet weak var cancleButton: UIButton!
    
    @IBOutlet weak var normalWorldMapButton: UIButton!
    
    var selectDevice: Bool = true
    
    var deviceIdSelected: ((String) -> Void)?
    
    var worldMapSelected: ((String) -> Void)?
    
    var closeView: (() -> Void)?
    
    var machineList: [MachineModel] = []
    
    var worldMapList: [WorldMapModel] = []
    
    var firstTime: Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    public func commonInit() {
        Bundle.main.loadNibNamed("SelectView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.layer.cornerRadius = 10
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.selectTableView.dataSource = self
        self.selectTableView.delegate = self
        self.selectTableView.layer.cornerRadius = 10
    }
    
    
    @IBAction func tapWorldMapButton(_ sender: Any) {
        if !selectDevice {
            self.worldMapSelected?("")
        }
        self.firstTime = false
        self.closeView?()
        self.removeFromSuperview()
        
    }
    
    
    func updateWith(selectDevice: Bool) {
        
        if selectDevice {
            self.displayLabel.text = "デバイスを選択"
            self.worldMapButton.setTitle("取り消し", for: .normal)
            machineList = DBManager.sharedInstance.getMachineList()
            self.cancleButton.isHidden = true
            self.normalWorldMapButton.isHidden = true
            self.worldMapButton.isHidden = false
        } else {
            self.displayLabel.text = "場所を選択"
            self.worldMapButton.setTitle("新規作成", for: .normal)
            worldMapList = DBManager.sharedInstance.getWorldMapList()
            if !self.firstTime {
                self.cancleButton.isHidden = false
                self.worldMapButton.isHidden = true
                self.normalWorldMapButton.isHidden = false
            } else {
                self.cancleButton.isHidden = true
                self.worldMapButton.isHidden = false
                self.normalWorldMapButton.isHidden = true
            }
        }
        self.selectDevice = selectDevice
        self.selectTableView.reloadData()
        self.layoutIfNeeded()
    }
    
    @IBAction func tapCancleButton(_ sender: Any) {
        self.closeView?()
        self.removeFromSuperview()
    }
    
}


extension SelectView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectDevice {
            return self.machineList.count
        } else {
            return self.worldMapList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        if selectDevice {
            let deviceID = self.machineList[indexPath.row].managementId
            cell.textLabel?.text = deviceID
            cell.isUserInteractionEnabled = true
            cell.textLabel?.isEnabled = true
        } else {
            cell.textLabel?.text = self.worldMapList[indexPath.row].worldMapName
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectDevice {
            self.deviceIdSelected?(self.machineList[indexPath.row].managementId)
        } else {
            self.worldMapSelected?(self.worldMapList[indexPath.row].worldMapName)
        }
        self.firstTime = false
        self.closeView?()
        self.removeFromSuperview()
    }
}

