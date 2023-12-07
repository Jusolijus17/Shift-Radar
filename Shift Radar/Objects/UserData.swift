//
//  UserData.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-11-29.
//

import Foundation

class UserData: ObservableObject, Codable {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var employeeNumber: String = ""
    @Published var profileImageUrl: String?
    
    enum CodingKeys: CodingKey {
        case firstName, lastName, email, employeeNumber, profileImageUrl
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(email, forKey: .email)
        try container.encode(employeeNumber, forKey: .employeeNumber)
        try container.encode(profileImageUrl, forKey: .profileImageUrl)
    }
    
    init() {}
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        email = try container.decode(String.self, forKey: .email)
        employeeNumber = try container.decode(String.self, forKey: .employeeNumber)
        profileImageUrl = try container.decode(String.self, forKey: .profileImageUrl)
    }
}

extension UserData {
    func toDictionary() -> [String: Any] {
        return [
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "employeeNumber": employeeNumber
        ]
    }
}
