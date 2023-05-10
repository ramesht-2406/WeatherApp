//
//  Utils.swift
//  WeatherApp
//
//  Created by Ramesh Thangalapally on 08/05/23.
//

import Foundation
import UIKit

class Utils: NSObject {
    class func showAlert(vc:UIViewController, message:String) {
        let alertController = UIAlertController(title: "Task", message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Ok", style: .cancel)
        alertController.addAction(dismissAction)
        vc.present(alertController, animated: true)
    }
    
    class func convertKelvintoCelsius(_ kelvin: Double) -> Double {
        let celsius = kelvin - 273.15
        return celsius
    }
    
    static func getDatefromUnixTimeStamp(_ unixStamp: TimeInterval) -> Date {
        let date = Date.init(timeIntervalSince1970: unixStamp)
        return date
    }
    
    static func getDateforCurrentTimeZone() -> Date {
        let initTz = TimeZone(abbreviation: "GMT")!
        let targetTz = TimeZone.current
        let targetDate = Date().convertToTimeZone(initTimeZone: initTz, to: targetTz)
        return targetDate
    }
    
    static func dateFormater(date: TimeInterval, dateFormat: String, timezone: Int) -> String {
        let dateText = Date(timeIntervalSince1970: date)
        let formater = DateFormatter()
        formater.timeZone = TimeZone(secondsFromGMT: timezone)
        formater.dateFormat = dateFormat
        return formater.string(from: dateText)
        
    }
    
    static func getCurrentDateTime(unixStamp: TimeInterval) -> String {
        let date = Utils.getDatefromUnixTimeStamp(unixStamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.string(from: date)
    }
    
    static func getTimeDifference(_ unixDate: Date) -> String {
        let today = Date()
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        print(formatter.string(from: unixDate, to: today)!)
        return formatter.string(from: unixDate, to: today)!
    }
    
    static func saveDataintoUserDefaults(_ modelClass: CoordCity) {
        do {
            // Create JSON Encoder
            let encoder = JSONEncoder()

            // Encode Note
            let data = try encoder.encode(modelClass)

            // Write/Set Data
            UserDefaults.standard.set(data, forKey: Constants.LAST_CITYSEARCHED)

        } catch {
            print("Unable to Encode Note (\(error))")
        }
    }
    
    static func retriveDatafromUserDefaults() -> CoordCity? {
        // Read/Get Data
        if let data = UserDefaults.standard.data(forKey: Constants.LAST_CITYSEARCHED) {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()
                
                // Decode Note
                let coordCity = try decoder.decode(CoordCity.self, from: data)
                return coordCity
            } catch {
                print("Unable to Decode Note (\(error))")
            }
        }
        return nil
    }
}

class SearchBar: UISearchBar {
    
    private enum SubviewKey: String {
        case searchField, clearButton, cancelButton,  placeholderLabel
    }
     
    // Button/Icon images
    public var clearButtonImage: UIImage?
    public var resultsButtonImage: UIImage?
    public var searchImage: UIImage?
    
    // Button/Icon colors
    public var searchIconColor: UIColor?
    public var clearButtonColor: UIColor?
    public var cancelButtonColor: UIColor?
    public var capabilityButtonColor: UIColor?
    
    // Text
    public var textColor: UIColor?
    public var placeholderColor: UIColor?
    public var cancelTitle: String?
    
    // Cancel button to change the appearance.
    public var cancelButton: UIButton? {
        guard showsCancelButton else { return nil }
        return self.value(forKey: SubviewKey.cancelButton.rawValue) as? UIButton
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let cancelColor = cancelButtonColor {
            self.cancelButton?.setTitleColor(cancelColor, for: .normal)
        }
        if let cancelTitle = cancelTitle {
            self.cancelButton?.setTitle(cancelTitle, for: .normal)
        }
        
        guard let textField = self.value(forKey: SubviewKey.searchField.rawValue) as? UITextField else { return }
        
        if let clearButton = textField.value(forKey: SubviewKey.clearButton.rawValue) as? UIButton {
            update(button: clearButton, image: clearButtonImage, color: clearButtonColor)
        }
        if let resultsButton = textField.rightView as? UIButton {
            update(button: resultsButton, image: resultsButtonImage, color: capabilityButtonColor)
        }
        if let searchView = textField.leftView as? UIImageView {
            searchView.image = (searchImage ?? searchView.image)?.withRenderingMode(.alwaysTemplate)
            if let color = searchIconColor {
                searchView.tintColor = color
            }
        }
        if let placeholderLabel =  textField.value(forKey: SubviewKey.placeholderLabel.rawValue) as? UILabel,
           let color = placeholderColor {
            placeholderLabel.textColor = color
        }
        if let textColor = textColor  {
            textField.textColor = textColor
        }
    }
    
    private func update(button: UIButton, image: UIImage?, color: UIColor?) {
        let image = (image ?? button.currentImage)?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.setImage(image, for: .highlighted)
        if let color = color {
            button.tintColor = color
        }
    }
    
}

extension Date {
    func convertToTimeZone(initTimeZone: TimeZone, to targetTimeZone: TimeZone) -> Date {
        let delta = TimeInterval(targetTimeZone.secondsFromGMT(for: self) - initTimeZone.secondsFromGMT(for: self))
        return addingTimeInterval(delta)
    }
}

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
}

extension String {
    mutating func getStringforDatetime() -> String {
        if self.contains("-") {
            self = self.replacingOccurrences(of: "-", with: "")
            return "in \(self) min"
        } else {
            let components = self.components(separatedBy: ":")
            if components.count > 1 {
                return "\(components[0]) hours ago"
            } else {
                return "\(self) min ago"
            }
        }
    }
}

@IBDesignable
public class Gradient: UIView {
    @IBInspectable var startColor:   UIColor = .black { didSet { updateColors() }}
    @IBInspectable var endColor:     UIColor = .white { didSet { updateColors() }}
    @IBInspectable var startLocation: Double =   0.05 { didSet { updateLocations() }}
    @IBInspectable var endLocation:   Double =   0.95 { didSet { updateLocations() }}
    @IBInspectable var horizontalMode:  Bool =  false { didSet { updatePoints() }}
    @IBInspectable var diagonalMode:    Bool =  false { didSet { updatePoints() }}

    override public class var layerClass: AnyClass { CAGradientLayer.self }

    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

    func updatePoints() {
        if horizontalMode {
            gradientLayer.startPoint = diagonalMode ? .init(x: 1, y: 0) : .init(x: 0, y: 0.5)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 0, y: 1) : .init(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = diagonalMode ? .init(x: 0, y: 0) : .init(x: 0.5, y: 0)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 1, y: 1) : .init(x: 0.5, y: 1)
        }
    }
    func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    func updateColors() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updatePoints()
        updateLocations()
        updateColors()
    }

}

extension Double {
    func doubleToString() -> String {
        return String(format: "%.0f", self)
    }
}
