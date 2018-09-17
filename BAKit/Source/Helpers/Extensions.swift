import UIKit

extension UIView {
  struct Constants {
    static let ExternalBorderName = "externalBorder"
  }
  
  func addExternalBorder(borderWidth: CGFloat = 2.0, borderColor: UIColor = .white, cornerRadius: CGFloat = 8) -> Void {
    let externalBorder = CALayer()
    externalBorder.frame = CGRect(x: -borderWidth, y: -borderWidth, width: frame.size.width + 2 * borderWidth, height: frame.size.height + 2 * borderWidth)
    externalBorder.borderColor = borderColor.cgColor
    externalBorder.borderWidth = borderWidth
    externalBorder.cornerRadius = cornerRadius
    externalBorder.name = Constants.ExternalBorderName
    
    layer.insertSublayer(externalBorder, at: 0)
    layer.masksToBounds = false
  }
  
  func removeExternalBorders() {
    layer.sublayers?.filter() { $0.name == Constants.ExternalBorderName }.forEach() {
      $0.removeFromSuperlayer()
    }
  }
  
  func removeExternalBorder(externalBorder: CALayer) {
    guard externalBorder.name == Constants.ExternalBorderName else { return }
    externalBorder.removeFromSuperlayer()
  }
  
  
  func addConstraintsWithFormat(format: String, views: UIView...) {
    var viewsDictionary = [String: UIView]()
    for (index, view) in views.enumerated() {
      let key = "v\(index)"
      view.translatesAutoresizingMaskIntoConstraints = false
      viewsDictionary[key] = view
    }
    
    addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
  }
}

let imageCache = NSCache<NSString, AnyObject>()

extension UIImageView {
  func loadImageUsingCache(withUrl urlString: String) {
    let url = URL(string: urlString)
    self.image = nil
    
    // check cached image
    if let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage {
      self.image = cachedImage
      return
    }
    
    // if not, download image from url
    URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
      if error != nil {
        print(error!)
        return
      }
      
      DispatchQueue.main.async {
        if let image = UIImage(data: data!) {
          imageCache.setObject(image, forKey: urlString as NSString)
          self.image = image
        }
      }
      
    }).resume()
  }
}


extension UINavigationController {
  override open var shouldAutorotate: Bool {
    get {
      if let visibleVC = visibleViewController {
        return visibleVC.shouldAutorotate
      }
      return super.shouldAutorotate
    }
  }
  
  override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
    get {
      if let visibleVC = visibleViewController {
        return visibleVC.preferredInterfaceOrientationForPresentation
      }
      return super.preferredInterfaceOrientationForPresentation
    }
  }
  
  override open var supportedInterfaceOrientations: UIInterfaceOrientationMask{
    get {
      if let visibleVC = visibleViewController {
        return visibleVC.supportedInterfaceOrientations
      }
      return super.supportedInterfaceOrientations
    }
  }
}
