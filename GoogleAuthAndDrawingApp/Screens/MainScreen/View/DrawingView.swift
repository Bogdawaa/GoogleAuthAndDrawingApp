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
        NavigationStack {
            VStack(spacing: 0) {
                // Top panel
                VStack(spacing: 0) {
                    
                    Color.clear
                        .frame(height: viewModel.safeAreaInsets.top)
                    
                    makeTopToolView()
                        .padding()
                }
                .background(Color(.systemBackground))
                .edgesIgnoringSafeArea(.top)
                
                Spacer()
                
                ZStack {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {}
                    
                    // Content
                    if let image = viewModel.image {
                        
                        GeometryReader { geometry in
                            let containerSize = viewModel.containerSize(for: image)
                            
                            ZStack {
                                // Image layer
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: containerSize.width, height: containerSize.height)
                                    .scaleEffect(viewModel.scale)
                                    .rotationEffect(viewModel.rotation)
                                    .offset(viewModel.offset)
                                    .gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                viewModel.handleDragChange(value)
                                            }
                                            .onEnded({ _ in
                                                viewModel.handleDragEnded(
                                                    containerSize: viewModel.containerSize(for: viewModel.image)
                                                )
                                            })
                                    )
                                
                                // Drawing layer
                                PencilKitRepresentable(
                                    drawing: $viewModel.drawing,
                                    isDrawingEnabled: $viewModel.isDrawingEnabled,
                                    tool: $viewModel.tool,
                                )
                                .frame(width: containerSize.width, height: containerSize.height)
                                .scaleEffect(viewModel.scale)
                                .rotationEffect(viewModel.rotation)
                                .offset(viewModel.offset)
                            }
                            .frame(width: containerSize.width, height: containerSize.height)
                            .background(Color.gray.opacity(0.1))
                            .clipped()
                            .contentShape(Rectangle())
                            .gesture(
                                MagnificationGesture()
                                    .updating($isInteracting, body: { _, out, _ in
                                        out = true
                                    })
                                    .onChanged { value in
                                        viewModel.handleMagnificationChange(value)
                                    }
                                    .onEnded { _ in
                                        viewModel.handleMagnificationEnded()
                                    }
                            )
                        }
                        .frame(width: viewModel.containerSize(for: image).width,
                               height: viewModel.containerSize(for: image).height)
                    } else {
                        Spacer()
                        Text("Выберите изображение")
                            .font(.headline)
                        Spacer()
                    }
                }
                
                
                Spacer()
                
                // Bottom panels
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
            .sheet(isPresented: $viewModel.isShownImagePicker) {
                ImagePicker(image: $viewModel.image)
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
}


// MARK: - UI Extension
extension DrawingView {
    // Верхняя панель инструментов
    func makeTopToolView() -> some View {
        HStack {
            
            Button(action: {
                
                viewModel.clearDrawing()
            }) {
                Image(systemName: "trash")
                    .font(.title)
            }
            
            Spacer()
            
            Button(action: {
                viewModel.isDrawingEnabled.toggle()
            }) {
                Image(systemName: "pencil.tip.crop.circle" )
                    .font(.title)
                    .foregroundColor(viewModel.isDrawingEnabled ? .gray : .blue)
            }
            
            Spacer()
            
            Button(action: {
                viewModel.isDrawingEnabled.toggle()
            }) {
                Image(systemName: "hand.point.up.left")
                    .font(.title)
                    .foregroundColor(viewModel.isDrawingEnabled ? .blue : .gray)
            }
            
            Spacer()

            Button(action: {
                viewModel.isShownImagePicker.toggle()
            }) {
                Image(systemName: "photo")
                    .font(.title)
            }

            Spacer()
            
            Button(action: {
                handleSave()
            }) {
                Image(systemName: "square.and.arrow.down")
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
                    viewModel.applyRotation(
                        degrees: $0 - viewModel.rotation.degrees,
                        containerSize: viewModel.containerSize(for: viewModel.image)
                    )
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
            Group {
                Button(action: {
                    viewModel.setTool(.pen)
                }) {
                    Text("Pen")
                }
                
                Button(action: {
                    viewModel.setTool(.marker)
                }) {
                    Text("Marker")
                }
                
                Button(action: {
                    viewModel.setTool(.eraser)
                }) {
                    Text("Eraser")
                }
            }
            .buttonStyle(.bordered)
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
}

// MARK: - Alert Actions
extension DrawingView {
    private func handleSave() {
        viewModel.saveImageToGallery { success, error in
            if success {
                showAlert(title: "Готово!", message: "Изображение сохранено в галерею!")
            } else if let error = error {
                showAlert(title: "Ошибка", message: error.localizedDescription)

                print("Save failed: \(error.localizedDescription)")
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}
