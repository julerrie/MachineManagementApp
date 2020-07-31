//
//  ScanningViewController.swift
//  MachineManagment
//
//  Created by julerrie on 2020/05/22.
//  Copyright © 2020 julerrie. All rights reserved.
//

import UIKit
import Combine
import AVFoundation
import Vision

class ScanningViewController: UIViewController, ObservableObject, AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate{
    ///プレビュー用レイヤー
    var previewLayer: AVCaptureVideoPreviewLayer!
    var cutoutView: UIView = UIView()
    var maskLayer = CAShapeLayer()
    var initProcessFinished: Bool = false
    
    var currentOrientation = UIDeviceOrientation.portrait
    var finishedPrepared: (() -> Void)?
    private let captureSession = AVCaptureSession()
    let captureSessionQueue = DispatchQueue(label: "com.example.apple-samplecode.CaptureSessionQueue")
    
    var captureDevice: AVCaptureDevice?
    
    var videoDataOutput = AVCaptureVideoDataOutput()
    let videoDataOutputQueue = DispatchQueue(label: "com.example.apple-samplecode.VideoDataOutputQueue")
    
    var regionOfInterest = CGRect(x: 0, y: 0, width: 1, height: 1)
    var textOrientation = CGImagePropertyOrientation.up
    var bufferAspectRatio: Double!
    var uiRotationTransform = CGAffineTransform.identity
    var bottomToTopTransform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1)
    var roiToGlobalTransform = CGAffineTransform.identity
    var visionToAVFTransform = CGAffineTransform.identity
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !initProcessFinished {
            initProcessFinished = true
            self.setupVideo()
            DispatchQueue.main.async {
                self.calculateRegionOfInterest()
            }
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
            cutoutView.frame = view.bounds
            cutoutView.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
            maskLayer.backgroundColor = UIColor.clear.cgColor
            maskLayer.fillRule = .evenOdd
            cutoutView.layer.mask = maskLayer
            view.addSubview(cutoutView)
        }
        self.finishedPrepared?()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    
    func setupVideo() {
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) else {
            print("Could not create capture device.")
            return
        }
        self.captureDevice = captureDevice
        if captureDevice.supportsSessionPreset(.hd4K3840x2160) {
            captureSession.sessionPreset = AVCaptureSession.Preset.hd4K3840x2160
            bufferAspectRatio = 3840.0 / 2160.0
        } else {
            captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
            bufferAspectRatio = 1920.0 / 1080.0
        }
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            print("Could not create device input.")
            return
        }
        if captureSession.canAddInput(deviceInput) {
            captureSession.addInput(deviceInput)
        }
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
            videoDataOutput.connection(with: AVMediaType.video)?.preferredVideoStabilizationMode = .off
        } else {
            print("Could not add VDO output")
            return
        }
        do {
            try captureDevice.lockForConfiguration()
            captureDevice.videoZoomFactor = 2
            captureDevice.autoFocusRangeRestriction = .near
            captureDevice.unlockForConfiguration()
        } catch {
            print("Could not set zoom level due to error: \(error)")
            return
        }
        captureSession.startRunning()
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
    
    func setupOrientationAndTransform() {
        let roi = regionOfInterest
        roiToGlobalTransform = CGAffineTransform(translationX: roi.origin.x, y: roi.origin.y).scaledBy(x: roi.width, y: roi.height)
        textOrientation = CGImagePropertyOrientation.right
        uiRotationTransform = CGAffineTransform(translationX: 0, y: 1).rotated(by: -CGFloat.pi / 2)
        visionToAVFTransform = roiToGlobalTransform.concatenating(bottomToTopTransform).concatenating(uiRotationTransform)
    }
    
    func updateCutout() {
        let roiRectTransform = bottomToTopTransform.concatenating(uiRotationTransform)
        let cutout = previewLayer.layerRectConverted(fromMetadataOutputRect: regionOfInterest.applying(roiRectTransform))
        let path = UIBezierPath(rect: cutoutView.frame)
        path.append(UIBezierPath(rect: cutout))
        maskLayer.path = path.cgPath
        var numFrame = cutout
        numFrame.origin.y += numFrame.size.height
    }
    
    func calculateRegionOfInterest() {
        let desiredHeightRatio = 0.15
        let desiredWidthRatio = 0.6
        let maxPortraitWidth = 0.8
        let size: CGSize
        if currentOrientation.isPortrait || currentOrientation == .unknown {
            size = CGSize(width: min(desiredWidthRatio * bufferAspectRatio, maxPortraitWidth), height: desiredHeightRatio / bufferAspectRatio)
        } else {
            size = CGSize(width: desiredWidthRatio, height: desiredHeightRatio)
        }
        regionOfInterest.origin = CGPoint(x: (1 - size.width) / 2, y: (1 - size.height) / 2)
        regionOfInterest.size = size
        setupOrientationAndTransform()
        DispatchQueue.main.async {
            self.updateCutout()
        }
    }
}

extension AVCaptureVideoOrientation {
    init?(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeRight
        case .landscapeRight: self = .landscapeLeft
        default: return nil
        }
    }
}
