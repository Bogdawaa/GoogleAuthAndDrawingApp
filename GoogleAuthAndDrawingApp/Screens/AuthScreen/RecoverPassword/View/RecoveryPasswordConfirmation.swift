import SwiftUI

struct RecoveryPasswordConfirmation: View {
    
    @ObservedObject var router: Router = Router.shared
    @ObservedObject var viewModel: RecoverPasswordViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle")
                .resizable()
                .frame(maxWidth: 100, maxHeight: 100)
            Text("На ваш email было направлено письмо с подтверждением")
                .font(.title)
                .multilineTextAlignment(.center)

                
            HStack {
                Button {
                    viewModel.resetPassword()
                } label: {
                    Text("Отправить повторно")
                        .frame(maxWidth: .infinity, maxHeight: 40)
                        .background(Color.yellow)
                        .foregroundStyle(.white)
                        .clipShape(.capsule)
                }
                
                Button {
                    router.dismissModal()
                } label: {
                    Text("Закрыть")
                        .frame(maxWidth: .infinity, maxHeight: 40)
                        .background(Color.yellow)
                        .foregroundStyle(.white)
                        .clipShape(.capsule)
                }
            }
        }
        .padding()
        .alert("Ошибка", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "Неизвестная ошибка")
        }
    }
}

//#Preview {
//    RecoveryPasswordConfirmation()
//}

