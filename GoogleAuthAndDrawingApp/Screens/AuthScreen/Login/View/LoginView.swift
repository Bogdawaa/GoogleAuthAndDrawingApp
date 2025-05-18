import SwiftUI

struct LoginView: View {
    
    // MARK: - Properties
    @ObservedObject var router = Router.shared
    @StateObject private var viewModel: LoginViewModel = LoginViewModel(authService: FirebaseAuthServiceImpl())
    
    // MARK: - Body
    var body: some View {
        Spacer()
        Text("Авторизация")
            .font(.title)
        VStack(alignment: .leading, spacing: 15) {
            Text("Email")
            TextField("Введите email", text: $viewModel.email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocorrectionDisabled(true)
                .autocapitalization(.none)
            
            Text("Пароль")
            SecureField("Ввдедите пароль", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)
                .textContentType(.password)
        }
        .padding()
        
        HStack {
            Spacer()
            
            Button {
                router.showRecoverPasswordModal()
            } label: {
                Text("Забыли пароль")
            }
        }
        .padding(.horizontal)
        
        Button {
            viewModel.signIn()
        }
        label: {
            Text("Войти")
                .frame(maxWidth: .infinity, maxHeight: 40)
                .background(!viewModel.isLoginButtonEnabled ? Color.gray : Color.yellow)
                .foregroundStyle(.white)
                .clipShape(.capsule)
                .padding()
        }
        .disabled(!viewModel.isLoginButtonEnabled)
        
        Button {
            viewModel.signInWithGoogle()
        } label: {
            Text("Google")
                .foregroundStyle(.black)
        }
        
        Spacer()
        
        Button {
            router.goToRegistration()
        } label: {
            Text("Нет аккаунта?")
                .frame(maxWidth: .infinity, maxHeight: 40)
        }
    }
}


//#Preview {
//    AuthView()
//}
