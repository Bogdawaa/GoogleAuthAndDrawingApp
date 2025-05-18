//
//  Validation.swift
//  GoogleAuthAndDrawingApp
//
//  Created by Bogdan Fartdinov on 15.05.2025.
//

import Foundation

enum ValidationError: Error {
    case invalidEmail
    case invalidPassword
    case passwordsDoNotMatch
}

enum Validation {
    case email
    case password
    
    func isValid(_ value: String) -> Bool {
        switch self {
        case .email:
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
            return predicate.evaluate(with: value)
        case .password:
            let passwordRegex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d).{8,}$"
            let predicate = NSPredicate(format:"SELF MATCHES %@", passwordRegex)
            return predicate.evaluate(with: value)
        }
    }
}
