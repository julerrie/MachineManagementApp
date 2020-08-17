//
//  MapDirectionView.swift
//  MachineManagment
//
//  Created by julerrie on 2020/07/30.
//  Copyright © 2020 julerrie. All rights reserved.
//

import SwiftUI
import LocationProvider

struct MapDirectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var turnToARView: Bool = false
    @State var scale: CGFloat = 1.0
    @State var fromDetail: Bool = true
    @State private var offset = CGSize.zero
    @State var position = CGPoint.zero
    @State var showAlert: Bool = false
    @State var placeDecided: Bool = false
    @State var imageSize: CGSize = CGSize(width: 300, height: 500)
    @State var circleSize: CGSize = CGSize(width: 20, height: 20)
    @State var placeAlert: Bool = false
//  @ObservedObject var locationProvider : LocationProvider
    @EnvironmentObject var motionManager: MotionManager
    var removal: (() -> Void)? = nil
    var machine: MachineModel?
    var destinationPoint: CGPoint?

    init(fromDetail: Bool, showAlert: Bool, machine: MachineModel?) {
        if let machine: MachineModel = machine {
            self.machine = machine
            self.destinationPoint = CGPoint(x: Int(machine.worldMapx) ?? 0, y: Int(machine.worldMapy) ?? 0)
        }
        self.fromDetail = fromDetail
        self.showAlert = showAlert
    }
    
//    init(fromDetail: Bool, showAlert: Bool) {
//        locationProvider = LocationProvider()
//        self.fromDetail = fromDetail
//        self.showAlert = showAlert
//        do {try locationProvider.start()}
//        catch {
//            print("No location access.")
//            locationProvider.requestAuthorization()
//        }
//    }
//    
    var body: some View {
        VStack(spacing: 30.0) {
            ZStack {
                Image("FloorMap")
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(scale)
                    .frame(width: imageSize.width, height: imageSize.height, alignment: .center)
                    .offset(x: offset.width, y: offset.height)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                if self.$placeDecided.wrappedValue {
                                    self.offset = gesture.translation
                                } else {
                                    self.position = gesture.location
                                }
                            }
                    )
                Circle()
                    .frame(width: circleSize.width, height: circleSize.height)
                    .offset(x: offset.width + CGFloat(motionManager.xChange), y: offset.height + CGFloat(motionManager.yChange))
                    .position($position.wrappedValue)
                if self.destinationPoint != nil {
                    Circle()
                        .fill(Color.red)
                        .frame(width: circleSize.width, height: circleSize.height)
                        .offset(x: offset.width, y: offset.height)
                        .position(self.destinationPoint ?? CGPoint.zero)
                }
                
            }
            .frame(width: 300, height: 500, alignment: .center)
            HStack(spacing: 40.0) {
                Button(action: {
                    self.imageSize.width *= 1.1
                    self.imageSize.height *= 1.1
                    self.circleSize.width *= 1.1
                    self.circleSize.height *= 1.1
                }) {
                    Text("+")
                        .font(.title)
                }
                .foregroundColor(Color.green)
                .frame(width: 60, height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.green, lineWidth: 2))
                .background(Color.white)
                .cornerRadius(10)
                Button(action: {
                    self.imageSize.width *= 0.9
                    self.imageSize.height *= 0.9
                    self.circleSize.width *= 0.9
                    self.circleSize.height *= 0.9
                }) {
                    Text("-")
                        .font(.title)
                }
                .foregroundColor(Color.green)
                .frame(width: 60, height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.green, lineWidth: 2))
                .background(Color.white)
                .cornerRadius(10)
                
            }
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
            .background(Color.white)
            .cornerRadius(10)
            .alert(isPresented: $showAlert) { () -> Alert in
                Alert(title: Text(""), message: Text("現在地を設定してください"), dismissButton:.default(Text("確認")))
            }
            
            Button(action: {
                self.placeDecided = true
                self.placeAlert = true
            }) {
                Text("確認")
            }
            .foregroundColor(Color.green)
            .frame(width: 250, height: 40.0)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.green, lineWidth: 2))
            .background(Color.white)
            .cornerRadius(10)
            .alert(isPresented: $placeAlert) { () -> Alert in
                Alert(title: Text(""), message: Text("現在地を設定しました。"), dismissButton:.default(Text("確認"), action: {
                    self.motionManager.getMotionInformation()
                }))
            }
            NavigationLink(destination: ARPresentViewBuilder.make(fromMenu: false), isActive: $turnToARView) {
                EmptyView()
            }
            .padding(.bottom, 50.0)
        }
        .navigationBarTitle("フロアガイド", displayMode: .inline)
    }
}

//struct MapDirectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapDirectionView()
//    }
//}
