//
//  PickupShiftModel.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-12-25.
//

import Foundation
import FirebaseFunctions

class PickupShiftModalViewModel: ObservableObject {
    @Published var error: ErrorAlert?
    
    func deleteShift(_ shift: Shift, completion: @escaping (Result<String?, Error>) -> Void) {
        guard let shiftId = shift.id else {
            print("No shiftId, cannot delete shift.")
            self.error = ErrorAlert(title: "Error deleting shift", message: "No shift id found.")
            completion(.failure(NSError()))
            return
        }
        
        let functions = Functions.functions()
        
        functions.httpsCallable("deleteShift").call(["shiftId": shiftId]) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error as NSError? {
                self.handleError(error, "Error deleting shift")
                completion(.failure(error))
            } else {
                print("Shift successfully deleted")
                completion(.success(nil))
            }
        }
    }
    
    func pickupShift(shiftId: String?, userData: UserData?, completion: @escaping (Result<String, Error>) -> Void) {
        guard let shiftId = shiftId, let userData = userData else {
            print("No shift id or userData found")
            self.error = ErrorAlert(title: "Error accepting shift", message: "Shift ID or user data not found")
            completion(.failure(NSError()))
            return
        }
        
        let offer = Offer(shiftId: shiftId)
        guard let offerDict = offer.toDictionary() else {
            print("Unable to encode offer")
            completion(.failure(NSError()))
            return
        }
        
        //Call cloud function
        let functions = Functions.functions()
        
        functions.httpsCallable("pickupShift").call(["offer": offerDict]) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error as NSError? {
                self.handleError(error, "Error accepting shift")
                completion(.failure(error))
            } else if let offerId = (result?.data as? [String: Any])?["offerId"] as? String {
                completion(.success(offerId))
            }
        }
    }
    
    private func handleError(_ error: NSError, _ title: String) {
        if error.domain == FunctionsErrorDomain {
            let code = FunctionsErrorCode(rawValue: error.code)
            let message = error.localizedDescription
            let details = error.userInfo[FunctionsErrorDetailsKey]
            print("Error occurred: [Code: \(code ?? .unknown)], Message: \(message), Details: \(details ?? "")")
            self.error = ErrorAlert(title: title, message: "\(message)")
        }
    }
}
