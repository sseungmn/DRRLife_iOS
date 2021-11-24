//
//  LocationInfoViewController.swift
//  DRRLife
//
//  Created by OHSEUNGMIN on 2021/11/22.
//

import UIKit
import Then

class LocationInfoViewController: UIViewController {
    lazy var label = UILabel().then {
        $0.text = "LocationInfoView"
        $0.font = .systemFont(ofSize: 20)
        $0.textColor = .black
    }

    lazy var contentView = UIView().then {
        $0.addSubview(label)
        
        $0.backgroundColor = .systemBlue
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 15
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setContstraints()
    }
    
    func setContstraints() {
        view.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

}
