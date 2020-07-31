//
//  OCRScannerView.swift
//  MachineManagment
//
//  Created by julerrie on 2020/05/22.
//  Copyright © 2020 julerrie. All rights reserved.
//

import Foundation
import SwiftUI

struct OCRScannerView: UIViewControllerRepresentable {
    
    
    typealias UIViewControllerType = OCRSCannerViewController
    @Binding var isDetected: Bool
    @Binding var machineModel: MachineModel
    @Binding var prepared: Bool
    var scanner: OCRSCannerViewController
    func makeUIViewController(context: Context) -> OCRSCannerViewController {
        scanner.showStringDelegate = context.coordinator
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: OCRSCannerViewController, context: Context) {
        
    }
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, ShowStringDelegate {
        var parent: OCRScannerView
        
        init(parent: OCRScannerView) {
            self.parent = parent
        }
        
        func showString(machine: MachineModel) {
            self.parent.machineModel = machine
            self.parent.isDetected = true
        }
        
        func finishPrepared() {
            self.parent.prepared = true
        }
        
        
    }
}
