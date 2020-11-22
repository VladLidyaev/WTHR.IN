//
//  CityTableViewCell.swift
//  WTHR.IN
//
//  Created by Vlad on 20.11.2020.
//

import UIKit

class CityTableViewCell: UITableViewCell {
    
    @IBOutlet weak var CityName: UILabel!
    @IBOutlet weak var Country: UILabel!
    @IBOutlet weak var Temperature: UILabel!
    @IBOutlet weak var RoundedView: UIView!
    @IBOutlet weak var Icon: UIImageView!
    var id : Int = 0
    
    private let CornerRadius = CGFloat(10)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureProperties()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func configureProperties() {
        RoundedView.translatesAutoresizingMaskIntoConstraints = false
        RoundedView.layer.cornerRadius = CornerRadius
    }
}
