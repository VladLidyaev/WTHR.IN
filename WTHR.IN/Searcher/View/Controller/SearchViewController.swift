//
//  SearchViewController.swift
//  WTHR.IN
//
//  Created by Vlad on 19.11.2020.
//

import UIKit
import RxCocoa
import RxSwift

class SearchViewController: UIViewController {
    
    private let CornerRadius = CGFloat(6)
    private let ViewTitle = "Select city"
    private let SearchPlaceholder = "Search by city name"
    
    @IBOutlet weak var RoundedView: UIView!
    @IBOutlet weak var SearchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    let DBag = DisposeBag()
    private var UserRequest = ""
    let viewModel = SearchViewModel()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureProperties()
        bindTableView()
        
    }
    
    private func bindTableView() {
        
        tableView.register(UINib(nibName: "CityTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        // TableView content
        
        viewModel.showdata.bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: CityTableViewCell.self)) { (row,item,cell) in
            cell.CityName.text = item.name
            cell.Country.text = item.country
            cell.Temperature.text = item.temperature
            cell.Icon.image = UIImage(named: item.icinname)
            cell.id = item.id
        }.disposed(by: DBag)
        
        tableView.rx            // Subscribe on VisibleCells
            .willDisplayCell
            .subscribe(onNext: { cell, indexPath in
                self.viewModel.visiblecellsindexpath.accept(indexPath[1])
            })
            .disposed(by: DBag)
        
        tableView.rx.itemSelected.subscribe ( onNext: {         // When selected -> Open More Info screen with that city
            [weak self] indexPath in
            if let cell = self?.tableView.cellForRow(at: indexPath) as? CityTableViewCell{
                let detailVC = self?.storyboard?.instantiateViewController(withIdentifier: "Details") as! DetailViewController
                detailVC.CityID = cell.id
                self?.navigationController?.pushViewController(detailVC, animated: true)
            }
        }).disposed(by: DBag)
        
        SearchTextField.rx.text         // Dynamic search
            .orEmpty
            .throttle(0.1, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .do(onNext: {_ in
                    if !self.tableView.visibleCells.isEmpty {
                        let indexPath = IndexPath(row: 0 , section: 0)
                        self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                    }})
            .bind(to: viewModel.searchText)
            .disposed(by: DBag)
        
        viewModel.status            // Generating allert with error
            .asObservable()
            .filter{ $0 != "OK"}
            .subscribe { (str) in
                self.ShowAlert(mess: str)
            }.disposed(by: DBag)
        
    }
    
    private func configureProperties() {
        self.tableView.separatorStyle = .none
        tableView.bounces = false
        navigationItem.title = ViewTitle
        navigationController?.navigationBar.prefersLargeTitles = true
        RoundedView.layer.cornerRadius = CornerRadius
        SearchTextField.placeholder = SearchPlaceholder
        RoundedView.layer.backgroundColor = UIColor.yellow.cgColor
    }
    
    enum mess {
        case ConnetionError
        case ServicesError
    }
    
    func ShowAlert(mess: String){           // Generating Allert
        var str = ""
        if mess == "ConnetionError" {
            str = "You have problems with the connection"
        } else {
            if mess == "ServicesError"{
                str = "We have a small problem on the server. We'll fix it soon"
            } else {
                str = "An unknown error occurred. Restart the application"
            }
        }
        
        let alert = UIAlertController(title: "Houston, we have a problem...", message: str, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "I'll come back later", style: .cancel, handler: { (action) in
            UIControl().sendAction(#selector(NSXPCConnection.suspend), to: UIApplication.shared, for: nil)
        }))
        present(alert, animated: true)
    }
}

