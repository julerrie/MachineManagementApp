//
//  BarcodeScanView.swift
//  MachineManagment
//
//  Created by julerrie on 2020/4/16.
//  Copyright © 2020 julerrie. All rights reserved.
//

import SwiftUI
import AVFoundation

struct BarcodeScanView: View {
    @ObservedObject private var avFoundationVM = AVFoundationVM()
    @State var isDetected: Bool = false
    @State var machineModel: MachineModel = MachineModel()
    @State var prepared: Bool = false
    @EnvironmentObject var userSettings: UserSettings
    var body: some View {
        VStack(spacing: 20.0) {
            VStack(spacing: 30.0) {
                Text(userSettings.department)
                    .font(.headline)
            }
            VStack(spacing: 20.0) {
                NavigationLink(destination: DetailView(machine: machineModel, codeString: machineModel.managementId), isActive: $isDetected, label: {
                    EmptyView()
                    
                })
                ZStack {
                    ActivityIndicator(isAnimating: .constant(true), style: .large)
                        .opacity($prepared.wrappedValue ? 0:1)
                    ScannerView(scanner: self.avFoundationVM, isDetected: self.$isDetected, machineMode: self.$machineModel, prepared: self.$prepared)
                        .frame(width: 350.0)
                }
                
                NavigationLink(destination: KeyboardInputView()) {
                    Text("入力切替")
                        .foregroundColor(Color.green)
                        .frame(width: 200.0, height: 40.0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.green, lineWidth: 2)
                    )
                }
            }
            Spacer()
        }
        .padding(.top, 50.0)
        .navigationBarTitle("機器照合", displayMode: .inline)
    }
}

final class BarcodeScanViewBuilder {
    static func make() -> some View {
        DeferView {
           BarcodeScanView()
        }
    }
}
