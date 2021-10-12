//
//  SnapCarousel.swift
//  Nouns
//
//  Created by Mohammed Ibrahim on 2021-10-11.
//

import SwiftUI

enum Section {
  case top
  case topMiddle
  case bottomMiddle
  case bottom
}

enum CarouselSelection: String {
  case head = "Head"
  case body = "Body"
  case glasses = "Glasses"
  case accessory = "Accessory"
  
  var color: UIColor {
    switch self {
    case .head:
      return UIColor.systemRed
    case .body:
      return UIColor.systemMint
    case .glasses:
      return UIColor.systemOrange
    case .accessory:
      return UIColor.systemTeal
    }
  }
}

struct SnapCarousel: View {
  @EnvironmentObject var UIState: UIStateModel
  
  var section: Section = .top
  var selection: CarouselSelection
  
  var body: some View {
    let spacing: CGFloat = 16
    let widthOfHiddenCards: CGFloat = 60 /// UIScreen.main.bounds.width - 10
    let cardHeight: CGFloat = 550
    
    let items: [Card] = {
      return (0...20).map { Card(id: $0, name: String($0)) }
    }()
    
    return Canvas {
      Carousel(
        numberOfItems: CGFloat(items.count),
        spacing: spacing,
        widthOfHiddenCards: widthOfHiddenCards
      ) {
        ForEach(items, id: \.self.id) { item in
          Item(
            _id: Int(item.id),
            spacing: spacing,
            widthOfHiddenCards: widthOfHiddenCards,
            cardHeight: cardHeight,
            section: .top
          ) {
            Text("\(item.name)")
          }
          .foregroundColor(Color.white)
          .background(Color(uiColor: selection.color))
          .cornerRadius(8)
          .transition(AnyTransition.slide)
          .animation(.spring())
        }
      }
    }
  }
}

struct Card: Decodable, Hashable, Identifiable {
  var id: Int
  var name: String = ""
}

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

struct Carousel<Items: View>: View {
  let items: Items
  let numberOfItems: CGFloat
  let spacing: CGFloat
  let widthOfHiddenCards: CGFloat
  let totalSpacing: CGFloat
  let cardWidth: CGFloat
  
  @GestureState var isDetectingLongPress = false
  
  @EnvironmentObject var UIState: UIStateModel
  
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

struct Canvas<Content: View>: View {
  let content: Content
  @EnvironmentObject var UIState: UIStateModel
  
  @inlinable init(@ViewBuilder _ content: () -> Content) {
    self.content = content()
  }
  
  var body: some View {
    content
      .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
  }
}

struct Item<Content: View>: View {
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
    self.cardWidth = UIScreen.main.bounds.width - (widthOfHiddenCards * 2) - (spacing * 2) //279
    self.cardHeight = cardHeight
    self._id = _id
    self.section = section
  }
  
  var body: some View {
    content
      .frame(width: cardWidth, height: cardHeight, alignment: .center)
  }
}

struct SnapCarousel_Previews: PreviewProvider {
  static var previews: some View {
    SnapCarousel(selection: .head)
  }
}
