import Combine
import Foundation

final class MainViewModel: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    @Published var showSettingsPanel = false
    @Published var showSignoutConfirmation = false


    
    private var authService = FirebaseAuthServiceImpl()
    private var cancellables: Set<AnyCancellable> = []
    
}

// MARK: - MainViewModel Extension
extension MainViewModel {
    func singOut() {
        isLoading = true
        
        authService
            .signOut()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                    case .failure(let error):
                    self?.isLoading = false
                    self?.errorMessage = error.localizedDescription
                    print("*** Error in \(#function): \(error)")
                case .finished:
                    self?.isLoading = false
                }
            } receiveValue: { [weak self] result in
                self?.errorMessage = nil
            }
            .store(in: &cancellables)
    }
}
