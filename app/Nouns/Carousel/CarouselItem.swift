//
//  CarouselItem.swift
//  Nouns
//
//  Created by Mohammed Ibrahim on 2021-10-12.
//

import SwiftUI

struct CarouselItem<Content: View>: View {
  @EnvironmentObject var UIState: UIStateModel
  let cardWidth: CGFloat
  let cardHeight: CGFloat
  
  var _id: Int
  var content: Content
  
  var section: Section
  
  @inlinable public init(
  _id: Int,
  spacing: CGFloat,
  widthOfHiddenCards: CGFloat,
  cardHeight: CGFloat,
  section: Section,
  @ViewBuilder _ content: () -> Content
  ) {
    self.content = content()
    self.cardWidth = UIScreen.main.bounds.width - (widthOfHiddenCards * 2) - (spacing * 2)
    self.cardHeight = cardHeight
    self._id = _id
    self.section = section
  }
  
  var body: some View {
    content
      .frame(width: cardWidth, height: cardHeight, alignment: .center)
  }
}
