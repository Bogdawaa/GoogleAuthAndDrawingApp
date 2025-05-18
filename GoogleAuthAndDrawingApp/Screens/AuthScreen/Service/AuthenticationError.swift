//
//  AuthError.swift
//  GoogleAuthAndDrawingApp
//
//  Created by Bogdan Fartdinov on 18.05.2025.
//

import Foundation

enum AuthenticationError: Error {
    case configurationError(message: String)
    case tokenError(message: String)
    case unknown(message: String)
    case firebaseError(error: Error)
}

extension AuthenticationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .configurationError(let message):
            return "Configuration Error: \(message)"
        case .tokenError(let message):
            return "Token Error: \(message)"
        case .unknown(let message):
            return "Unknown Error: \(message)"
        case .firebaseError(let error):
            return "Firebase Error: \(error.localizedDescription)"
        }
    }
}
