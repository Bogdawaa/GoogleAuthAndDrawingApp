import Combine
import Foundation

@MainActor
final class RecoverPasswordViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var isLoading: Bool = false
    @Published var isSendButtonEnabled: Bool = false
    @Published var errorMessage: String? = nil
    @Published private(set) var isRecoverySuccessful: Bool = false

    
    private var cancellables: Set<AnyCancellable> = []
    
    private var authService: AuthService
    
    init (authService: AuthService) {
        self.authService = authService
        
        $email
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .map { email in
                return Validation.email.isValid(email)
            }
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: \.isSendButtonEnabled, on: self)
            .store(in: &cancellables)
    }
    
}

// MARK: - RecoverPasswordViewModel Extension
extension RecoverPasswordViewModel {
    func resetPassword() {
        isLoading = true
        errorMessage = nil
        
        authService
            .sendPasswordReset(withEmail: email)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.isLoading = false
                case .failure(let error):
                    self?.isLoading = false
                    self?.errorMessage = error.localizedDescription
                    print("*** Error in \(#function): \(error)")
                }
            } receiveValue: { [weak self] result in
                self?.errorMessage = nil
                self?.isRecoverySuccessful = true
            }
            .store(in: &cancellables)
    }
}
