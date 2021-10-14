//
//  NounView.swift
//  Nouns
//
//  Created by Mohammed Ibrahim on 2021-10-14.
//

import SwiftUI
// swiftlint:disable all
struct NounView: View {
  let noun: Noun
  
  var body: some View {
    ZStack {
      ForEach(noun.seed.first!.shapes, id: \.id) { pathSeed in
        Path { path in
          path.addRect(
            CGRect(
              x: pathSeed.rect.minX,
              y: pathSeed.rect.minY,
              width: pathSeed.rect.width,
              height: pathSeed.rect.height
            )
          )
        }
        .fill(Color(uiColor: UIColor(hexString: pathSeed.fillColor)))
      }
    }
    .frame(width: 32, height: 32, alignment: .center)
  }
}

struct NounView_Previews: PreviewProvider {
  let noun = try! NounsEngine().random()

  init() {
    print(noun.seed.first!)
  }
  
  static var previews: some View {
    NounView(noun: try! NounsEngine().random())
  }
}
