import SwiftUI

struct AuthView: View {
    
    @ObservedObject var router = Router.shared
    @StateObject var passwordRecoveryViewModel = RecoverPasswordViewModel(authService: FirebaseAuthServiceImpl())
    @StateObject var emailConfirmationViewModel = RegistrationViewModel(authService: FirebaseAuthServiceImpl())

    
    
    var body: some View {
        NavigationStack(path: $router.path) {
            LoginView(router: router)
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .goToRegistration:
                        RegistrationView(router: router)
                    case .goToEmailConfirmation:
                        EmailSendConfirmationView(router: router, viewModel: emailConfirmationViewModel)
                    case .goToMain:
                        MainView(router: router)
                    }
                }
                .sheet(item: $router.modal) { modalRoute in
                    switch modalRoute {
                    case .showRecoverPasswordModal:
                        RecoverPasswordView(router: router, viewModel: passwordRecoveryViewModel)
                    case .showRecoverPasswordConfirmation:
                        RecoveryPasswordConfirmation(router: router, viewModel: passwordRecoveryViewModel)
                    }
                }
        }
    }
}
