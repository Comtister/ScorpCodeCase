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
    func indicatorUpdate(isActive: Bool)
    
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
                    nextUsersString = response.next
                    userDatas.append(contentsOf: response.people)
                    userDatas = filterUsersForIds()
                    delegate?.updateUserData()
                    delegate?.indicatorUpdate(isActive: false)
                    //delegate?.userDataUpdateFailed(errorDescription: "Test")
                case .failure(let error):
                    delegate?.userDataUpdateFailed(errorDescription: error.errorDescription)
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
        
        let personIds = userDatas.map { $0.id }
        let uniqueIds = Set(personIds)
        
        var personDict: [Int: Person] = [:]
        
        userDatas.forEach { person in
            if let _ = personDict[person.id] {
                return
            } else {
                personDict[person.id] = person
            }
        }
        
        var filteredPersons: [Person] = []
        
        uniqueIds.forEach { id in
            guard let person = personDict[id] else { return }
            filteredPersons.append(person)
        }
        return filteredPersons
    }
    
}
