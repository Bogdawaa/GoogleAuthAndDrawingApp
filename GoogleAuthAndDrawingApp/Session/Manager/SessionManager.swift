import Combine
import FirebaseAuth
import Foundation

final class SessionManager: ObservableObject {
    
    @Published var isLoggedIn = false
    
    private let authStateSubject = PassthroughSubject<Bool, Never>()
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        setupAuthStateListener()
    }
}

// MARK: - SessionManager Extension
extension SessionManager {
    private func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                self.authStateSubject.send(user.isEmailVerified)
            } else {
                self.authStateSubject.send(false)
            }
        }
        
        authStateSubject
            .receive(on: DispatchQueue.main)
            .assign(to: \.isLoggedIn, on: self)
            .store(in: &cancellables)
    }
}
