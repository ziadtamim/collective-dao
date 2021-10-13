//
//  Carousel.swift
//  Nouns
//
//  Created by Mohammed Ibrahim on 2021-10-12.
//

import SwiftUI
import Combine

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

struct Carousel<Items: View>: View {
  let items: Items
  let numberOfItems: CGFloat
  let spacing: CGFloat
  let widthOfHiddenCards: CGFloat
  let totalSpacing: CGFloat
  let cardWidth: CGFloat
  
  let detector: CurrentValueSubject<CGFloat, Never>
  let publisher: AnyPublisher<CGFloat, Never>
  
  @GestureState var isDetectingLongPress = false
  
  @EnvironmentObject var UIState: UIStateModel
  
  @State var scrollableWidth: CGFloat = 0.0
  
  let imageSize: CGSize = CGSize(width: 200, height: 200)
  let screenWidth = UIScreen.main.bounds.width
  
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
    
    let detector = CurrentValueSubject<CGFloat, Never>(0)
    self.publisher = detector
        .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
        .dropFirst()
        .eraseToAnyPublisher()
    self.detector = detector
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
    
    return ScrollViewReader { reader in
      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(alignment: .center, spacing: spacing) {
          items
        }.padding(.horizontal, (spacing + 100))
        .background(GeometryReader { proxy in
                        Color.clear.preference(key: ViewOffsetKey.self,
                                               value: -proxy.frame(in: .named("scroll")).origin.x).onAppear {
                          scrollableWidth = proxy.size.width
                          print("width: \(scrollableWidth)")
                        }
                    })
        .onPreferenceChange(ViewOffsetKey.self) { detector.send($0) }
      }.coordinateSpace(name: "scroll")
        .onReceive(publisher) { value in
          let centeredPos = value + (screenWidth / 2)
          let closest = Int(round((centeredPos - totalSpacing - (100 + spacing)) / cardWidth)) - 1 // minus 1 for index value
          
          withAnimation(.easeOut) {
            reader.scrollTo(closest, anchor: .center)
          }
        }
    }
  }
}
