//
//  NounsDecoder.swift
//  NounsServices
//
//  Created by Ziad Tamim on 13.10.21.
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
        let bytes = Data(hex: part)!.bytes
        
        _ = bytes[0] // Palette Index
        let frame = CGRect(
            x: Int(bytes[1]),
            y: Int(bytes[4]),
            width: Int(bytes[2]),
            height: Int(bytes[3])
        )
        
        var currentX = frame.minX
        var currentY = frame.minY
        
        var shapes = [Shape]()
        for i in stride(from: 5, to: bytes.endIndex, by: 2) {
            let color = palette[Int(bytes[i+1])]
            let width = CGFloat(bytes[i])
            
            if !color.isEmpty {
                let rect = CGRect(
                    x: currentX, y: currentY,
                    width: frame.width, height: 1
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
