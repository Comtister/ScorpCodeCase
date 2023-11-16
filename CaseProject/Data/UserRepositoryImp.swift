//
//  UserRepositoryImp.swift
//  CaseProject
//
//  Created by Oguzhan Ozturk on 15.11.2023.
//

import Foundation

class UserRepositoryImp: UserRepository {
    
    func fetchUsers(next: String?) async -> Result<FetchResponse, FetchError> {
        let result: Result<FetchResponse, FetchError> = await withCheckedContinuation { contiunation in
            DataSource.fetch(next: next) { response, error in
                if let error = error { contiunation.resume(returning: .failure(error)) }
                if let response = response { contiunation.resume(returning: .success(response)) }
            }
        }
        return result
    }
    
}
