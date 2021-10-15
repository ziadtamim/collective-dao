//
//  ContentView.swift
//  Nouns
//
//  Created by Mohammed Ibrahim on 2021-09-28.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
      Text("Hello World")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro"))
    }
}
