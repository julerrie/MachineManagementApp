//
//  ARView.swift
//  MachineManagment
//
//  Created by julerrie on 2020/05/07.
//  Copyright © 2020 julerrie. All rights reserved.
//

import Foundation
import SwiftUI
import ARKit


struct ARView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = ARViewController
    
    @Binding var message: String?
    @Binding var buttonAvaliable: Bool
    
    var view: ARViewController
    
    func makeUIViewController(context: Context) -> ARViewController {
        view.arViewPresentDelegate = context.coordinator
        return view
    }
    
    func updateUIViewController(_ uiViewController: ARViewController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, ARViewPresentDelegate {
        
        var parent: ARView
        
        init(parent: ARView) {
            self.parent = parent
        }
        
        func setMessage(text: String) {
            self.parent.message = text
            print(text)
        }
        func setButtonAvaliable(avaliable: Bool) {
            self.parent.buttonAvaliable = avaliable
        }
    }
    
}
