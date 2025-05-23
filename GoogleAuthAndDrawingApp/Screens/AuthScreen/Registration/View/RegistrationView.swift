import SwiftUI

struct RegistrationView: View {
    
    @ObservedObject var router = Router.shared
    @StateObject private var viewModel: RegistrationViewModel = RegistrationViewModel(authService: FirebaseAuthServiceImpl())
    
    var body: some View {
        
        ZStack {
            VStack {
                Spacer()
                
                Text("Регистрация")
                    .font(.title)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Email")
                    TextField("Введите email", text: $viewModel.email)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.emailAddress)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                    
                    Text("Пароль")
                    SecureField("Ввдедите пароль", text: $viewModel.password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.password)
                    
                    
                    Text("Повторите пароль")
                    SecureField("Ввдедите пароль", text: $viewModel.confirmPassword)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.password)
                    
                    Button {
                        viewModel.register()
//                        if viewModel.errorMessage == nil {
//                            router.goToEmailConfirmation()
//                        }
                    } label: {
                        Text("Регистрация")
                            .frame(maxWidth: .infinity, maxHeight: 40)
                            .background(viewModel.isRegistraionButtonEnabled ? Color.yellow : Color.gray)
                            .foregroundStyle(.white)
                            .clipShape(.capsule)
                            .padding(.top)
                    }
                    .disabled(!viewModel.isRegistraionButtonEnabled)
                }
                .padding()
                
                Spacer()
                Spacer()
            }
            .padding()
            .blur(radius: viewModel.isLoading ? 3 : 0)

            if viewModel.isLoading {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                
                ProgressView()
                    .scaleEffect(2)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }
        .alert("Ошибка", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "Неизвестная ошибка")
        }
        .onChange(of: viewModel.isRegistrationSuccessful) { success in
            if success && viewModel.errorMessage == nil {
                router.goToEmailConfirmation()
            }
        }
    }
}

//#Preview {
//    RegistrationView()
//}
