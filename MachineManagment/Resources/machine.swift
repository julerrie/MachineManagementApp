//
//  machine.swift
//  MachineManagment
//
//  Created by julerrie on 2020/04/24.
//  Copyright © 2020 julerrie. All rights reserved.
//

import Foundation

class Machine {
    
    struct MachineList: Decodable {
        var machine: [entity]
    }
    
    struct entity: Decodable {
        var managementId: String
        var type: String
        var name: String
        var department: String
        var group: String
        var address: String
        var remark: String
        var userId: String
        var userName: String
        var complete: String
        var date: String
        var worldMapx: String
        var worldMapy: String
    }
    
    func loadJson(filename fileName: String) -> MachineList? {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(MachineList.self, from: data)
                return jsonData
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }
}
