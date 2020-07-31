//
//  DBManager.swift
//  MachineManagment
//
//  Created by julerrie on 2020/04/28.
//  Copyright © 2020 julerrie. All rights reserved.
//

import Foundation
import RealmSwift
import ARKit


class DBManager {
    
    var realm: Realm!
    
    //DB初期化
    static let sharedInstance: DBManager = {
        let instance = DBManager()
        let realm = try! Realm()
        let machine: Machine = Machine()
        var machineList: [MachineModel] = []
        if let list: Machine.MachineList = machine.loadJson(filename: "machine") {
            for entity in list.machine {
                let model: MachineModel = MachineModel(entity: entity)
                machineList.append(model)
            }
        } else{
            print("fail to get list")
        }
        for model in machineList {
            let existingModel = realm.object(ofType: MachineModel.self, forPrimaryKey: model.managementId)
            if existingModel == nil {
                try! realm.write {
                    realm.add(model)
                }
            }
        }
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        instance.realm = realm
        return instance
    }()
    
    
    public func getMachineList() -> [MachineModel]{
        let predicate = NSPredicate(format: "department == %@", UserDefaults.standard.string(forKey: "department") ?? "先端技術部")
        return Array(realm.objects(MachineModel.self).filter(predicate))
    }
    
    public func updataDBWith(id: String){
        let existingModel = realm.object(ofType: MachineModel.self, forPrimaryKey: id)
        if existingModel != nil {
            try! realm.write {
                existingModel?.complete = "1"
                print("update finish")
            }
        }else {
            print("data not exist")
        }
    }
    
    public func saveWorldMapModel(path: String) {
        let existingModel = realm.object(ofType: WorldMapModel.self, forPrimaryKey: path)
        if existingModel == nil {
            let worldMapModel = WorldMapModel(worldMapName: path, department: UserDefaults.standard.string(forKey: "department") ?? "先端技術部")
            try! realm.write {
                realm.add(worldMapModel)
            }
        }
    }
    
    public func saveDeviceAnchor(id: String, worldMap: String, anchor: simd_float4x4) {
        let existingModel = realm.object(ofType: AnchorModel.self, forPrimaryKey: id)
        let anchorList: List<Float> = List<Float>()
        anchorList.append(anchor.columns.0.x)
        anchorList.append(anchor.columns.0.y)
        anchorList.append(anchor.columns.0.z)
        anchorList.append(anchor.columns.0.w)
        anchorList.append(anchor.columns.1.x)
        anchorList.append(anchor.columns.1.y)
        anchorList.append(anchor.columns.1.z)
        anchorList.append(anchor.columns.1.w)
        anchorList.append(anchor.columns.2.x)
        anchorList.append(anchor.columns.2.y)
        anchorList.append(anchor.columns.2.z)
        anchorList.append(anchor.columns.2.w)
        anchorList.append(anchor.columns.3.x)
        anchorList.append(anchor.columns.3.y)
        anchorList.append(anchor.columns.3.z)
        anchorList.append(anchor.columns.3.w)
        let anchorModel = AnchorModel(managementId: id, worldMap: worldMap, anchor: anchorList)
        if existingModel == nil {
            try! realm.write {
                realm.add(anchorModel)
            }
        } else{
            try! realm.write {
                if let existingModel: AnchorModel = existingModel {
                    realm.delete(existingModel)
                }
                realm.add(anchorModel)
            }
        }
    }
    
    public func getDeviceAnchor() -> [AnchorModel] {
        return Array(realm.objects(AnchorModel.self))
    }
    
    public func getWorldMapList() -> [WorldMapModel] {
        let predicate = NSPredicate(format: "department == %@", UserDefaults.standard.string(forKey: "department") ?? "先端技術部")
        return Array(realm.objects(WorldMapModel.self).filter(predicate))
    }

    public func getMachineBy(id: String) -> MachineModel? {
        if let machineModel: MachineModel = realm.object(ofType: MachineModel.self, forPrimaryKey: id) {
            return machineModel
        }
        return nil
    }
}
