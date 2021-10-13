//
//  Carousel.swift
//  Nouns
//
//  Created by Mohammed Ibrahim on 2021-10-12.
//

import SwiftUI

struct Carousel<Items: View>: View {
  let items: Items
  let numberOfItems: CGFloat
  let spacing: CGFloat
  let widthOfHiddenCards: CGFloat
  let totalSpacing: CGFloat
  let cardWidth: CGFloat
  
  @GestureState var isDetectingLongPress = false
  
  @EnvironmentObject var UIState: UIStateModel
  
  let imageSize: CGSize = CGSize(width: 200, height: 200)
  
  @inlinable public init(
  numberOfItems: CGFloat,
  spacing: CGFloat,
  widthOfHiddenCards: CGFloat,
  @ViewBuilder _ items: () -> Items) {
    self.items = items()
    self.numberOfItems = numberOfItems
    self.spacing = spacing
    self.widthOfHiddenCards = widthOfHiddenCards
    self.totalSpacing = (numberOfItems - 1) * spacing
    self.cardWidth = UIScreen.main.bounds.width - (widthOfHiddenCards * 2) - (spacing * 2)
  }
  
  var body: some View {
    let totalCanvasWidth: CGFloat = (cardWidth * numberOfItems) + totalSpacing
    let xOffsetToShift = (totalCanvasWidth - UIScreen.main.bounds.width) / 2
    let leftPadding = widthOfHiddenCards + spacing
    let totalMovement = cardWidth + spacing
    
    let activeOffset = xOffsetToShift + (leftPadding) - (totalMovement * CGFloat(UIState.activeCard))
    let nextOffset = xOffsetToShift + (leftPadding) - (totalMovement * CGFloat(UIState.activeCard) + 1)
    
    var calcOffset = Float(activeOffset)
    
    if calcOffset != Float(nextOffset) {
      calcOffset = Float(activeOffset) + UIState.screenDrag
    }
    
    return LazyHStack(alignment: .center, spacing: spacing) {
      items
    }
    .offset(x: CGFloat(calcOffset), y: 0)
    .gesture(DragGesture().updating($isDetectingLongPress) { currentState, gestureState, transaction in
      self.UIState.screenDrag = Float(currentState.translation.width)
    }.onEnded { value in
      let endLocation = min(max(0, value.predictedEndLocation.x), totalCanvasWidth)
      let endLocationWithoutSpacing = endLocation - totalSpacing
      print(endLocation / cardWidth)
      self.UIState.screenDrag = 0
      
      if value.translation.width < -50 {
        guard !self.UIState.outOfBoundsRight else { return }
        self.UIState.activeCard += 1
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        impactMed.impactOccurred()
      }
      
      if value.translation.width > 50 {
        guard !self.UIState.outOfBoundsLeft else { return }
        self.UIState.activeCard -= 1
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        impactMed.impactOccurred()
      }
    })
  }
}
