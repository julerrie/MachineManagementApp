//
//  NFCReader.swift
//  MachineManagment
//
//  Created by julerrie on 2020/06/15.
//  Copyright © 2020 julerrie. All rights reserved.
//

import Foundation
import CoreNFC
import UIKit
import SwiftUI

class NFCReaderController: UIViewController, ObservableObject {
    var session: NFCNDEFReaderSession?
    var delegate: NFCNDEFReaderSessionDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func startScanning() {
        if let delegate: NFCNDEFReaderSessionDelegate = self.delegate {
            session = NFCNDEFReaderSession(delegate: delegate, queue: DispatchQueue.main, invalidateAfterFirstRead: false)
            session?.begin()
        }
    }
    
}


struct NFCReader: UIViewControllerRepresentable {
    
    
    typealias UIViewControllerType = NFCReaderController
    var reader: NFCReaderController
    
    func makeUIViewController(context: Context) -> NFCReaderController {
        reader.delegate = context.coordinator
        return reader
    }
    
    func updateUIViewController(_ uiViewController: NFCReaderController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, NFCNDEFReaderSessionDelegate {
        var parent: NFCReader
        
        init(parent: NFCReader) {
            self.parent = parent
        }
        func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
            print(error.localizedDescription)
        }
        
        func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
            for message in messages {
                for record in message.records {
                    if let string = String(data: record.payload, encoding: .ascii) {
                        print(string)
                    }
                }
            }
        }
    }
    
}
