import UIKit

public let imageCache = NSCache<NSString, AnyObject>()

public extension UIImageView {
    func loadImageUsingCache(withUrl urlString: String) {
        let url = URL(string: urlString)
        image = nil
        
        // check cached image
        if let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage {
            image = cachedImage
            return
        }
        
        // if not, download image from url
        URLSession.shared.dataTask(with: url!, completionHandler: { data, _, error in
            if error != nil {
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

public extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
}

public extension Date {
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}

public extension UIDevice {
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            switch identifier {
            case "iPod5,1":
                return "iPod Touch 5"
            case "iPod7,1":
                return "iPod Touch 6"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":
                return "iPhone 4"
            case "iPhone4,1":
                return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":
                return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":
                return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":
                return "iPhone 5s"
            case "iPhone7,2":
                return "iPhone 6"
            case "iPhone7,1":
                return "iPhone 6 Plus"
            case "iPhone8,1":
                return "iPhone 6s"
            case "iPhone8,2":
                return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":
                return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":
                return "iPhone 7 Plus"
            case "iPhone8,4":
                return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":
                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":
                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":
                return "iPhone X"
            case "iPhone11,2":
                return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":
                return "iPhone XS Max"
            case "iPhone11,8":
                return "iPhone XR"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":
                return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":
                return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":
                return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":
                return "iPad Air"
            case "iPad5,3", "iPad5,4":
                return "iPad Air 2"
            case "iPad6,11", "iPad6,12":
                return "iPad 5"
            case "iPad7,5", "iPad7,6":
                return "iPad 6"
            case "iPad2,5", "iPad2,6", "iPad2,7":
                return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":
                return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":
                return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":
                return "iPad Mini 4"
            case "iPad6,3", "iPad6,4":
                return "iPad Pro (9.7-inch)"
            case "iPad6,7", "iPad6,8":
                return "iPad Pro (12.9-inch)"
            case "iPad7,1", "iPad7,2":
                return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad7,3", "iPad7,4":
                return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":
                return "iPad Pro (11-inch)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":
                return "iPad Pro (12.9-inch) (3rd generation)"
            case "AppleTV5,3":
                return "Apple TV"
            case "AppleTV6,2":
                return "Apple TV 4K"
            case "AudioAccessory1,1":
                return "HomePod"
            case "i386", "x86_64":
                return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default: return identifier
            }
        }
        
        return mapToDevice(identifier: identifier)
    }()
}

extension UIApplication {
    static var appVersion: String {
        guard let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
            return "1"
        }
        return version
    }
}

extension UserDefaults {
    static let extensions = UserDefaults(suiteName: "group.BAKit")
    
    private enum Keys {
        static let badge = "badge"
    }
    
    var badge: Int {
        get {
            return UserDefaults.extensions!.integer(forKey: Keys.badge)
        }
        
        set {
            UserDefaults.extensions!.set(newValue, forKey: Keys.badge)
        }
    }
}

extension NSMutableAttributedString {
    public func setAsLink(textToFind:String, linkURL:String) -> Bool {
        guard !linkURL.isEmpty else {
            return false
        }
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(.link, value: linkURL, range: foundRange)
            return true
        }
        return false
    }
}

extension NSAttributedString {
    static public func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString {
        let result = NSMutableAttributedString()
        result.append(left)
        result.append(right)
        return result
    }
}

extension NSDictionary {
    var swiftDictionary: Dictionary<String, Any> {
        var swiftDictionary = Dictionary<String, Any>()
        
        for key : Any in self.allKeys {
            let stringKey = key as! String
            if let keyValue = self.value(forKey: stringKey){
                swiftDictionary[stringKey] = keyValue
            }
        }
        return swiftDictionary
    }
}

