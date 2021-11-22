//
//  LocationInfoViewController.swift
//  DRRLife
//
//  Created by OHSEUNGMIN on 2021/11/22.
//

import UIKit

class LocationInfoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel().then {
            $0.text = "LocationInfoView"
            $0.font = .systemFont(ofSize: 20)
            $0.textColor = .white
        }
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalTo(view)
        }
    }

}
