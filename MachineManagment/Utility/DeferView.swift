//
//  DeferView.swift
//  MachineManagment
//
//  Created by julerrie on 2020/06/03.
//  Copyright © 2020 julerrie. All rights reserved.
//

import Foundation
import SwiftUI

struct DeferView<Content: View>: View {
    let content: () -> Content
    
    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }
    var body: some View {
        content()
    }
}
