//
//  NounsGenerator.swift
//  Nouns
//
//  Created by Mohammed Ibrahim on 2021-10-14.
//

import Foundation

class NounsGenerator {
  
  struct Layer: Decodable {
    let partcolors: [String]
    let bgcolors: [String]
    let parts: [[Part]]
  }
  
  struct Part: Decodable {
    let name: String
    let data: String
  }
  
  private let layer: Layer
  
  init() throws {
    guard let url = Bundle.main.url(forResource: "encoded-layers", withExtension: "json") else {
      throw URLError(.badURL)
    }
    let data = try Data(contentsOf: url)
    layer = try JSONDecoder().decode(Layer.self, from: data)
  }
  
  func randomBackgroundColor() -> String {
    layer.bgcolors[Int.random(in: 0..<layer.bgcolors.endIndex)]
  }
  
  func backgroundColor(at index: Int) -> String {
    layer.bgcolors[index]
  }
  
  func randomSeed() -> [String] {
    (0...3).compactMap { index in
      layer.parts[index].randomElement()?.data
    }
  }
  
  func seed(withBody body: Int, accessory: Int, head: Int, glasses: Int) -> [String] {
    [
      layer.parts[0][body].data,
      layer.parts[1][accessory].data,
      layer.parts[2][head].data,
      layer.parts[3][glasses].data
    ]
  }
}

