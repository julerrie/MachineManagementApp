//
//  OCRSCannerViewController.swift
//  MachineManagment
//
//  Created by julerrie on 2020/05/22.
//  Copyright © 2020 julerrie. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Vision
import SwiftUI


protocol ShowStringDelegate {
    func showString(machine: MachineModel)
    func finishPrepared()
}

class OCRSCannerViewController: ScanningViewController {
    var request: VNRecognizeTextRequest!
    let numberTracker = StringTracker()
    var showStringDelegate: ShowStringDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        self.finishedPrepared = {
            self.showStringDelegate?.finishPrepared()
        }
    }
    func recognizeTextHandler(request: VNRequest, error: Error?) {
        var numbers = [String]()
        var redBoxes = [CGRect]()
        var greenBoxes = [CGRect]()
        
        guard let results = request.results as? [VNRecognizedTextObservation] else {
            return
        }
        
        let maximumCandidates = 1
        
        for visionResult in results {
            guard let candidate = visionResult.topCandidates(maximumCandidates).first else { continue }
            var numberIsSubstring = true
            
            if let result = candidate.string.extractPhoneNumber() {
                let (range, number) = result
                if let box = try? candidate.boundingBox(for: range)?.boundingBox {
                    numbers.append(number)
                    greenBoxes.append(box)
                    numberIsSubstring = !(range.lowerBound == candidate.string.startIndex && range.upperBound == candidate.string.endIndex)
                }
            }
            if numberIsSubstring {
                redBoxes.append(visionResult.boundingBox)
            }
        }
        
        numberTracker.logFrame(strings: numbers)
        show(boxGroups: [(color: UIColor.red.cgColor, boxes: redBoxes), (color: UIColor.green.cgColor, boxes: greenBoxes)])
        if let sureNumber = numberTracker.getStableString() {
            DispatchQueue.main.async {
                self.endSession()
                self.showAlertMessage(message: sureNumber)
            }
        }
    }
    var boxLayer = [CAShapeLayer]()
    func draw(rect: CGRect, color: CGColor) {
        let layer = CAShapeLayer()
        layer.opacity = 0.5
        layer.borderColor = color
        layer.borderWidth = 1
        layer.frame = rect
        boxLayer.append(layer)
        previewLayer.insertSublayer(layer, at: 1)
    }
    
    func removeBoxes() {
        for layer in boxLayer {
            layer.removeFromSuperlayer()
        }
        boxLayer.removeAll()
    }
    
    typealias ColoredBoxGroup = (color: CGColor, boxes: [CGRect])
    
    func show(boxGroups: [ColoredBoxGroup]) {
        DispatchQueue.main.async {
            let layer = self.previewLayer
            self.removeBoxes()
            for boxGroup in boxGroups {
                let color = boxGroup.color
                for box in boxGroup.boxes {
                    let rect = layer?.layerRectConverted(fromMetadataOutputRect: box.applying(self.visionToAVFTransform))
                    self.draw(rect: rect ?? CGRect(), color: color)
                }
            }
        }
    }
    
    func showAlertMessage(message: String) {
        let alertView: UIAlertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okAction: UIAlertAction = UIAlertAction(title: "確認", style: .default) { _ in
            self.checkDeviceExist(id: message)
        }
        let cancleAnction: UIAlertAction = UIAlertAction (title: "戻る", style: .default) { _ in
            self.numberTracker.reset(string: message)
            self.startSession()
        }
        alertView.addAction(okAction)
        alertView.addAction(cancleAnction)
        self.present(alertView, animated: true, completion: nil)
    }
    
    func checkDeviceExist(id: String) {
        if let machineModel: MachineModel = DBManager.sharedInstance.getMachineBy(id: id) {
            self.showStringDelegate?.showString(machine: machineModel)
            self.numberTracker.reset(string: id)
        } else {
            let alertView: UIAlertController = UIAlertController(title: "", message: "該当機器は存在しない", preferredStyle: .alert)
            let okAction: UIAlertAction = UIAlertAction(title: "確認", style: .default) { _ in
                self.numberTracker.reset(string: id)
                self.startSession()
            }
            alertView.addAction(okAction)
            self.present(alertView, animated: true, completion: nil)
        }
    }
}


extension OCRSCannerViewController {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = false
            request.regionOfInterest = regionOfInterest
            
            let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: textOrientation, options: [:])
            do {
                try requestHandler.perform([request])
            } catch {
                print(error)
            }
        }
    }
}
