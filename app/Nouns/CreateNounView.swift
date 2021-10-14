//
//  CreateNounView.swift
//  Nouns
//
//  Created by Mohammed Ibrahim on 2021-10-11.
//

import SwiftUI

enum CarouselSelection: String {
  case head = "Head"
  case body = "Body"
  case glasses = "Glasses"
  case accessory = "Accessory"
}

// swiftlint:disable all
struct CreateNounView: View {
  @State var carouselSelection: CarouselSelection = .head
  
  var body: some View {
    VStack {
      Spacer()
      CreateHeader()
        .padding(.horizontal)
      
      ZStack {
        NounView(noun: try! NounsEngine().random())
        .drawingGroup()
        .background(Color(uiColor: UIColor(hexString: "#FFFFFF")))
        .frame(width: 200, height: 200, alignment: .center)
        
        Carousel(carouselSelection: $carouselSelection)
        
        VStack {
          Spacer()
          HStack(spacing: 20) {
            Image(R.image.leftArrow.name)
            Text("Swipe to pick \(carouselSelection.rawValue.lowercased())")
              .bold()
            Image(R.image.rightArrow.name)
          }.padding(.bottom, 40)
        }
      }
      
      Picker("Noun Trait", selection: $carouselSelection) {
        Text(CarouselSelection.head.rawValue).tag(CarouselSelection.head)
        Text(CarouselSelection.body.rawValue).tag(CarouselSelection.body)
        Text(CarouselSelection.glasses.rawValue).tag(CarouselSelection.glasses)
        Text(CarouselSelection.accessory.rawValue).tag(CarouselSelection.accessory)
      }
        .pickerStyle(.segmented)
        .padding(.horizontal)
      Spacer()
    }.background(LinearGradient(gradient: Gradient(colors: [Color(uiColor: UIColor(red: 234/255, green: 235/255, blue: 240/255, alpha: 1.0)),
                                                            Color(uiColor: UIColor(red: 213/255, green: 215/255, blue: 225/255, alpha: 1.0))]),
                                startPoint: .top,
                                endPoint: .bottom))
  }
}

struct CreateNounView_Previews: PreviewProvider {
  static var previews: some View {
    CreateNounView()
  }
}
