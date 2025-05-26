import SwiftUI
import PencilKit

struct DrawingContentView: View {
    @ObservedObject var viewModel: DrawingViewModel
    @GestureState private var isInteracting: Bool
    
    init(viewModel: DrawingViewModel) {
        self.viewModel = viewModel
        self._isInteracting = GestureState(initialValue: false)
    }
    
    var body: some View {
        if let image = viewModel.currentFilter == .none ? viewModel.image : viewModel.filteredImage {
            
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
                                .onChanged(viewModel.handleDragChange)
                                .onEnded { _ in
                                    viewModel.handleDragEnded(containerSize: containerSize)
                                }
                        )
                    
                    // Drawing layer
                    PencilKitRepresentable(
                        viewModel: viewModel,
                        drawing: $viewModel.drawing,
                        isDrawingEnabled: $viewModel.isDrawingEnabled,
                    )
                    .frame(width: containerSize.width, height: containerSize.height)
                    .scaleEffect(viewModel.scale)
                    .rotationEffect(viewModel.rotation)
                    .offset(viewModel.offset)
                    
                    // Text layers
                    ForEach($viewModel.textElements) { $textElement in
                        TextElementView(
                            textElement: $textElement,
                            viewModel: viewModel
                        )
                    }
                    
                    // Text editing
                    if viewModel.isAddingText {
                        TextEntryView(
                            viewModel: viewModel,
                            text: $viewModel.currentText,
                            isPresented: $viewModel.isAddingText,
                            onCommit: viewModel.addTextElement
                        )
                        .padding()
                        .position(
                            x: containerSize.width/2,
                            y: containerSize.height/2
                        )
                    }
                }
                .frame(width: containerSize.width, height: containerSize.height)
                .background(Color.gray.opacity(0.1))
                .clipped()
                .contentShape(Rectangle())
                .gesture(
                    MagnificationGesture()
                        .updating($isInteracting) { _, out, _ in
                            out = true
                        }
                        .onChanged(viewModel.handleMagnificationChange)
                        .onEnded { _ in
                            viewModel.handleMagnificationEnded()
                        }
                )
                .gesture(
                    TapGesture()
                        .onEnded { _ in
                            viewModel.deselectTextElements()
                        }
                )
            }
            .frame(
                width: viewModel.containerSize(for: image).width,
                height: viewModel.containerSize(for: image).height
            )
        } else {
            Spacer()
            Text("Выберите изображение")
                .font(.headline)
            Spacer()
        }
    }
}
