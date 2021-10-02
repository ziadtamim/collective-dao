//
//  ContentView.swift
//  Nouns
//
//  Created by Mohammed Ibrahim on 2021-09-28.
//

import SwiftUI
import NounsServices

struct ContentView: View {
    
    let nounsService = NounsService()
  
    init() {
        nounsService.generateSVG("0x0Cfdb3Ba1694c2bb2CFACB0339ad7b1Ae5932B63", seed: [0,2,4,123,2])
    }
  
    var body: some View {
      Image(R.image.placeholder.name)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 200, height: 200, alignment: .center)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro"))
    }
}
