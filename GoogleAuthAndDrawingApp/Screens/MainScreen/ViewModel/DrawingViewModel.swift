import SwiftUI
import PencilKit
import PhotosUI

class DrawingViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var image: UIImage?
    @Published var originalImage: UIImage?
    @Published var offset: CGSize = .zero
    @Published var lastOffset: CGSize = .zero
    @Published var rotation: Angle = .zero
    @Published var accumulatedRotation: Double = 0
    @Published var scale: CGFloat = 1.0
    @Published var lastScale: CGFloat = 0.0
    @Published var isShownImagePicker: Bool = false
    @Published var isDrawingEnabled = false
    @Published var drawing = PKDrawing()
    @Published var currentFilter: FilterService.FilterType = .none
    @Published var filteredImage: UIImage?
    @Published var tool: PKTool = PKInkingTool(.pen, color: .black, width: 5)
    @Published var selectedTool: ToolType = .pen

    
    // MARK: - Computed Properties
    var safeAreaInsets: EdgeInsets {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return EdgeInsets()
        }
        let uiInsets = window.safeAreaInsets
        return EdgeInsets(
            top: uiInsets.top,
            leading: uiInsets.left,
            bottom: uiInsets.bottom,
            trailing: uiInsets.right
        )
    }
    
    // Доступное пространство с учетом отступов и панелей
    var availableContentHeight: CGFloat {
        let safeArea = safeAreaInsets
        let screenHeight = UIScreen.main.bounds.height
        let topPanelHeight: CGFloat = 60
        let bottomPanelHeight: CGFloat = 150
        
        return screenHeight - safeArea.top - safeArea.bottom - topPanelHeight - bottomPanelHeight
    }
}

// MARK: - Transformation Methods
extension DrawingViewModel {
    // Рассчет размеров контейнера изображения
    func containerSize(for image: UIImage?) -> CGSize {
        guard let image = image else { return .zero }
        let width = UIScreen.main.bounds.width
        let aspectRatio = image.size.height / image.size.width
        
        let proposedHeight = width * aspectRatio
        let height = min(proposedHeight, availableContentHeight)
        
        if height < proposedHeight {
            let scaleFactor = height / proposedHeight
            return CGSize(width: width * scaleFactor, height: height)
        }
        
        return CGSize(width: width, height: height)
    }
    
    // Рассчет компенсации оффсета при чрезмерном сдвиге
    func clampOffset(for containerSize: CGSize) {
        let maxOffsetValues = maxOffset(for: containerSize)
        offset.width = min(maxOffsetValues.width, max(-maxOffsetValues.width, offset.width))
        offset.height = min(maxOffsetValues.height, max(-maxOffsetValues.height, offset.height))
    }
    
    func applyRotation(degrees: Double, containerSize: CGSize) {
        let newTotal = accumulatedRotation + degrees
        let newRotation = newTotal.truncatingRemainder(dividingBy: 360)
        
        if abs(degrees) < 360 {
            withAnimation {
                rotation = .degrees(newRotation)
            }
        } else {
            rotation = .degrees(newRotation)
        }
        
        accumulatedRotation = newTotal
        adjustScaleForRotation(containerSize: containerSize)
        clampOffset(for: containerSize)
    }
    
    func maxOffset(for containerSize: CGSize) -> CGSize {
        let radians = rotation.radians
        let cosVal = abs(cos(radians))
        let sinVal = abs(sin(radians))
        
        let rotatedWidth = (containerSize.width * cosVal + containerSize.height * sinVal) * scale
        let rotatedHeight = (containerSize.height * cosVal + containerSize.width * sinVal) * scale
        
        return CGSize(
            width: max(0, (rotatedWidth - containerSize.width) / 2),
            height: max(0, (rotatedHeight - containerSize.height) / 2)
        )
    }
    
    func adjustScaleForRotation(containerSize: CGSize) {
        let radians = rotation.radians
        let cosVal = abs(cos(radians))
        let sinVal = abs(sin(radians))
        
        let rotatedWidth = containerSize.width * cosVal + containerSize.height * sinVal
        let rotatedHeight = containerSize.height * cosVal + containerSize.width * sinVal
        
        let widthScale = rotatedWidth / containerSize.width
        let heightScale = rotatedHeight / containerSize.height
        
        let fillScale = min(widthScale, heightScale)
        
        let clampedScale = max(fillScale, 1.0)
        
        withAnimation(.interactiveSpring()) {
            scale = clampedScale
            offset = .zero
            lastOffset = .zero
        }
    }
}

// MARK: - Gesture handlers
extension DrawingViewModel {
    func handleDragChange(_ value: DragGesture.Value) {
        if scale > 1 {
            withAnimation(.easeInOut(duration: 0.1)) {
                offset = CGSize(
                    width: value.translation.width + lastOffset.width,
                    height: value.translation.height + lastOffset.height
                )
            }
        } else {
            withAnimation(.easeInOut(duration: 0.1)) {
                offset = .zero
            }
        }
    }
    
    func handleDragEnded(containerSize: CGSize) {
        withAnimation(.interactiveSpring()) {
            clampOffset(for: containerSize)
            lastOffset = offset
        }
    }
    
    func handleMagnificationChange(_ value: CGFloat) {
        let newScale = lastScale + value
        scale = (newScale < 1 ? 1 : newScale)
    }
    
    func handleMagnificationEnded() {
        withAnimation {
            if scale < 1 {
                scale = 1
                lastScale = 0
                offset = .zero
            } else {
                lastScale = scale - 1
            }
        }
    }
}

// MARK: Saving Extension
extension DrawingViewModel {
    
    func saveImageToGallery(completion: @escaping (Bool, Error?) -> Void) {
        
        let imageToRender = currentFilter == .none ? image : filteredImage
        
        guard let resultlImage = renderCombinedImage(baseImage: imageToRender) else {
            completion(false, NSError(domain: "RenderingError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to render image"]))
            return
        }
        
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            DispatchQueue.main.async {
                guard status == .authorized else {
                    completion(false, NSError(domain: "AuthDenied", code: -2, userInfo: [NSLocalizedDescriptionKey: "Photo library access denied"]))
                    return
                }
                
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: resultlImage)
                }) { success, error in
                    DispatchQueue.main.async {
                        completion(success, error)
                    }
                }
            }
        }
    }
    
    private func renderCombinedImage(baseImage: UIImage?) -> UIImage? {
        guard let baseImage = baseImage else { return nil }
        let size = containerSize(for: baseImage)
        
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            
            let radians = rotation.radians
            ctx.cgContext.saveGState()
            ctx.cgContext.translateBy(x: size.width/2, y: size.height/2)
            ctx.cgContext.rotate(by: CGFloat(radians))
            ctx.cgContext.scaleBy(x: scale, y: scale)
            
            baseImage.draw(in: CGRect(
                x: -size.width/2 + offset.width,
                y: -size.height/2 + offset.height,
                width: size.width,
                height: size.height
            ))
            
            ctx.cgContext.restoreGState()
            
            let drawingImage = drawing.image(
                from: CGRect(origin: .zero, size: size),
                scale: UIScreen.main.scale
            )
            
            drawingImage.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
}

// MARK: - Drawing
extension DrawingViewModel {
    
    enum ToolType: String, CaseIterable {
        case pen = "Pen"
        case marker = "Marker"
        case eraser = "Eraser"
    }
    
    func reset() {
        drawing = PKDrawing()
        scale = 1
        lastScale = 1
        rotation = .zero
        offset = .zero
        lastOffset = .zero
    }
    
    func clearDrawing() {
        drawing = PKDrawing()
    }
    
    func setTool(_ tool: ToolType) {
        selectedTool = tool
        switch tool {
        case .pen:
            self.tool = PKInkingTool(.pen, color: .black, width: 5)
        case .marker:
            self.tool = PKInkingTool(.marker, color: .red, width: 10)
        case .eraser:
            self.tool = PKEraserTool(.bitmap, width: 15)
        }
    }
}

// MARK: - Filter
extension DrawingViewModel {
    func applyFilter(_ filterType: FilterService.FilterType) {
        guard let originalImage = image else { return }
        
        currentFilter = filterType
        filteredImage = FilterService.shared.applyFilter(filterType, to: originalImage)
    }
}
