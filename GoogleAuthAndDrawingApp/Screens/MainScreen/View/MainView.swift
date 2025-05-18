import SwiftUI
import PhotosUI

struct MainView: View {
    
    @State private var avatarItem: PhotosPickerItem?
    @State private var avatarImage: Image?
    
    @ObservedObject var router = Router.shared
    @StateObject var viewModel = MainViewModel()
    
    var body: some View {
        VStack {
            PhotosPicker("Select avatar", selection: $avatarItem, matching: .images)

            avatarImage?
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
            
            Button {
                viewModel.singOut()
            } label: {
                Text("Log out")
            }
            .buttonStyle(.borderedProminent)

        }
        .padding()
        .onChange(of: avatarItem) {
                    Task {
                        if let loaded = try? await avatarItem?.loadTransferable(type: Image.self) {
                            avatarImage = loaded
                        } else {
                            print("Failed")
                        }
                    }
                }
    }
}

//#Preview {
//    MainView()
//}
