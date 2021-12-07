//
//  RouteInfoViewController.swift
//  DRRLife
//
//  Created by 오승민 on .
//

import UIKit

class RouteInfoViewController: UIViewController {
    lazy var containers = [ph0container, ph1container, ph2container]
    lazy var ph0container = Container(ph0ContainerView, ph0FromLbl, ph0Icon, ph0ToLbl, ph0DistLbl, ph0DuraLbl)
    lazy var ph1container = Container(ph1ContainerView, ph1FromLbl, ph1Icon, ph1ToLbl, ph1DistLbl, ph1DuraLbl)
    lazy var ph2container = Container(ph2ContainerView, ph2FromLbl, ph2Icon, ph2ToLbl, ph2DistLbl, ph2DuraLbl)
    
    // MARK: Total
    lazy var totContainerView = UIView().then {
        $0.backgroundColor = .clear
        $0.addSubview(totDistLbl)
        $0.addSubview(totDuraLbl)
        totDistLbl.snp.makeConstraints { make in
            make.right.equalTo(totDuraLbl.snp.left).offset(-8)
            make.centerY.equalToSuperview()
        }
        totDuraLbl.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
        }
    }
    var count: Int = 0
    var totDistance: Double = 0
    var totDuration: Double = 0
    lazy var totDistLbl = UILabel().then {
        $0.font = .boldThemeFont(ofSize: 18)
        $0.textColor = .black
    }
    lazy var totDuraLbl = UILabel().then {
        $0.font = .extraboldThemeFont(ofSize: 24)
        $0.textColor = .themeMain
    }
    
    //MARK: Phase 0
    lazy var ph0ContainerView = UIView().then {
        $0.backgroundColor = .systemYellow
    }
    lazy var ph0FromLbl = UILabel().then {
        $0.text = "출발지".localized()
    }
    lazy var ph0ToLbl = UILabel().then {
        $0.text = "출발지대여소".localized()
    }
    lazy var ph0Icon = UIImageView().then {
        $0.image = UIImage(named: "figure.walk")!
    }
    var ph0DistLbl = UILabel()
    var ph0DuraLbl = UILabel()
    
    //MARK: Phase 1
    lazy var ph1ContainerView = UIView().then {
        $0.backgroundColor = .systemGreen
    }
    lazy var ph1FromLbl = UILabel().then {
        $0.text = "출발지대여소".localized()
    }
    lazy var ph1ToLbl = UILabel().then {
        $0.text = "도착지대여소".localized()
    }
    lazy var ph1Icon = UIImageView().then {
        $0.image = UIImage(named: "bicycle")!
    }
    var ph1DistLbl = UILabel()
    var ph1DuraLbl = UILabel()
    
    //MARK: Phase 2
    lazy var ph2ContainerView = UIView().then {
        $0.backgroundColor = .systemYellow
    }
    lazy var ph2FromLbl = UILabel().then {
        $0.text = "도착지대여소".localized()
    }
    lazy var ph2ToLbl = UILabel().then {
        $0.text = "도착지".localized()
    }
    lazy var ph2Icon = UIImageView().then {
        $0.image = UIImage(named: "figure.walk")!
    }
    var ph2DistLbl = UILabel()
    var ph2DuraLbl = UILabel()
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.setContainerView()
    }
    
    func setContainerView() {
        view.addSubview(totContainerView)
        view.addSubview(ph0ContainerView)
        view.addSubview(ph1ContainerView)
        view.addSubview(ph2ContainerView)
        
        totContainerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        ph0ContainerView.snp.makeConstraints { make in
            make.top.equalTo(totContainerView.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(60)
        }
        ph1ContainerView.snp.makeConstraints { make in
            make.top.equalTo(ph0ContainerView.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(60)
        }
        ph2ContainerView.snp.makeConstraints { make in
            make.top.equalTo(ph1ContainerView.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(30)
            make.height.equalTo(60)
        }
    }
    
//    func setData(phase: Int, response: ORResponse) {
//        self.containers[phase].setData(response: response)
//        totDistance += response.distance
//        totDuration += response.duration
//        count += 1
//        if count == 3 {
//            totDuraLbl.text = makeFormattedDuration(totDuration)
//            totDistLbl.text = makeFormattedDistance(totDistance)
//
//            totDuration = 0
//            totDistance = 0
//            count = 0
//        }
//    }
    func setData(phase: Int, route: Route) {
        self.containers[phase].setData(route: route)
        totDistance += route.distance!
        totDuration += route.duration!
        count += 1
        if count == 3 {
            totDuraLbl.text = makeFormattedDuration(totDuration)
            totDistLbl.text = makeFormattedDistance(totDistance)
            
            totDuration = 0
            totDistance = 0
            count = 0
        }
    }
        
    private func makeFormattedDistance(_ distance: Double) -> String {
        let km: String = String(format: "%.1f", distance / 1000)
        print("distance : \(distance), km : \(km)")
        let m = distance
        if distance >= 1000 {
            return "\(km)km"
        } else {
            return "\(m)m"
        }
    }
    private func makeFormattedDuration(_ duration: Double) -> String {
        print("duration : \(duration)")
        let hour = Int(duration) / 3600
        let minutes = (Int(duration) - hour * 3600) / 60
        if hour > 0 {
            return "\(hour)\("시간".localized()) \(minutes)\("분".localized())"
        } else if minutes > 0 {
            return "\(minutes)\("분".localized())"
        } else {
            return "1분 이내".localized()
        }
   }
}

struct Container {
    var container: UIView
    var fromLabel: UILabel
    var icon: UIImageView
    var toLabel: UILabel
    var distanceLabel: UILabel
    var durationLabel: UILabel
    
    lazy var labels = [toLabel, fromLabel, distanceLabel, durationLabel]
    
    init(_ container: UIView,_ fromLabel: UILabel,_ icon: UIImageView,_ toLabel: UILabel,_ distanceLabel: UILabel,_ durationLabel: UILabel) {
        self.container = container
        self.fromLabel = fromLabel
        self.icon = icon
        self.toLabel = toLabel
        self.distanceLabel = distanceLabel
        self.durationLabel = durationLabel
        
        self.setContraints()
        self.setContentsUI()
    }
    
    mutating func setContentsUI() {
        container.layer.cornerRadius = 15
        fromLabel.font = .themeFont(ofSize: 13)
        fromLabel.textAlignment = .left
        fromLabel.numberOfLines = 2
        icon.contentMode = .scaleAspectFit
        icon.tintColor = .white
        toLabel.font = .themeFont(ofSize: 13)
        toLabel.textAlignment = .left
        toLabel.numberOfLines = 2
        
        distanceLabel.font = .themeFont(ofSize: 17)
        durationLabel.font = .boldThemeFont(ofSize: 22)
        distanceLabel.textAlignment = .right
        durationLabel.textAlignment = .right
        labels.forEach({ $0.textColor = .white })
    }
    
    mutating func setContraints() {
        container.addSubview(fromLabel)
        container.addSubview(icon)
        container.addSubview(toLabel)
        container.addSubview(distanceLabel)
        container.addSubview(durationLabel)
        
        fromLabel.snp.makeConstraints { make in
            make.size.equalTo(36)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(13)
        }
        icon.snp.makeConstraints { make in
            make.size.equalTo(36)
            make.centerY.equalToSuperview()
            make.left.equalTo(fromLabel.snp.right).offset(8)
        }
        
        toLabel.snp.makeConstraints { make in
            make.size.equalTo(36)
            make.centerY.equalToSuperview()
            make.left.equalTo(icon.snp.right).offset(8)
        }
        distanceLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(durationLabel.snp.left).offset(-8)
        }
        durationLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(8)
        }
    }
    
    func setData(route: Route) {
        self.distanceLabel.text = makeFormattedDistance(route.distance!)
        self.durationLabel.text = makeFormattedDuration(route.duration!)
    }
    
    private func makeFormattedDistance(_ distance: Double) -> String {
        let km: String = String(format: "%.1f", distance / 1000)
        print("distance : \(distance), km : \(km)")
        let m = distance
        if distance >= 1000 {
            return "\(km)km"
        } else {
            return "\(m)m"
        }
    }
    private func makeFormattedDuration(_ duration: Double) -> String {
        let hour = Int(duration) / 3600
        let minutes = (Int(duration) - hour * 3600) / 60
        if hour > 0 {
            return "\(hour)\("시간".localized()) \(minutes)\("분".localized())"
        } else if minutes > 0 {
            return "\(minutes)\("분".localized())"
        } else {
            return "1분 이내".localized()
        }
   }
}
