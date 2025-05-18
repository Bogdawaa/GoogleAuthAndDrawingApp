import SwiftUI

struct RegistrationView: View {
    
    @ObservedObject var router = Router.shared
    @StateObject private var viewModel: RegistrationViewModel = RegistrationViewModel()
    
    var body: some View {
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
                if viewModel.errorMessage == nil {
                    router.goToEmailConfirmation()
                }
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
}

//#Preview {
//    RegistrationView()
//}
