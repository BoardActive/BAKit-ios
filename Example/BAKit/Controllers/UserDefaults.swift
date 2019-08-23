//
//  UserDefaults.swift
//  BAKit
//
//  Created by Ed Salter on 5/3/19.
//  Copyright © 2019 BoardActive. All rights reserved.
//

import Foundation
import UIKit

extension UserDefaults {
    static let suiteName = "group.BAKit"
    static let extensions = UserDefaults(suiteName: suiteName)!
    static var imageCache = NSCache<NSString, AnyObject>()
    
    private enum Keys {
        static let badge = "badge"
        static let userInfo = "userInfo"
        static let imageCache = "imageCache"
    }
    
    var imageCache: NSCache<NSString, AnyObject> {
        get {
            return UserDefaults.extensions.value(forKey: Keys.imageCache) as! NSCache<NSString,AnyObject>
        }
        set {
            UserDefaults.extensions.set(newValue, forKey: Keys.imageCache)
        }
    }
    
    var userInfo: Dictionary<String,Any> {
        get {
            return UserDefaults.extensions.dictionary(forKey: Keys.userInfo)!
        }
        set {
            UserDefaults.extensions.set(newValue, forKey: Keys.userInfo)
        }
    }
    
    var badge: Int {
        get {
            return UserDefaults.extensions.integer(forKey: Keys.badge)
        }
        
        set {
            UserDefaults.extensions.set(newValue, forKey: Keys.badge)
        }
    }
}

public extension UIImageView {
    func download(
        from url: URL,
        contentMode: UIView.ContentMode = .scaleAspectFit,
        placeholder: UIImage? = nil,
        completionHandler: ((UIImage?) -> Void)? = nil) {
        
        image = placeholder
        self.contentMode = contentMode
        URLSession.shared.dataTask(with: url) { (data, response, _) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data,
                let image = UIImage(data: data)
                else {
                    completionHandler?(nil)
                    return
            }
            DispatchQueue.main.async { [unowned self] in
                self.image = image
                completionHandler?(image)
            }
            }.resume()
    }
}

