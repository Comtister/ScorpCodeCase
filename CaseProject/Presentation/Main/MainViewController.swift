//
//  ViewController.swift
//  CaseProject
//
//  Created by Oguzhan Ozturk on 15.11.2023.
//

import UIKit

class MainViewController: UIViewController {

    private let viewModel: MainViewModel
    
    //MARK: - Views
    private var tableView: UITableView!
    private var indicatorView: UIActivityIndicatorView!
    private var fetchErrorSheet = UIAlertController(title: "Hata", message: "Veriler yüklenirken hata meydana geldi.", preferredStyle: .actionSheet)
    
    init() {
        self.viewModel = MainViewModel()
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        viewModel.fetchNames()
    }
    

}

//MARK: - View Setup Functions
extension MainViewController {
    
    private func setupUI() {
        
        self.view.backgroundColor = .systemBackground
        setupTableView()
        setupIndicatorView()
    }
    
    private func setupTableView() {
        
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
        self.view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
        
    }
    
    private func setupIndicatorView() {
        
        indicatorView = UIActivityIndicatorView()
        indicatorView.style = .large
        indicatorView.isHidden = true
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(indicatorView)
        
        NSLayoutConstraint.activate([
            indicatorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
        
    }
    
}

// MARK: - ViewModel Delegates
extension MainViewController: MainViewModelDelegate {
    
    func updateUserData() {
        tableView.reloadData()
        print("update data")
    }
    
    func userDataUpdateFailed(errorDescription: String) {
        print("show error")
        //Show error and refresh fetch or cancel
        
        
    }
    
    func indicatorUpdate(isActive: Bool) {
        indicatorView.isHidden = !isActive
        isActive ? indicatorView.startAnimating() : indicatorView.stopAnimating()
    }
    
}

// MARK: - TableView Delegates
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.userDatas.count
        //return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = viewModel.userDatas[indexPath.row].fullName
        //cell.textLabel?.text = "Test \(indexPath.row)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard viewModel.userDatas.count != 0 else { return }
        if indexPath.row == viewModel.userDatas.count - 1 {
            viewModel.fetchNames()
        }
    }
    
    @objc func handleRefresh() {
        viewModel.refreshData()
        self.tableView.refreshControl?.endRefreshing()
    }
    
}
