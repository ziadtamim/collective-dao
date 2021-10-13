//
//  Canvas.swift
//  Nouns
//
//  Created by Mohammed Ibrahim on 2021-10-12.
//

import SwiftUI

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
