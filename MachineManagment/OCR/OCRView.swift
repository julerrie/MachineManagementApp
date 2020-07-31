//
//  OCRView.swift
//  MachineManagment
//
//  Created by julerrie on 2020/05/22.
//  Copyright © 2020 julerrie. All rights reserved.
//

import SwiftUI
import Combine

struct OCRView: View {
    @ObservedObject private var ocrScanner = OCRSCannerViewController()
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
                NavigationLink(destination: DetailView(machine: machineModel, codeString: machineModel.managementId, showingAlert: false, buttonAvaliable: true), isActive: $isDetected, label: {
                    EmptyView()
                })
                ZStack {
                ActivityIndicator(isAnimating: .constant(true), style: .large)
                    .opacity($prepared.wrappedValue ? 0:1)
                    OCRScannerView(isDetected: $isDetected, machineModel: $machineModel, prepared: $prepared, scanner: ocrScanner)
                    .frame(width: 350.0)
                }
            }
            Spacer()
        }
        .padding(.top, 50.0)
        .navigationBarTitle("OCR", displayMode: .inline)
    }
}

struct OCRView_Previews: PreviewProvider {
    static var previews: some View {
        OCRView()
    }
}

final class OCRViewBuilder {
    static func make() -> some View {
        DeferView {
           OCRView()
        }
    }
}
