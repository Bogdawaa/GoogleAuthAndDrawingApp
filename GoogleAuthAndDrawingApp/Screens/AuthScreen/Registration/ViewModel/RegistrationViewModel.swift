import Foundation
import Combine

final class RegistrationViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isRegistraionButtonEnabled: Bool = false
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published private(set) var isRegistrationSuccessful: Bool = false
    
    private var cancellables: Set<AnyCancellable> = []
    private var authService: AuthService
    
    init (authService: AuthService) {
        self.authService = authService
        
        $email
            .combineLatest($password, $confirmPassword)
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .map { email, password, confirmPassword in
                return Validation.email.isValid(email) && Validation.password.isValid(password) && password == confirmPassword
            }
            .assign(to: \.isRegistraionButtonEnabled, on: self)
            .store(in: &cancellables)
    }
}

// MARK: - RegistrationViewModel Extension
extension RegistrationViewModel {
    func register() {
        isLoading = true
        errorMessage = nil
        
        authService
            .signUp(withEmail: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.isLoading = false
                    print("Login finished")
                case .failure(let error):
                    print("Login failed")
                    self?.errorMessage = error.localizedDescription
                    self?.isLoading = false

                }
            } receiveValue: { [weak self] result in
                self?.errorMessage = nil
                self?.isRegistrationSuccessful = true
                self?.sendEmailVerification()
            }
            .store(in: &cancellables)

    }
    
    func sendEmailVerification() {
        isLoading = true
        errorMessage = nil
        
        authService
            .sendEmailVerification()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.isLoading = false
                    print("Register finished")
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.isLoading = false
                    print("*** Error in \(#function): \(error)")
                }
            } receiveValue: { [weak self] result in
                self?.errorMessage = nil
            }
            .store(in: &cancellables)
    }
}
