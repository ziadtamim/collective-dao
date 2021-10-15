//
//  NounView.swift
//  Nouns
//
//  Created by Mohammed Ibrahim on 2021-10-14.
//

import SwiftUI

// swiftlint:disable all
enum PartSelection: Int {
  case body = 0
  case accessory = 1
  case head = 2
  case glasses = 3
}

struct NounView: View {
  // seed parts
  // 0 = body
  // 1 = accessory
  // 2 = head
  // 3 = glasses
  
  let noun = try! NounsEngine().random()
  var parts: Set<PartSelection> = [.body, .accessory, .head, .glasses]
  var showShadow: Bool = false
  var yOffset: CGFloat = 0
  
  let lookup = [
    0, 10, 20, 30, 40, 50, 60, 70,
    80, 90, 100, 110, 120, 130, 140, 150,
    160, 170, 180, 190, 200, 210, 220, 230,
    240, 250, 260, 270, 280, 290, 300, 310,
    320
  ]
  
  var body: some View {
    ZStack {
      if showShadow {
        VStack(alignment: .center) {
          Spacer()
          Image(R.image.shadow.name)
            .offset(x: 0, y: 160)
          Spacer()
        }
      }
      
      ForEach(noun.seed.indices) { index in
        if let partSelection = PartSelection(rawValue: index), parts.contains(partSelection) {
          ForEach(noun.seed[index].shapes, id: \.id) { pathSeed in
            Path { path in
              path.addRect(
                CGRect(
                  x: lookup[Int(pathSeed.rect.minX)],
                  y: lookup[Int(pathSeed.rect.minY)],
                  width: lookup[Int(pathSeed.rect.width)],
                  height: lookup[Int(pathSeed.rect.height)]
                )
              )
            }
            .fill(Color(uiColor: UIColor(hexString: pathSeed.fillColor)))
          }
        }
      }.frame(width: 320, height: 320, alignment: .center)
    }
    .drawingGroup()
    .background(Color.clear)
    .offset(x: 0, y: yOffset)
  }
}

struct NounView_Previews: PreviewProvider {
  static var previews: some View {
    NounView()
  }
}
