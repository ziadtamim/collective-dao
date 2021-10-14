//
//  Carousel.swift
//  Nouns
//
//  Created by Mohammed Ibrahim on 2021-10-13.
//

import Foundation
import SwiftUI

struct Carousel: UIViewControllerRepresentable {
  typealias UIViewControllerType = CarouselCollectionViewController
  
  func makeUIViewController(context: Context) -> CarouselCollectionViewController {
    return CarouselCollectionViewController()
  }
  
  func updateUIViewController(_ uiViewController: CarouselCollectionViewController, context: Context) {
    //
  }
}
