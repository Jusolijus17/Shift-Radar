//
//  UserData.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-11-29.
//

import Foundation
import FirebaseFirestoreSwift

class UserData: ObservableObject, Codable {
    @DocumentID var id: String?
    @Published var firstName: String
    @Published var lastName: String
    @Published var email: String
    @Published var employeeNumber: String
    @Published var phoneNumber: String?
    @Published var profileImageUrl: String?
    @Published var creationDate: Date?
    
    enum CodingKeys: CodingKey {
        case id
        case firstName
        case lastName
        case email
        case employeeNumber
        case phoneNumber
        case profileImageUrl
        case creationDate
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(email, forKey: .email)
        try container.encode(employeeNumber, forKey: .employeeNumber)
        try container.encodeIfPresent(phoneNumber, forKey: .phoneNumber)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(String.self, forKey: .id)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        email = try container.decode(String.self, forKey: .email)
        employeeNumber = try container.decode(String.self, forKey: .employeeNumber)
        phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
        profileImageUrl = try container.decodeIfPresent(String.self, forKey: .profileImageUrl)
        creationDate = try container.decodeIfPresent(Date.self, forKey: .creationDate)
    }
    
    // Default init
    init(firstName: String, lastName: String, email: String, employeeNumber: String, 
         phoneNumber: String? = nil, profileImageUrl: String? = nil, creationDate: Date? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.employeeNumber = employeeNumber
        self.phoneNumber = phoneNumber
        self.profileImageUrl = profileImageUrl
        self.creationDate = creationDate
    }
}

extension UserData {
    static func newUser() -> UserData {
        return UserData(
            firstName: "",
            lastName: "",
            email: "",
            employeeNumber: ""
        )
    }
    
    static func dummyUser() -> UserData {
        return UserData(
            firstName: "John",
            lastName: "Summit",
            email: "john.summit@aircanada.ca",
            employeeNumber: "123456",
            phoneNumber: "450-123-4567",
            creationDate: Date()
        )
    }
}
