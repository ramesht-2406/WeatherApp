//
//  SelfLocationTableViewCell.swift
//  WeatherApp
//
//  Created by Ramesh Thangalapally on 07/05/23.
//

import UIKit

class SelfLocationTableViewCell: UITableViewCell {

    @IBOutlet weak var imageViewCell: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    
    class var nibName: String {
        return "\(self)"
    }
    class var identifier: String {
        return "\(self)"
    }
    
    func configure() {
        self.locationLabel.text = "Use current location"
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
