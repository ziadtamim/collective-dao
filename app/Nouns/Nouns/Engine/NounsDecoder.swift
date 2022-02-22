//
//  NounsDecoder.swift
//  Nouns
//
//  Created by Mohammed Ibrahim on 2021-10-14.
//

import Foundation
import CoreGraphics

class NounsDecoder {
  private let palette: [String]
  
  init() throws {
    let url = Bundle.main.url(forResource: "encoded-colors", withExtension: "json")!
    let data = try Data(contentsOf: url)
    palette = try JSONDecoder().decode([String].self, from: data)
  }
  
  func decodeRLEImage(part: String) -> Part {
    var part = part
    if part.hasPrefix("0x") {
      part = String(part.dropFirst(2))
    }
    let bytes = Data(hex: part)!.bytesBuffer
    //        print(bytes)
    _ = bytes[0] // Palette Index
    let frame = CGRect(
      x: Int(bytes[4]),
      y: Int(bytes[1]),
      width: Int(bytes[2]),
      height: Int(bytes[3])
    )
    
    //let frame = (top: Int(bytes[1]), left: Int(bytes[4]), right: Int(bytes[2]), bottom: Int(bytes[3]))
    
    var currentX = frame.minX//frame.left //frame.minX
    var currentY = frame.minY //frame.top //frame.minY
    
    var shapes = [Shape]()
    for i in stride(from: 5, to: bytes.endIndex, by: 2) {
      let color = palette[Int(bytes[i+1])]
      let width = CGFloat(bytes[i])
      
      if !color.isEmpty {
        let rect = CGRect(
          x: currentX,
          y: currentY,
          width: width,
          height: 1
        )
        
        shapes.append(Shape(fillColor: color, rect: rect))
      }
      
      currentX += width
      if (currentX == frame.width) {
        currentX = frame.minX
        currentY += 1
      }
    }
    
    return Part(frame: frame, shapes: shapes)
  }
}
