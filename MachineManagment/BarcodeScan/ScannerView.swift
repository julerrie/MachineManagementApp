//
//  CALayerView.swift
//  MachineManagment
//
//  Created by julerrie on 2020/4/16.
//  Copyright © 2020 julerrie. All rights reserved.
//

import SwiftUI
import AVFoundation

struct ScannerView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = AVFoundationVM
    
    var scanner: AVFoundationVM
    @Binding var isDetected: Bool
    @Binding var machineMode: MachineModel
    @Binding var prepared: Bool

    func makeUIViewController(context: UIViewControllerRepresentableContext<ScannerView>) -> AVFoundationVM {
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: AVFoundationVM, context: UIViewControllerRepresentableContext<ScannerView>) {
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    
    class Coordinator: NSObject, AVMessageDelegate {
        var parent: ScannerView
        init(parent: ScannerView) {
            self.parent = parent
        }

        func found(machine: MachineModel) {
            self.parent.isDetected = true
            self.parent.machineMode = machine
        }
        
        func finishedPrepared() {
            self.parent.prepared = true
        }
    }
    
}

