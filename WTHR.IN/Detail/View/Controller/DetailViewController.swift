//
//  DetailViewController.swift
//  WTHR.IN
//
//  Created by Vlad on 22.11.2020.
//

import UIKit
import RxSwift
import RxCocoa

class DetailViewController: UIViewController {          // City Detail Screen
    
    private let CornerRadius = CGFloat(15)
    private let ViewTitle = "WTHR.IN"
    
    @IBOutlet weak var CityName: UILabel!
    @IBOutlet weak var DownloadDate: UILabel!
    @IBOutlet weak var Icon: UIImageView!
    @IBOutlet weak var Temperature: UILabel!
    @IBOutlet weak var FeelsLikeTemperature: UILabel!
    @IBOutlet weak var InfoScroll: UITextView!
    @IBOutlet weak var RoundedRectangleTop: UIView!
    @IBOutlet weak var RoundedRectangleMid: UIView!
    @IBOutlet weak var RoundedRectangleBot: UIView!
    
    var CityID : Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureProperties()
        
        let viewModel = DetailViewModel(id: String(CityID))
        CityName.text = viewModel.cityName
        Temperature.text = viewModel.temp
        FeelsLikeTemperature.text = viewModel.feelLikeTemp
        Icon.image = UIImage(named: viewModel.icon)
        DownloadDate.text = "Upload date: \(viewModel.date)"
        InfoScroll.text = (viewModel.Info)
        
    }
    
    private func configureProperties() {
        
        InfoScroll.isEditable = false
        InfoScroll.layer.cornerRadius = CornerRadius
        navigationItem.title = ViewTitle
        navigationController?.navigationBar.prefersLargeTitles = true
        
        for RoundedView in [RoundedRectangleTop,RoundedRectangleMid,RoundedRectangleBot]{
            RoundedView!.layer.cornerRadius = CornerRadius
        }
        
    }
    
}
