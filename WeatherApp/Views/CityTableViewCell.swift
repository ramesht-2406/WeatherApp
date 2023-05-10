//
//  CityTableViewCell.swift
//  WeatherApp
//
//  Created by Ramesh Thangalapally on 08/05/23.
//

import UIKit

class CityTableViewCell: UITableViewCell {

    @IBOutlet weak var lbl_CityName: UILabel!
    
    class var nibName: String {
        return "\(self)"
    }
    class var identifier: String {
        return "\(self)"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
