//
//  UserSettings.swift
//  MachineManagment
//
//  Created by julerrie on 2020/06/17.
//  Copyright © 2020 julerrie. All rights reserved.
//

import Foundation

class UserSettings: ObservableObject {
    @Published var department: String = UserDefaults.standard.string(forKey: "department") ?? "先端技術室"
}
