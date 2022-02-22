//
//  NounsEngine.swift
//  Nouns
//
//  Created by Mohammed Ibrahim on 2021-10-14.
//

import Foundation
import CoreGraphics

public struct Shape: Identifiable, Hashable, Equatable {
  public var id: UUID = UUID()
  
  public let fillColor: String
  public let rect: CGRect
}

public struct Part: Identifiable, Hashable, Equatable {
  public var id: UUID = UUID()
  
  public let frame: CGRect
  public let shapes: [Shape]
}

extension CGRect: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(minX)
    hasher.combine(minY)
    hasher.combine(width)
    hasher.combine(height)
  }
}

public typealias Noun = (backgroundColor: String, seed: [Part])

public class NounsEngine {
  private let generator: NounsGenerator
  private let decoder: NounsDecoder
  
  init() throws {
    generator = try NounsGenerator()
    decoder = try NounsDecoder()
  }
  
  public func random() -> Noun {
    Noun(
      backgroundColor: generator.randomBackgroundColor(),
      seed: generator.randomSeed().map { decoder.decodeRLEImage(part: $0) }
    )
  }
  
  public subscript(withBackgroundColor bgColor: Int, body: Int, accessory: Int, head: Int, glasses: Int) -> Noun {
    Noun(
      backgroundColor: generator.backgroundColor(at: bgColor),
      seed: generator.seed(
        withBody: body,
        accessory: accessory,
        head: head,
        glasses: glasses
        
      ).map { index in
        decoder.decodeRLEImage(part: index)
      }
    )
  }
}
