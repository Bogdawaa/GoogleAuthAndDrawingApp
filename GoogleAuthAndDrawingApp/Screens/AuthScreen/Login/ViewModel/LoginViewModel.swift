import Combine
import Foundation


@MainActor
final class LoginViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoginButtonEnabled = false
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    private var authService: AuthService
    
    private var cancellables = Set<AnyCancellable>()
    
    init (authService: AuthService) {
        self.authService = authService
        
        $email
            .combineLatest($password)
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .map { email, password in
                return Validation.email.isValid(email) && Validation.password.isValid(password)
            }
            .assign(to: \.isLoginButtonEnabled, on: self)
            .store(in: &cancellables)
    }
    
}

// MARK: - LoginViewModel Extension
extension LoginViewModel {
    func signIn() {
        isLoading = true
        authService
            .signIn(withEmail: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.isLoading = false
                    print("Login finished")
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
    
    func signInWithGoogle() {
        isLoading = true
        
        authService.signInWithGoogle()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                switch completion {
                case .finished:
                    self.isLoading = false
                    self.errorMessage = nil
                case .failure(let error):
                    print("*** Error in \(#function): \(error)")
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }, receiveValue: { [weak self] _ in
                self?.errorMessage = nil
            })
            .store(in: &cancellables)
    }
}
