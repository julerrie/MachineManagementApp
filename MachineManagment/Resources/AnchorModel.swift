//
//  AnchorModel.swift
//  MachineManagment
//
//  Created by julerrie on 2020/05/11.
//  Copyright © 2020 julerrie. All rights reserved.
//

import Foundation
import RealmSwift
import ARKit

class AnchorModel: Object, Identifiable {
    @objc dynamic var managementId: String = ""
    @objc dynamic var worldMap: String = ""
    var anchorList: List<Float> = List<Float>()
    
    convenience init(managementId: String, worldMap: String, anchor: List<Float>) {
        self.init()
        self.managementId = managementId
        self.worldMap = worldMap
        anchorList = anchor
    }
    
    override static func primaryKey() -> String? {
      return "managementId"
    }
    
}
