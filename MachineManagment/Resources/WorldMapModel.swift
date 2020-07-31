//
//  WorldMapModel.swift
//  MachineManagment
//
//  Created by julerrie on 2020/05/14.
//  Copyright © 2020 julerrie. All rights reserved.
//

import Foundation
import RealmSwift

class WorldMapModel: Object, Identifiable {
    @objc dynamic var worldMapName: String = ""
    @objc dynamic var department: String = ""
    
    convenience init(worldMapName: String, department: String) {
        self.init()
        self.worldMapName = worldMapName
        self.department = department
    }
    
    override static func primaryKey() -> String? {
      return "worldMapName"
    }
    
}
