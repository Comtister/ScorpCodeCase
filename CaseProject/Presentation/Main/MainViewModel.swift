//
//  MainViewModel.swift
//  CaseProject
//
//  Created by Oguzhan Ozturk on 15.11.2023.
//

import Foundation

// MARK: - ViewModel Delegate
protocol MainViewModelDelegate {
    
    func updateUserData()
    func userDataUpdateFailed(errorDescription: String)
    
}

class MainViewModel {
    
    var delegate: MainViewModelDelegate?
    
    private let userRepository = UserRepositoryImp()
    
    private var fetchTask: Task<Void, Never>?
    
    var userDatas: [Person] = []
    
    private var nextUsersString: String? = nil
    /*
    init(delegate: MainViewModelDelegate) {
        self.delegate = delegate
    }*/
    
    func initialFetch() {
        
        fetchTask = Task {
            let result = await userRepository.fetchUsers(next: nil)
            
            await MainActor.run {
                switch result {
                case .success(let response):
                    nextUsersString = response.next
                    delegate?.updateUserData()
                case .failure(let error):
                    delegate?.userDataUpdateFailed(errorDescription: error.errorDescription)
                }
            }
             fetchTask = nil
        }
       
    }
    
    func fetchNames() {
        
        guard fetchTask == nil else { return }
        
        fetchTask = Task {
            
            let result = await userRepository.fetchUsers(next: nextUsersString)
            
            await MainActor.run {
                switch result {
                case .success(let response):
                    nextUsersString = response.next
                    delegate?.updateUserData()
                case .failure(let error):
                    delegate?.userDataUpdateFailed(errorDescription: error.errorDescription)
                }
            }
            fetchTask = nil
        }
        
    }
    
}
