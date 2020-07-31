//
//  Enum.swift
//  MachineManagment
//
//  Created by julerrie on 2020/06/15.
//  Copyright © 2020 julerrie. All rights reserved.
//

import Foundation

enum Department: String, CaseIterable, Identifiable {
    var id: Department { self }
    case SIS第一部 = "SIS第一部"
    case SIS第二部 = "SIS第二部"
    case SIS第三部 = "SIS第三部"
    case GIC = "GIC"
    case CSS部 = "CSS部"
    case 先端技術部 = "先端技術部"
    case 中部事業部 = "中部事業部"
    case 大阪事業部 = "大阪事業部"
    case 山陰事業部 = "山陰事業部"
    case 四国事業部 = "四国事業部"
}
