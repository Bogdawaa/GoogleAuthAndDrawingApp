import SwiftUI

struct RecoverPasswordView: View {
    
    @ObservedObject var router = Router.shared
    @ObservedObject var viewModel: RecoverPasswordViewModel
    
    var body: some View {
        
        VStack() {
            Text("Введите пароль, на который мы отправим Вам ссылку для восстановления")
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(.bottom,20)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Email")
                TextField("Введите email", text: $viewModel.email)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                
                Button {
                    viewModel.resetPassword()
                    // TODO: is success!!!!
                    if viewModel.errorMessage == nil {
                        router.showRecoveryPasswordConfirmationModal()
                    }
                } label: {
                    Text("Отправить")
                        .frame(maxWidth: .infinity, maxHeight: 40)
                        .background(viewModel.isSendButtonEnabled ? Color.yellow : Color.gray)
                        .foregroundStyle(.white)
                        .clipShape(.capsule)
                        .padding(.top)
                        .disabled(viewModel.isSendButtonEnabled)
                }
            }
        }
        .padding()
    }
}

//#Preview {
//    RecoverPasswordView()
//}
