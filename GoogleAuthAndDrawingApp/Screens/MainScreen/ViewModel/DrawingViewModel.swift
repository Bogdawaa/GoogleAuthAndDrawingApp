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
    @Published var showImageSourceSelection = false
    @Published var sourceType: ImagePicker.SourceType = .library
    
    @Published var drawing = PKDrawing()
    @Published var toolPiker = PKToolPicker()
    
    @Published var currentFilter: FilterService.FilterType = .none
    @Published var filteredImage: UIImage?

    @Published var textElements: [TextElement] = []
    @Published var currentText: String = ""
    @Published var isAddingText = false
    @Published var selectedTextColor: Color = .black
    @Published var selectedFontSize: CGFloat = 24
    
    // MARK: - Computed properties
    @Published var isDrawingEnabled = true {
        didSet {
            updateToolPickerVisibility()
        }
    }
    
    private var canvasView: PKCanvasView?

    
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
        let radians = Angle(degrees: degrees).radians
        let center = CGPoint(x: containerSize.width/2, y: containerSize.height/2)
        
        let newTotal = accumulatedRotation + degrees
        let newRotation = newTotal.truncatingRemainder(dividingBy: 360)
        rotation = .degrees(newRotation)
        accumulatedRotation = newTotal
        
        for index in textElements.indices {
            let dx = textElements[index].position.x - center.x
            let dy = textElements[index].position.y - center.y
            
            let newX = center.x + dx * cos(radians) - dy * sin(radians)
            let newY = center.y + dx * sin(radians) + dy * cos(radians)
            
            textElements[index].position = CGPoint(x: newX, y: newY)
        }
        
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
    
    func applyScaleToAllElements(scale: CGFloat) {
        let delta = scale / self.scale
        self.scale = scale
        
        for index in textElements.indices {
            textElements[index].scale *= delta
            textElements[index].position = CGPoint(
                x: textElements[index].position.x * delta,
                y: textElements[index].position.y * delta
            )
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
        let center = CGPoint(x: size.width/2, y: size.height/2)
        
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { ctx in
            
            UIColor.white.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            
            ctx.cgContext.saveGState()
            
            ctx.cgContext.translateBy(x: center.x, y: center.y)
            ctx.cgContext.rotate(by: CGFloat(rotation.radians))
            ctx.cgContext.scaleBy(x: scale, y: scale)
            ctx.cgContext.translateBy(x: -center.x, y: -center.y)
            ctx.cgContext.translateBy(x: offset.width, y: offset.height)
            
            baseImage.draw(in: CGRect(origin: .zero, size: size))
            
            let drawingImage = drawing.image(
                from: CGRect(origin: .zero, size: size),
                scale: UIScreen.main.scale
            )
            drawingImage.draw(in: CGRect(origin: .zero, size: size))
            
            ctx.cgContext.restoreGState()
            
            for textElement in textElements {
                ctx.cgContext.saveGState()
                
                let textPosition = CGPoint(
                    x: (textElement.position.x - center.x) * scale + center.x + offset.width,
                    y: (textElement.position.y - center.y) * scale + center.y + offset.height
                )
                
                ctx.cgContext.translateBy(x: textPosition.x, y: textPosition.y)
                ctx.cgContext.rotate(by: CGFloat((rotation + textElement.rotation).radians))
                ctx.cgContext.scaleBy(x: textElement.scale, y: textElement.scale)
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: textElement.fontSize),
                    .foregroundColor: UIColor(textElement.color),
                    .paragraphStyle: paragraphStyle
                ]
                
                let textSize = (textElement.text as NSString).size(withAttributes: attributes)
                let textRect = CGRect(
                    x: -textSize.width/2,
                    y: -textSize.height/2,
                    width: textSize.width,
                    height: textSize.height
                )
                
                (textElement.text as NSString).draw(in: textRect, withAttributes: attributes)
                ctx.cgContext.restoreGState()
            }
        }
    }
}


// MARK: - Drawing
extension DrawingViewModel {
    
    func reset() {
        drawing = PKDrawing()
        scale = 1
        lastScale = 1
        rotation = .zero
        offset = .zero
        lastOffset = .zero
        textElements.removeAll()
    }
    
    func clearDrawing() {
        drawing = PKDrawing()
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

// MARK: - Text Elements
extension DrawingViewModel {
    func addTextElement() {
        guard let image = image else { return }
        
        let newElement = TextElement(
            text: currentText,
            position: CGPoint(x: containerSize(for: image).width/2, y: containerSize(for: image).height/2),
            color: selectedTextColor,
            fontSize: selectedFontSize
        )
        textElements.append(newElement)
        currentText = ""
        isAddingText = false
    }
    
    func updateTextPosition(_ id: UUID, newPosition: CGPoint) {
        if let index = textElements.firstIndex(where: { $0.id == id }) {
            textElements[index].position = newPosition
        }
    }

    func updateTextScale(_ id: UUID, newScale: CGFloat) {
        if let index = textElements.firstIndex(where: { $0.id == id }) {
            textElements[index].scale = newScale
        }
    }
    
    func updateTextRotation(_ id: UUID, newRotation: Angle) {
        if let index = textElements.firstIndex(where: { $0.id == id }) {
            textElements[index].rotation = newRotation
        }
    }
    
    func updateTextSize(_ id: UUID, size: CGSize) {
        if let index = textElements.firstIndex(where: { $0.id == id }) {
            textElements[index].size = size
        }
    }
    
    func selectTextElement(_ id: UUID) {
        textElements.indices.forEach { index in
            textElements[index].isSelected = (textElements[index].id == id)
        }
    }
    
    func deselectTextElements() {
        textElements.indices.forEach { index in
            textElements[index].isSelected = false
        }
    }
}

// MARK: - PencilKit setup
extension DrawingViewModel {
    
    func setupToolPicker(for canvasView: PKCanvasView) {
        self.canvasView = canvasView
        updateToolPickerVisibility()
    }
    
    func updateToolPickerVisibility() {
        guard let canvasView = canvasView else { return }
        
        if isDrawingEnabled {
            toolPiker.addObserver(canvasView)
            toolPiker.setVisible(true, forFirstResponder: canvasView)
            canvasView.becomeFirstResponder()
        } else {
            toolPiker.setVisible(false, forFirstResponder: canvasView)
            toolPiker.removeObserver(canvasView)
        }
        canvasView.isUserInteractionEnabled = isDrawingEnabled
    }
}

// MARK: - Sharing
extension DrawingViewModel {
    func shareImage(completion: @escaping (UIImage?) -> Void) {
        let imageToRender = currentFilter == .none ? image : filteredImage
        let renderedImage = renderCombinedImage(baseImage: imageToRender)
        completion(renderedImage)
    }
}
