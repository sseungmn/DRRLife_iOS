//
//  SearchTableViewCell.swift
//  DRRLife
//
//  Created by OHSEUNGMIN on 2021/11/23.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    static let identifier = "SearchTableViewCell"
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setData(row: KLResponse.Place) {
        nameLabel.text = row.place_name
        addressLabel.text = row.road_address_name
        categoryLabel.text = row.category_name.components(separatedBy: ">").last
    }
    
}
