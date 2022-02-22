//
//  CreateHeader.swift
//  Nouns
//
//  Created by Mohammed Ibrahim on 2021-10-12.
//

import SwiftUI

struct CreateHeader: View {
  var didTapRandom: () -> Void = {}
  
  init(didTapRandom: @escaping () -> Void = {}) {
    self.didTapRandom = didTapRandom
  }
  
  var body: some View {
    HStack {
      Image(R.image.close.name)
      Spacer()
      Button {
        didTapRandom()
      } label: {
        Image(R.image.vector.name)
      }

      Image(R.image.check.name)
    }
  }
}

struct CreateHeader_Previews: PreviewProvider {
  static var previews: some View {
    CreateHeader()
  }
}
