//
//  ARPresentView.swift
//  MachineManagment
//
//  Created by julerrie on 2020/05/07.
//  Copyright © 2020 julerrie. All rights reserved.
//

import SwiftUI
import ARKit

struct ARPresentView: View{
    @ObservedObject private var arViewController = ARViewController()
    @State var message: String? = ""
    @State var showAlert: Bool = false
    @State var anchorList: [ARAnchor]? = []
    @State var prepared: Bool = false
    @State var buttonAvaliable: Bool = true
    @State var turnToMapView: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @State var fromMenu: Bool = true
    
    var body: some View {
        ZStack {
            ZStack {
                ARView(message: $message, buttonAvaliable: $buttonAvaliable, view: arViewController)
                    .onAppear {
                        self.arViewController.initProcess()
                        self.buttonAvaliable = false
                }
                .onDisappear {
                    self.arViewController.cleanProcess()
                }
            }
            VStack(spacing: 30.0){
                HStack {
                    Button(action: {
                        self.arViewController.saveBarButtonItemDidTouch()
                    }){
                        Text("保存")
                            .foregroundColor(Color.green)
                            .frame(width: 100, height: 40.0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.green, lineWidth: 2))
                            .background(Color.white)
                        .cornerRadius(10)
                    }.disabled(!$buttonAvaliable.wrappedValue)
                    
                    Button(action: {
                        self.arViewController.resetTrackingConfiguration()
                    }) {
                        Text("レセット")
                            .foregroundColor(Color.green)
                            .frame(width: 100, height: 40.0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.green, lineWidth: 2))
                            .background(Color.white)
                        .cornerRadius(10)
                    }.disabled(!$buttonAvaliable.wrappedValue)
                    
                    Button(action: {
                        self.arViewController.loadBarButtonItemDidTouch()
                    }) {
                        Text("ロード")
                            .foregroundColor(Color.green)
                            .frame(width: 100, height: 40.0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.green, lineWidth: 2))
                            .background(Color.white)
                        .cornerRadius(10)
                    }.disabled(!$buttonAvaliable.wrappedValue)
                }
                Button(action: {
                    if self.fromMenu {
                        self.turnToMapView = true
                    } else {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text("画面切り替え")
                }
                .foregroundColor(Color.green)
                .frame(width: 300, height: 40.0)
                .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.green, lineWidth: 2))
                    .background(Color.white)
                .cornerRadius(10)
                NavigationLink(destination: MapDirectionView(fromDetail: false, showAlert: true, machine: nil), isActive: $turnToMapView) {
                    EmptyView()
                }
            }
             .padding(.top, 500)
        }
        .navigationBarTitle("機器位置確認", displayMode: .inline)
    }
}

final class ARPresentViewBuilder {
    static func make(fromMenu: Bool) -> some View {
        DeferView {
           ARPresentView(fromMenu: fromMenu)
        }
    }
}
