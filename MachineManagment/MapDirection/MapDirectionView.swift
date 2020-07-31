//
//  MapDirectionView.swift
//  MachineManagment
//
//  Created by julerrie on 2020/07/30.
//  Copyright © 2020 julerrie. All rights reserved.
//

import SwiftUI

struct MapDirectionView: View {
    
    @State var turnToARView: Bool = false
    @GestureState var scale: CGFloat = 1.0
    @State var fromDetail: Bool = true
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack {
            Image("FloorMap")
                .resizable()
                .scaledToFill()
                .frame(width: 300, height: 400)
                .scaleEffect(scale)
                .gesture(MagnificationGesture()
                    .updating($scale, body: { (value, scale, trans) in
                        scale = value.magnitude
                    })
            )
            Spacer()
            Button(action: {
                if self.fromDetail {
                    self.turnToARView = true
                } else {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }) {
                Text("画面切り替え")
            }
            .foregroundColor(Color.green)
            .frame(width: 250, height: 40.0)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.green, lineWidth: 2))
            
            NavigationLink(destination: ARPresentViewBuilder.make(fromMenu: false), isActive: $turnToARView) {
                EmptyView()
            }
            .padding(.bottom, 100.0)
        }
        .navigationBarTitle("フロアガイド", displayMode: .inline)
    }
}

struct MapDirectionView_Previews: PreviewProvider {
    static var previews: some View {
        MapDirectionView()
    }
}
