//
//  ViewController.swift
//  DRRLife
//
//  Created by OHSEUNGMIN on 2021/11/20.
//

import UIKit
import Then

class ViewController: UIViewController {
    lazy var infoContainer = UIView()
    lazy var mapContainer = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(infoContainer)
        view.addSubview(mapContainer)
        infoContainer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 100)
        mapContainer.frame = CGRect(x: 0, y: 100, width: view.bounds.width, height: 500)
        
        let infoView = LocationInfoView()
        infoContainer.addSubview(infoView)
        infoView.frame = infoContainer.frame
        
        let mapViewController = MapViewController()
        mapContainer.addSubview(mapViewController.view)
        mapViewController.view.frame = mapContainer.frame
    }

}
