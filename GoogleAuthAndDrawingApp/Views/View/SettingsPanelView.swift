import SwiftUI

struct SettingsPanelView: View {
    @ObservedObject var viewModel: MainViewModel
    
    private let buttonSize: CGFloat = 36
    private let iconSize: CGFloat = 20
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: {
                withAnimation(.spring()) {
                    viewModel.showSettingsPanel.toggle()
                }
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: iconSize))
                    .foregroundColor(.white)
                    .frame(width: buttonSize, height: buttonSize)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
            
            if viewModel.showSettingsPanel {
                Button(action: {
                    viewModel.showSignoutConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Выход")
                    }
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.red)
                    .cornerRadius(8)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .alert("Выход", isPresented: $viewModel.showSignoutConfirmation) {
            Button("Отмена", role: .cancel) {}
            Button("Выйти", role: .destructive) {
                viewModel.singOut()
            }
        } message: {
            Text("Вы действительно хотите выйти?")
        }
    }
}
