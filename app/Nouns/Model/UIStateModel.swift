//
//  UIStateModel.swift
//  Nouns
//
//  Created by Mohammed Ibrahim on 2021-10-12.
//

import Foundation
import SwiftUI

public class UIStateModel: ObservableObject {
  @Published var activeCard: Int = 0
  @Published var screenDrag: Float = 0.0
  @Published var numberOfItems: Int = 0
  
  var outOfBoundsLeft: Bool {
    return (activeCard - 1) < 0
  }
  
  var outOfBoundsRight: Bool {
    return (activeCard + 1) > (numberOfItems - 1)
  }
  
  init(numberOfItems: Int) {
    self.numberOfItems = numberOfItems
  }
}
