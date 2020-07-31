//
//  ColorGenerator.swift
//  MachineManagment
//
//  Created by julerrie on 2020/06/26.
//  Copyright © 2020 julerrie. All rights reserved.
//

import Foundation
import UIKit

class ColorGenerator {
    static let sharedInstance = ColorGenerator()
    private var last: UIColor
    private var colors: [UIColor] = [.red, .blue, .yellow, .orange, .green]

    private init() {
        let random = Int(arc4random_uniform(UInt32(colors.count)))
        self.last = colors[random]
        colors.remove(at: random)
    }

    func next() -> UIColor {
        let random = Int(arc4random_uniform(UInt32(colors.count)))
        swap(&colors[random], &last)
        return last
    }
}
