import Combine
import Foundation
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

final class FirebaseAuthServiceImpl {
    // todo
}

// MARK: - FirebaseAuthServiceImpl Extension
extension FirebaseAuthServiceImpl: AuthService {
    
    func signIn(withEmail email: String, password: String) -> AnyPublisher<AuthDataResult, Error> {
        Future<AuthDataResult, Error> { promise in
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                if let error = error {
                    promise(.failure(error))
                } else if let result = result {
                    promise(.success(result))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func signUp(withEmail email: String, password: String) -> AnyPublisher<AuthDataResult, Error> {
        Future<AuthDataResult, Error> { promise in
            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                if let error = error {
                    promise(.failure(error))
                } else if let result = result {
                    promise(.success(result))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func signOut() -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            do {
                try Auth.auth().signOut()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func sendEmailVerification() -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            guard let user = Auth.auth().currentUser else {
                promise(.failure(NSError(domain: "", code: 0, userInfo: nil)))
                return
            }
            user.sendEmailVerification { error in
                if let error = error {
                    promise(.failure(error))
                }
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func sendPasswordReset(withEmail email: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getCurrentUser() -> User? {
        return Auth.auth().currentUser
    }
    
    func isUserSignedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
    
    
    func isEmailVerified() -> Bool {
        var isVerified: Bool = false
            Auth.auth().currentUser?.reload(completion: { error in
                if let error = error {
                    print("Error reloading user: \(error.localizedDescription)")
                } else {
                    if let user = Auth.auth().currentUser {
                        if user.isEmailVerified {
                            // User's email is verified, proceed
                            print("Email verified, logging in...")
                            isVerified = true
                        } else {
                            // User's email is not verified
                            print("Email not verified")
                            isVerified = false
                        }
                    }
                }
            })
        return isVerified
    }
    
    func signInWithGoogle() -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                promise(.failure(AuthenticationError.configurationError(message: "No client ID found in Firebase configuration")))
                return
            }
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
            
            GIDSignIn.sharedInstance.signIn(withPresenting: Application.rootViewController) { userAuthentication, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                guard let userAuthentication = userAuthentication else {
                    promise(.failure(AuthenticationError.unknown(message: "User authentication data missing")))
                    return
                }
                
                let user = userAuthentication.user
                guard let idToken = user.idToken else {
                    promise(.failure(AuthenticationError.tokenError(message: "ID token missing")))
                    return
                }
                let accessToken = user.accessToken
                let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
                
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
            }
            
        }
        .eraseToAnyPublisher()
    }
    
//    func signInWithGoogle() async -> Bool {
//            guard let clientID = FirebaseApp.app()?.options.clientID else {
//                fatalError("No client ID found in Firebase configuration")
//            }
//            let config = GIDConfiguration(clientID: clientID)
//            GIDSignIn.sharedInstance.configuration = config
//            
//            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//                  let window = windowScene.windows.first,
//                  let rootViewController = window.rootViewController else {
//                return false
//            }
//            do {
//                let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
//                let user = userAuthentication.user
//                guard let idToken = user.idToken else { throw AuthenticationError.tokenError(message: "ID token missing") }
//                let accessToken = user.accessToken
//                let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString,
//                                                               accessToken: accessToken.tokenString)
//                let _  = try await Auth.auth().signIn(with:credential)
//                self.isLoading = false
//                return true
//            }
//            catch {
//                self.errorMessage = error.localizedDescription
//                return false
//            }
//        }
}
