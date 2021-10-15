//
//  Extensions.swift
//  Nouns
//
//  Created by Mohammed Ibrahim on 2021-10-14.
//

import Foundation
import UIKit

// swiftlint:disable all
extension UIColor {
  convenience init(hexString: String, alpha: CGFloat = 1.0) {
    let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    let scanner = Scanner(string: hexString)
    if (hexString.hasPrefix("#")) {
      scanner.scanLocation = 1
    }
    var color: UInt32 = 0
    scanner.scanHexInt32(&color)
    let mask = 0x000000FF
    let r = Int(color >> 16) & mask
    let g = Int(color >> 8) & mask
    let b = Int(color) & mask
    let red   = CGFloat(r) / 255.0
    let green = CGFloat(g) / 255.0
    let blue  = CGFloat(b) / 255.0
    self.init(red:red, green:green, blue:blue, alpha:alpha)
  }
}

typealias Bytes = [UInt8]

extension Data {
  
  init?(hex: String) {
    let len = hex.count / 2
    var data = Data(capacity: len)
    var i = hex.startIndex
    for _ in 0..<len {
      let j = hex.index(i, offsetBy: 2)
      let bytes = hex[i..<j]
      guard var num = UInt8(bytes, radix: 16) else {
        return nil
      }
      data.append(&num, count: 1)
      i = j
    }
    self = data
  }
  
  var bytesBuffer: Bytes {
    var byteBuffer = Bytes()
    withUnsafeBytes( {
      byteBuffer.append(contentsOf: $0)
    })
    return byteBuffer
  }
}
