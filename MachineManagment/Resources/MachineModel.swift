//
//  MachineModel.swift
//  MachineManagment
//
//  Created by julerrie on 2020/04/24.
//  Copyright © 2020 julerrie. All rights reserved.
//

import Foundation
import RealmSwift

class MachineModel: Object, Identifiable {
    @objc dynamic var managementId: String = ""
    @objc dynamic var type: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var department: String = ""
    @objc dynamic var group: String = ""
    @objc dynamic var address: String = ""
    @objc dynamic var remark: String = ""
    @objc dynamic var userId: String = ""
    @objc dynamic var userName: String = ""
    @objc dynamic var complete: String = ""
    @objc dynamic var date: String = ""
    @objc dynamic var worldMapx: String = ""
    @objc dynamic var worldMapy: String = ""
    
    
    convenience init(entity: Machine.entity) {
        self.init()
        self.managementId = entity.managementId
        self.type = entity.type
        self.name = entity.name
        self.department = entity.department
        self.group = entity.group
        self.address = entity.address
        self.remark = entity.remark
        self.userId = entity.userId
        self.userName = entity.userName
        self.complete = entity.complete
        self.date = entity.date
        self.worldMapx = entity.worldMapx
        self.worldMapy = entity.worldMapy
    }
    
    override static func primaryKey() -> String? {
      return "managementId"
    }
    
}
