import PencilKit
import SwiftUI

struct PencilKitRepresentable: UIViewRepresentable {
    @ObservedObject var viewModel: DrawingViewModel
    
    @Binding var drawing: PKDrawing
    @Binding var isDrawingEnabled: Bool
    @State private var lastValidDrawing: PKDrawing?

    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView()
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = viewModel.toolPiker.selectedTool
        canvasView.drawing = drawing
        canvasView.delegate = context.coordinator
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
        
//        updateToolPickerVisibility(for: canvasView)
        viewModel.setupToolPicker(for: canvasView)

        DispatchQueue.main.async {
            lastValidDrawing = drawing
        }
        
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        let currentDrawing = uiView.drawing
        
        uiView.tool = viewModel.toolPiker.selectedTool
        
        if currentDrawing.strokes.isEmpty && !drawing.strokes.isEmpty {
            uiView.drawing = drawing
        } else if currentDrawing != drawing {
            uiView.drawing = drawing
        }
        
        if !uiView.drawing.strokes.isEmpty {
            DispatchQueue.main.async {
                lastValidDrawing = uiView.drawing
            }
        }
        
        uiView.isUserInteractionEnabled = isDrawingEnabled
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - Coordinator
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: PencilKitRepresentable

        init(_ parent: PencilKitRepresentable) {
            self.parent = parent
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            if !canvasView.drawing.strokes.isEmpty {
                parent.drawing = canvasView.drawing
                
                DispatchQueue.main.async { [weak self] in
                    self?.parent.lastValidDrawing = canvasView.drawing
                }
            }
        }
    }
}
