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

    func setData(row: PlaceDetail) {
        nameLabel.text = row.name
        addressLabel.text = row.address!
        categoryLabel.text = row.categoryName.components(separatedBy: ">").last
    }
    
}
