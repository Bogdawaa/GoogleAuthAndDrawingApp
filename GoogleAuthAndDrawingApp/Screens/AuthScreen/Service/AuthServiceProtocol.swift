//
//  AuthServiceProtocol.swift
//  GoogleAuthAndDrawingApp
//
//  Created by Bogdan Fartdinov on 18.05.2025.
//

import Combine
import FirebaseAuth

protocol AuthService {
    func signIn(withEmail email: String, password: String) -> AnyPublisher<AuthDataResult, Error>
    func signUp(withEmail email: String, password: String) -> AnyPublisher<AuthDataResult, Error>
    func sendEmailVerification() -> AnyPublisher<Void, Error>
    func sendPasswordReset(withEmail email: String) -> AnyPublisher<Void, Error>
    func signInWithGoogle() -> AnyPublisher<Void, Error>
    func signOut() -> AnyPublisher<Void, Error>
    func getCurrentUser() -> User?
    func isUserSignedIn() -> Bool
    func isEmailVerified() -> Bool
    
}
