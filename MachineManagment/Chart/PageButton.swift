//
//  CircleButton.swift
//  MachineManagment
//
//  Created by julerrie on 2020/06/05.
//  Copyright © 2020 julerrie. All rights reserved.
//

import SwiftUI

struct PageButton: View {
    @Binding var isSelected: Bool
    var buttonName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            self.action()
        }) {
            Text(buttonName)
                .foregroundColor(Color.green)
                .frame(width: 80.0, height: 40.0)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.green, lineWidth: 2)
                    
            )
            .foregroundColor(self.isSelected ? Color.white : Color.gray.opacity(0.5))
        }
    }
}
