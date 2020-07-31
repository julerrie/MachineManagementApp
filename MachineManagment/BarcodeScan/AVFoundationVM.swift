//
//  AVFoundationVM.swift
//  MachineManagment
//
//  Created by julerrie on 2020/4/16.
//  Copyright © 2020 julerrie. All rights reserved.
//

//reference:https://qiita.com/From_F/items/759544896fe89e828898

import UIKit
import Combine
import AVFoundation

protocol AVMessageDelegate {
    func found(machine: MachineModel)
    func finishedPrepared()
}

class AVFoundationVM: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject, AVCaptureMetadataOutputObjectsDelegate{
    ///プレビュー用レイヤー
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var delegate: AVMessageDelegate?
    ///撮影開始フラグ
    private var _takePhoto:Bool = false
    var initProcessFinished: Bool = false
    ///セッション
    private let captureSession = AVCaptureSession()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !initProcessFinished {
            initProcessFinished = true
            setupVideo()
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
            captureSession.startRunning()
            self.delegate?.finishedPrepared()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
    
    
    func setupVideo() {
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.code39]
            
        } else {
            failed()
            return
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            DispatchQueue.main.async {
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                self.endSession()
                self.showAlertMessage(message: stringValue)
            }
        }
    }
    
    func showAlertMessage(message: String) {
        let alertView: UIAlertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okAction: UIAlertAction = UIAlertAction(title: "確認", style: .default) { _ in
            self.checkDeviceExist(id: message)
        }
        let cancleAnction: UIAlertAction = UIAlertAction (title: "戻る", style: .default) { _ in
            self.startSession()
        }
        alertView.addAction(okAction)
        alertView.addAction(cancleAnction)
        self.present(alertView, animated: true, completion: nil)
    }
    
    func checkDeviceExist(id: String) {
        if let machineModel: MachineModel = DBManager.sharedInstance.getMachineBy(id: id) {
            self.delegate?.found(machine: machineModel)
        } else {
            let alertView: UIAlertController = UIAlertController(title: "", message: "該当機器は存在しない", preferredStyle: .alert)
            let okAction: UIAlertAction = UIAlertAction(title: "確認", style: .default) { _ in
                self.captureSession.startRunning()
            }
            alertView.addAction(okAction)
            self.present(alertView, animated: true, completion: nil)
        }
    }
    
    func startSession() {
        if captureSession.isRunning { return }
        captureSession.startRunning()
    }
    
    func endSession() {
        if !captureSession.isRunning { return }
        captureSession.stopRunning()
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    func failed() {
        print("Scanning not supported")
    }
}
