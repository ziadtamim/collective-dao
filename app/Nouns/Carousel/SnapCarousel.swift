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
      return UIColor.clear
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
    let widthOfHiddenCards: CGFloat = 50 /// UIScreen.main.bounds.width - 10
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
          CarouselItem(
            _id: Int(item.id),
            spacing: spacing,
            widthOfHiddenCards: widthOfHiddenCards,
            cardHeight: cardHeight,
            section: .top
          ) {
            Image(R.image.glasses.name)
              .resizable()
              .frame(width: 200, height: 200, alignment: .center)
          }
          .foregroundColor(Color.white)
          .background(Color(uiColor: selection.color))
          .cornerRadius(8)
          .transition(AnyTransition.slide)
          .animation(.easeOut)
        }
      }
    }
  }
}

