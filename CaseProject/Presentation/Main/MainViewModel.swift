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
    func userDataUpdateFailed(errorDescription: MainViewFetchErrorTypes)
    func indicatorUpdate(isActive: Bool)
    
}

enum MainViewFetchErrorTypes {
    case ZeroFound
    case GeneralError(description: String)
}

class MainViewModel {
    
    var delegate: MainViewModelDelegate?
    
    private let userRepository = UserRepositoryImp()
    
    private var fetchTask: Task<Void, Never>?
    
    var userDatas: [Person] = []
    
    private var nextUsersString: String? = nil
    
    func fetchNames() {
        delegate?.indicatorUpdate(isActive: true)
        guard fetchTask == nil else { return }
        
        fetchTask = Task {
            
            let result = await userRepository.fetchUsers(next: nextUsersString)
            
            await MainActor.run {
                switch result {
                case .success(let response):
                    if response.people.count == 0 {
                        delegate?.userDataUpdateFailed(errorDescription: .ZeroFound)
                        delegate?.indicatorUpdate(isActive: false)
                        return
                    }
                    nextUsersString = response.next
                    userDatas.append(contentsOf: response.people)
                    userDatas = filterUsersForIds()
                    delegate?.updateUserData()
                    delegate?.indicatorUpdate(isActive: false)
                case .failure(let error):
                    delegate?.indicatorUpdate(isActive: false)
                    delegate?.userDataUpdateFailed(errorDescription: .GeneralError(description: error.errorDescription))
                }
            }
            fetchTask = nil
        }
        
    }
    
    func refreshData() {
        userDatas = []
        nextUsersString = nil
        delegate?.updateUserData()
        fetchNames()
    }
    
    func filterUsersForIds() -> [Person] {
        
        var filteredUsers: [Person] = []
        var storedIds: [Int: Int] = [:]
        
        userDatas.forEach { person in
            if let _ = storedIds[person.id] {
                return
            } else {
                filteredUsers.append(person)
                storedIds[person.id] = person.id
            }
        }
        return filteredUsers
    }
    
}
