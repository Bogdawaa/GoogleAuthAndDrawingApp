import SwiftUI

struct RecoverPasswordView: View {
    
    @ObservedObject var router = Router.shared
    @ObservedObject var viewModel: RecoverPasswordViewModel
    
    var body: some View {
        ZStack {
            VStack {
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
                    } label: {
                        Text("Отправить")
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .background(viewModel.isSendButtonEnabled ? Color.yellow : Color.gray)
                            .foregroundStyle(.white)
                            .clipShape(.capsule)
                    }
                    .disabled(!viewModel.isSendButtonEnabled)
                    .padding()
                }
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
        .onChange(of: viewModel.isRecoverySuccessful) { _ in
            if viewModel.errorMessage == nil && viewModel.isRecoverySuccessful {
                router.showRecoveryPasswordConfirmationModal()
            }
        }
        .onDisappear {
            viewModel.email = ""
        }
    }
}

//#Preview {
//    RecoverPasswordView()
//}
