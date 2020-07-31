//
//  StringUtils.swift
//  MachineManagment
//
//  Created by julerrie on 2020/05/22.
//  Copyright © 2020 julerrie. All rights reserved.
//

import Foundation

extension Character {
    func getSimilarCharacterIfNotIn(allowedChars: String) -> Character {
        let conversionTable = [
            "s": "S",
            "S": "5",
            "5": "S",
            "o": "O",
            "Q": "O",
            "O": "0",
            "0": "O",
            "l": "I",
            "I": "1",
            "1": "I",
            "B": "8",
            "8": "B"
        ]
        let maxSubstitutions = 2
        var current = String(self)
        var counter = 0
        while !allowedChars.contains(current) && counter < maxSubstitutions {
            if let altChar = conversionTable[current] {
                current = altChar
                counter += 1
            } else {
                break
            }
        }
        
        return current.first!
    }
}

extension String {
    func extractPhoneNumber() -> (Range<String.Index>, String)? {
//        let pattern = #"""
//        (?x)                    # Verbose regex, allows comments
//        (?:\+1-?)?                # Potential international prefix, may have -
//        [(]?                    # Potential opening (
//        \b(\w{3})                # Capture xxx
//        [)]?                    # Potential closing )
//        [\ -./]?                # Potential separator
//        (\w{3})                    # Capture xxx
//        [\ -./]?                # Potential separator
//        (\w{4})\b                # Capture xxxx
//        """#
        let pattern = "^[A-Za-z]{2}[0-9]+$"
        guard let range = self.range(of: pattern, options: .regularExpression, range: nil, locale: nil) else {
            // No phone number found.
            return nil
        }
        
        // Potential number found. Strip out punctuation, whitespace and country
        // prefix.
//        var numberDigits = ""
//        let substring = String(self[range])
//        let nsrange = NSRange(substring.startIndex..., in: substring)
//        do {
//            // Extract the characters from the substring.
//            let regex = try NSRegularExpression(pattern: pattern, options: [])
//            if let match = regex.firstMatch(in: substring, options: [], range: nsrange) {
//                for rangeInd in 1 ..< match.numberOfRanges {
//                    let range = match.range(at: rangeInd)
//                    let matchString = (substring as NSString).substring(with: range)
//                    numberDigits += matchString as String
//                }
//            }
//        } catch {
//            print("Error \(error) when creating pattern")
//        }
        
        let numberDigits = String(self[range])
        //長さ設定
        guard numberDigits.count >= 5 else {
            return nil
        }
        
        var result = ""
        let allowedChars = "IN0123456789"
        for var char in numberDigits {
            char = char.getSimilarCharacterIfNotIn(allowedChars: allowedChars)
            guard allowedChars.contains(char) else {
                return nil
            }
            result.append(char)
        }
        return (range, result)
    }
}
class StringTracker {
    var frameIndex: Int64 = 0

    typealias StringObservation = (lastSeen: Int64, count: Int64)
    
    var seenStrings = [String: StringObservation]()
    var bestCount = Int64(0)
    var bestString = ""

    func logFrame(strings: [String]) {
        for string in strings {
            if seenStrings[string] == nil {
                seenStrings[string] = (lastSeen: Int64(0), count: Int64(-1))
            }
            seenStrings[string]?.lastSeen = frameIndex
            seenStrings[string]?.count += 1
            print("Seen \(string) \(seenStrings[string]?.count ?? 0) times")
        }
    
        var obsoleteStrings = [String]()

        for (string, obs) in seenStrings {
            if obs.lastSeen < frameIndex - 30 {
                obsoleteStrings.append(string)
            }
            let count = obs.count
            if !obsoleteStrings.contains(string) && count > bestCount {
                bestCount = Int64(count)
                bestString = string
            }
        }
        for string in obsoleteStrings {
            seenStrings.removeValue(forKey: string)
        }
        
        frameIndex += 1
    }
    
    func getStableString() -> String? {
        if bestCount >= 6 {
            return bestString
        } else {
            return nil
        }
    }
    
    func reset(string: String) {
        seenStrings.removeValue(forKey: string)
        bestCount = 0
        bestString = ""
    }
}
