//
//  UserRepository.swift
//  CaseProject
//
//  Created by Oguzhan Ozturk on 15.11.2023.
//

import Foundation

protocol UserRepository {
    
    func fetchUsers(next: String?) async -> Result<FetchResponse,FetchError>
    
}
