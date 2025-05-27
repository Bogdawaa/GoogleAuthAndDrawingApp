import SwiftUI
import PencilKit
import PhotosUI

struct DrawingView: View {
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    
    @GestureState private var isInteracting: Bool = false
    @StateObject private  var viewModel = DrawingViewModel()
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top panel
            VStack(spacing: 0) {
                
                Color.clear
                    .frame(height: viewModel.safeAreaInsets.top)
                
                topToolView
                    .padding()
            }
            .background(Color(.systemBackground))
            .edgesIgnoringSafeArea(.top)
            
            Spacer()
            
            ZStack {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.deselectTextElements()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                DrawingContentView(viewModel: viewModel)
                
            }
            
            Spacer()
            
            // MARK: - Bottom panels
            if let image = viewModel.image {
                VStack(spacing: 0) {
                    rotationSlider
                    rotationPanel
                    bottomToolView
                }
                .background(Color(.systemBackground))
            }
        }
        .edgesIgnoringSafeArea(.vertical)
        .sheet(isPresented: $viewModel.showImageSourceSelection) {
            ImageSourceSelectionView(
                showImageSourceSelection: $viewModel.showImageSourceSelection,
                showImagePicker: $viewModel.isShownImagePicker,
                sourceType: $viewModel.sourceType
            )
        }
        .sheet(isPresented: $viewModel.isShownImagePicker) {
            ImagePicker(image: $viewModel.image, sourceType: viewModel.sourceType)
                .onDisappear {
                    guard viewModel.image?.pngData() == viewModel.originalImage?.pngData() else { return
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.reset()
                            viewModel.originalImage = viewModel.image
                        }
                    }
                }
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
}


// MARK: - UI Extension
extension DrawingView {
    // Верхняя панель инструментов
    private var topToolView: some View {
        HStack {
            // Кнопка очистки контента
            Button(action: {
                
                viewModel.clearDrawing()
            }) {
                Image(systemName: "trash")
                    .font(.title)
            }
            
            Spacer()
            
            // Кнопка режима рисования
            Button(action: {
                viewModel.isDrawingEnabled = true
            }) {
                Image(systemName: "pencil.tip.crop.circle" )
                    .font(.title)
                    .foregroundColor(viewModel.isDrawingEnabled ? .gray : .blue)
            }
            
            Spacer()
            
            // Кнопка режима перемещения
            Button(action: {
                viewModel.isDrawingEnabled = false
            }) {
                Image(systemName: "hand.point.up.left")
                    .font(.title)
                    .foregroundColor(viewModel.isDrawingEnabled ? .blue : .gray)
            }
            
            Spacer()

            // Кнопка выбора фото
            Button(action: {
                viewModel.isDrawingEnabled = false
                viewModel.showImageSourceSelection.toggle()
            }) {
                Image(systemName: "photo")
                    .font(.title)
            }

            Spacer()
            
            Menu {
                // Кнопка сохранения в галерею
                Button(action: {
                    viewModel.isDrawingEnabled = false
                    saveImage()
                }) {
                    Label("Сохранить", systemImage: "photo")
                }
                
                // Кнопка поделиться
                Button(action: {
                    viewModel.isDrawingEnabled = false
                    shareImage()
                }) {
                    Label("Поделиться", systemImage: "arrowshape.turn.up.forward")
                        .font(.title)
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title)
            }
        }
    }
    
    // Слайдер
    private var rotationSlider: some View {
        Slider(
            value: Binding(
                get: { viewModel.rotation.degrees },
                set: {
                    let delta = $0 - viewModel.rotation.degrees
                    viewModel.applyRotation(degrees: delta, containerSize: viewModel.containerSize(for: viewModel.image))
                }
            ),
            in: -45...45,
            step: 1
        )
        .padding(.horizontal)
        .accentColor(.green)
    }

    // Нижняя панель инструментов
    private var bottomToolView: some View {
        HStack {
            Spacer()
            textPanel
            Spacer()
            filterMenu
            Spacer()
        }
        .padding(.horizontal)
        .padding(.bottom, viewModel.safeAreaInsets.bottom)
    }
    
    // Панель поворотов
    private var rotationPanel: some View {
        HStack(spacing: 30) {
            Button {
                viewModel.applyRotation(
                    degrees: -90,
                    containerSize: viewModel.containerSize(for: viewModel.image)
                )
            } label: {
                Image(systemName: "rotate.left")
            }
            
            Text("Rotation: \(viewModel.rotation.degrees, specifier: "%.1f")°")
            
            Button {
                viewModel.applyRotation(
                    degrees: 90,
                    containerSize: viewModel.containerSize(for: viewModel.image)
                )
            } label: {
                Image(systemName: "rotate.right")
            }
        }
        .padding()
    }
    
    // Панель добавления текста
    private var textPanel: some View {
        VStack {
            
            Button(action: {
                viewModel.isAddingText = true
            }) {
                Image(systemName: "textformat")
                    .font(.title)
            }
        }
    }
    
    private var filterMenu: some View {
        Menu {
            ForEach(FilterService.FilterType.allCases, id: \.self) { filter in
                Button {
                    viewModel.applyFilter(filter)
                } label: {
                    HStack {
                        Text(filter.rawValue)
                        Spacer()
                        if viewModel.currentFilter == filter {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "camera.filters")
                .font(.title)
        }
    }
}

// MARK: - Alert Actions
extension DrawingView {
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}


// MARK: - Image activities
extension DrawingView {
    
    private func saveImage() {
        viewModel.saveImageToGallery { success, error in
            if success {
                showAlert(title: "Готово!", message: "Изображение сохранено в галерею!")
            } else if let error = error {
                showAlert(title: "Ошибка", message: error.localizedDescription)

                print("Save failed: \(error.localizedDescription)")
            }
        }
    }
    
    private func shareImage() {
        viewModel.shareImage { image in
            guard let image = image else {
                showAlert(title: "Ошибка", message: "Ошибка при попытке поделиться изображением")
                return
            }
            
            let activityVC = UIActivityViewController(
                activityItems: [image],
                applicationActivities: nil
            )
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                activityVC.popoverPresentationController?.sourceView = rootViewController.view
                rootViewController.present(activityVC, animated: true)
            }
        }
    }
}
