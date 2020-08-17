//
//  extension.swift
//  MachineManagment
//
//  Created by julerrie on 2020/05/14.
//  Copyright © 2020 julerrie. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

extension UIColor {
    open class var transparentWhite: UIColor {
        return UIColor.white.withAlphaComponent(0.70)
    }
}

extension UserDefaults {
  var currentLocation: CLLocation {
    get { return CLLocation(latitude: latitude ?? 90, longitude: longitude ?? 0) } // default value is North Pole (lat: 90, long: 0)
    set { latitude = newValue.coordinate.latitude
          longitude = newValue.coordinate.longitude }
  }
  
  private var latitude: Double? {
    get {
      if let _ = object(forKey: #function) {
        return double(forKey: #function)
      }
      return nil
    }
    set { set(newValue, forKey: #function) }
  }
  
  private var longitude: Double? {
    get {
      if let _ = object(forKey: #function) {
        return double(forKey: #function)
      }
      return nil
    }
    set { set(newValue, forKey: #function) }
  }
}
