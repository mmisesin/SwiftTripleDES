//
//  extensions.swift
//  DESCryptoProject
//
//  Created by Artem Misesin on 3/28/17.
//  Copyright © 2017 Artem Misesin. All rights reserved.
//

import Foundation

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

extension String {
    subscript (index: Int) -> Character {
        let charIndex = self.index(startIndex, offsetBy: index)
        return self[charIndex]
    }
    
    subscript (range: Range<Int>) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: range.lowerBound)
        let endIndex = self.index(self.startIndex, offsetBy: range.upperBound)
        return self[startIndex..<endIndex]
    }
    
    func replace(at index: Int, by newChar: Character) -> String {
        var chars = Array(self.characters)     // gets an array of characters
        chars[index] = newChar
        let modifiedString = String(chars)
        return modifiedString
    }
}

extension Array {
    func rotate(shift:Int) -> Array {
        var array = Array()
        if (self.count > 0) {
            array = self
            if (shift > 0) {
                for _ in 1...shift {
                    array.append(array.remove(at: 0))
                }
            }
            else if (shift < 0) {
                for _ in 1...abs(shift) {
                    array.insert(array.remove(at: array.count-1),at:0)
                }
            }
        }
        return array
    }
}
