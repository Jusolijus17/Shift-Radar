//
//  StaffViewModel.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2024-05-09.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class StaffViewModel: ObservableObject {
    @Published var users: [UserData] = []
    @Published var isLoading = false
    private var lastDocumentSnapshot: DocumentSnapshot?

    init() {
        loadUsers()
    }
    
    func loadUsers() {
        guard !isLoading else { return }
        isLoading = true
        
        var query: Query = Firestore.firestore().collection("users")
        if let lastSnapshot = lastDocumentSnapshot {
            query = query.start(afterDocument: lastSnapshot)
        }
        
        query.limit(to: 10).getDocuments { snapshot, error in
            if let snapshot = snapshot {
                let users = snapshot.documents.compactMap { document -> UserData? in
                    try? document.data(as: UserData.self)
                }
                self.users.append(contentsOf: users)
                self.lastDocumentSnapshot = snapshot.documents.last
            }
            self.isLoading = false
        }
    }
}
