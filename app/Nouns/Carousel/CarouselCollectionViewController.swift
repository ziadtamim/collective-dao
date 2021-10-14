//
//  CarouselCollectionViewController.swift
//  Nouns
//
//  Created by Mohammed Ibrahim on 2021-10-13.
//

import UIKit

private let reuseIdentifier = "Cell"

enum ScrollDirection {
  case left
  case right
}

enum ScrollContext {
  case freescroll
  case iterate(direction: ScrollDirection)
  case stop
}

class CarouselCollectionViewController: UICollectionViewController {
  let items: Int = 20
  
  private var indexOfCellBeforeDragging: Int? = 0
  var endedCell: IndexPath?
  
  var context: ScrollContext = .freescroll
  
  private var setInsets: Bool = false
  
  private var flowLayout: UICollectionViewFlowLayout = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    return layout
  }()
  
  init() {
    super.init(collectionViewLayout: flowLayout)
    
    self.collectionView?.layer.borderColor = UIColor.systemBlue.cgColor
    self.collectionView?.layer.borderWidth = 2.0
    self.collectionView?.showsHorizontalScrollIndicator = false
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    guard !setInsets else { return }
    let inset = (collectionView!.frame.width - 200) / 2
    self.collectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: false)
    setInsets = true
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Register cell classes
    self.collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

    // Do any additional setup after loading the view.
  }
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using [segue destinationViewController].
   // Pass the selected object to the new view controller.
   }
   */
  private func indexOfMajorCell() -> Int? {
    let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
    let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
    let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint)
    return visibleIndexPath?.item
  }
}

// MARK: UICollectionViewDataSource
extension CarouselCollectionViewController {
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return items
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    cell.layer.borderWidth = 2.5
    cell.layer.borderColor = UIColor.red.cgColor
    
    cell.subviews.forEach { view in
      view.removeFromSuperview()
    }
    
    let label = UILabel()
    label.text = String(indexPath.row)
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    
    cell.addSubview(label)
    
    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
      label.centerYAnchor.constraint(equalTo: cell.centerYAnchor)
    ])
    
    return cell
  }
}

// MARK: UICollectionViewDelegateFlowLayout
extension CarouselCollectionViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 200, height: collectionView.frame.height)
  }
}

// MARK: UIScrollViewDelegate
extension CarouselCollectionViewController {
  override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
      indexOfCellBeforeDragging = indexOfMajorCell()
  }

  override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    let iterateThreshold = 0.2
    let freeScrollThreshold = 1.9
    
    let xVelocity = abs(velocity.x)
    
    if xVelocity > freeScrollThreshold {
      context = .freescroll
    } else if xVelocity > iterateThreshold {
      context = .iterate(direction: velocity.x > 0 ? .right : .left)
      
      guard let startIndex = indexOfCellBeforeDragging else { return }
      targetContentOffset.pointee = scrollView.contentOffset
      
      let endIndex = (velocity.x > 0 ? .right : .left) == .right ? min(startIndex + 1, items - 1) : max(startIndex - 1, 0)
      UIView.animate(withDuration: 0.3, animations: { [weak self] in
        self?.collectionViewLayout.collectionView?.scrollToItem(at: IndexPath(item: endIndex, section: 0), at: .centeredHorizontally, animated: true)
      })
    } else {
      context = .stop
      guard let indexOfMajorCell = self.indexOfMajorCell() else { return }

      let indexPath = IndexPath(row: indexOfMajorCell, section: 0)

      UIView.animate(withDuration: 0.3, animations: { [weak self] in
        self?.collectionViewLayout.collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
      })
      return
    }
  }
  
  override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
  }
  
  override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    switch context {
    case .freescroll, .stop:
      guard let indexOfMajorCell = self.indexOfMajorCell() else { return }

      let indexPath = IndexPath(row: indexOfMajorCell, section: 0)

      UIView.animate(withDuration: 0.3, animations: { [weak self] in
        self?.collectionViewLayout.collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
      })
    default:
      break
    }
  }
}
