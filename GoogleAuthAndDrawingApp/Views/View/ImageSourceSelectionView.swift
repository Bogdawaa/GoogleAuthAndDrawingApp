import SwiftUI

struct ImageSourceSelectionView: View {
    @Binding var showImageSourceSelection: Bool
    @Binding var showImagePicker: Bool
    @Binding var sourceType: ImagePicker.SourceType
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Выберите источник изображения")
                .font(.headline)
                .padding(.top)
            
            Button(action: {
                sourceType = .library
                showImageSourceSelection = false
                showImagePicker = true
            }) {
                HStack {
                    Image(systemName: "photo.on.rectangle")
                    Text("Галерея")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            
            Button(action: {
                sourceType = .camera
                showImageSourceSelection = false
                showImagePicker = true
            }) {
                HStack {
                    Image(systemName: "camera")
                    Text("Камера")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            
            Button("Отмена") {
                showImageSourceSelection = false
            }
            .padding()
        }
        .padding()
        .presentationDetents([.height(220)])
    }
}
