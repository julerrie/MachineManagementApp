//
//  NavigationARView.swift
//  MachineManagment
//
//  Created by julerrie on 2020/08/27.
//  Copyright © 2020 julerrie. All rights reserved.
//

import Foundation
import SwiftUI
import ARKit


struct NavigationARView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = ARViewController
    
    @Binding var distanceX: Float
    @Binding var distanceY: Float
    
    var view: ARViewController
    
    func makeUIViewController(context: Context) -> ARViewController {
        view.mapDirectionDelegate = context.coordinator
        return view
    }
    
    func updateUIViewController(_ uiViewController: ARViewController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, MapDirectionDelegate {
        
        func setDistance(x: Float, y: Float) {
            self.parent.distanceX = x
            self.parent.distanceY = y
        }
        
        
        var parent: NavigationARView
        
        init(parent: NavigationARView) {
            self.parent = parent
            
        }
        
        
        
        
        
    }
    
}
