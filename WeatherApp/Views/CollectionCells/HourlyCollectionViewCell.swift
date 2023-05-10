//
//  HourlyCollectionViewCell.swift
//  WeatherApp
//
//  Created by Ramesh Thangalapally on 08/05/23.
//

import UIKit

class HourlyCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var hourlyImageVew: UIImageView!
    @IBOutlet weak var hourlyTemp: UILabel!
    @IBOutlet weak var hourlyTime: UILabel!
    
    class var nibName: String {
        return "\(self)"
    }
    class var identifier: String {
        return "\(self)"
    }
    
    func configure(hourly: Hourly, indexPath: Int) {
        hourlyTemp.textColor = .white
        hourlyTime.textColor = .white
        hourlyImageVew.contentMode = .scaleAspectFit
        hourlyImageVew.image = UIImage(named: "\(hourly.weather.first!.icon)-1.png")
        hourlyTemp.text = "\(hourly.temp.doubleToString())°"
    }
}
