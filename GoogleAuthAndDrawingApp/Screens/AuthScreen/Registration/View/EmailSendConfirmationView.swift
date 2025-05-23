import SwiftUI

struct EmailSendConfirmationView: View {
    
    @ObservedObject var router: Router = Router.shared
    @ObservedObject var viewModel: RegistrationViewModel
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle")
                    .resizable()
                    .frame(maxWidth: 100, maxHeight: 100)
                Text("На ваш email было направлено письмо с подтверждением")
                    .font(.title)
                    .multilineTextAlignment(.center)

                    
                HStack {
                    Button {
                        viewModel.sendEmailVerification()
                    } label: {
                        Text("Отправить повторно")
                            .frame(maxWidth: .infinity, maxHeight: 40)
                            .background(Color.yellow)
                            .foregroundStyle(.white)
                            .clipShape(.capsule)
                    }
                    
                    Button {
                        router.backToRoot()
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
    }
}

//#Preview {
//    EmailSendConfirmationView()
//}
