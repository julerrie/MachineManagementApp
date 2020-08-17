//
//  MotionManager.swift
//  MachineManagment
//
//  Created by julerrie on 2020/08/06.
//  Copyright © 2020 julerrie. All rights reserved.
//

import Foundation
import CoreMotion
import SwiftUI

class MotionManager: ObservableObject {
    
    var motionManager: CMMotionManager!
    var initialAttitude : CMAttitude!
    @Published var xChange: Float = 0
    @Published var yChange: Float = 0
    
    public init() {
        motionManager = CMMotionManager()
    }
    
    public func getMotionInformation() {
        if motionManager.isAccelerometerAvailable{
            let queue = OperationQueue()
            motionManager.accelerometerUpdateInterval = 0.5
//            motionManager.deviceMotionUpdateInterval = 0.5
//            motionManager.startDeviceMotionUpdates(to: queue, withHandler:{ (data, error) in
//                if self.initialAttitude != nil {
//                    data?.attitude.multiply(byInverseOf: self.initialAttitude)
//
//                    // calculate magnitude of the change from our initial attitude
//                    let magnitude = self.magnitudeFromAttitude(attitude: data?.attitude)
//                    let initMagnitude = self.magnitudeFromAttitude(attitude: self.initialAttitude)
//
//                    if magnitude - initMagnitude > 0.1 // threshold
//                    {
//                        print(magnitude - initMagnitude)
//                        self.initialAttitude  = self.motionManager.deviceMotion?.attitude
//
//                    }
//                } else {
//                    self.initialAttitude = self.motionManager.deviceMotion?.attitude
//                }
//            })
//            print(self.motionManager.isDeviceMotionActive) // print false
            
//                        let queue = OperationQueue()
//                        motionManager.deviceMotionUpdateInterval = 0.5
//                        motionManager.showsDeviceMovementDisplay = true
//                        motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical,
//                              to: queue, withHandler: { (data, error) in
//                            if let validData = data {
//                                let roll = validData.attitude.roll
//                                let pitch = validData.attitude.pitch
//                                let yaw = validData.attitude.yaw
//                                print(pitch, roll, yaw)
//                            }
//                        })
            
            // Use the motion data in your app.
//            }
            
            motionManager.startAccelerometerUpdates(to: queue, withHandler:
                {data, error in

                    guard let data = data else{
                        return
                    }
                    print("X = \(data.acceleration.x)")
                    print("Y = \(data.acceleration.y)")
                    print(" ")
                    DispatchQueue.main.async {
                        self.xChange = Float(data.acceleration.x*100)
                        self.yChange = Float(data.acceleration.y*100)
                    }

                }
            )
            
//            self.motionManager.magnetometerUpdateInterval = 1
//            self.motionManager.showsDeviceMovementDisplay = true
//            self.motionManager.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xTrueNorthZVertical, to: queue, withHandler: { (deviceMotion, error) in
//                // If no device-motion data is available, the value of this property is nil.
//                if let motion = deviceMotion {
//                    let accuracy = motion.magneticField.accuracy
//                    let x = motion.magneticField.field.x
//                    let y = motion.magneticField.field.y
//                    let z = motion.magneticField.field.z
//                    print("accuracy: \(accuracy.rawValue), x: \(x), y: \(y), z: \(z)")
//                }
//                else {
//                    print("Device motion is nil.")
//                }
//            })
        } else {
            print("Accelerometer is not available")
        }
    }
    
    // get magnitude of vector via Pythagorean theorem
    func magnitudeFromAttitude(attitude: CMAttitude?) -> Double {
        if let attitude: CMAttitude = attitude {
            return sqrt(pow(attitude.roll, 2) + pow(attitude.yaw, 2) + pow(attitude.pitch, 2))
        }
        return 0
    }
    
    func stopMotionDetection() {
        self.motionManager.stopAccelerometerUpdates()
    }
}



