//
//  DailyCollectionViewCell.swift
//  WeatherApp
//
//  Created by Ramesh Thangalapally on 08/05/23.
//

import UIKit

class DailyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dailyImage: UIImageView!
    @IBOutlet weak var dailyDate: UILabel!
    @IBOutlet weak var dailyMaxTemp: UILabel!
    @IBOutlet weak var dailyMinTemp: UILabel!
    
    class var nibName: String {
        return "\(self)"
    }
    class var identifier: String {
        return "\(self)"
    }
    
    func configure(daily: Daily, indexPath: Int) {
        dailyDate.textColor = .white
        dailyMaxTemp.textColor = .white
        dailyMinTemp.textColor = .white
        dailyImage.contentMode = .scaleAspectFit
        dailyImage.image = UIImage(named: "\(daily.weather.first!.icon)-1.png")
        dailyMinTemp.text = "\(daily.temp.min.doubleToString())°"
        dailyMaxTemp.text = "\(daily.temp.max.doubleToString())°"
    }
    
}
