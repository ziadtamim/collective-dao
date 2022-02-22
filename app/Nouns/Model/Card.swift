//
//  Card.swift
//  Nouns
//
//  Created by Mohammed Ibrahim on 2021-10-12.
//

import Foundation

struct Card: Decodable, Hashable, Identifiable {
  var id: Int
  var name: String = ""
}
