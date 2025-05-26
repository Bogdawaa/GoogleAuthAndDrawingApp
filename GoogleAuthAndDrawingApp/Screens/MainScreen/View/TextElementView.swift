import SwiftUI

struct TextElementView: View {
    @Binding var textElement: TextElement
    @ObservedObject var viewModel: DrawingViewModel
    
    var body: some View {
        ZStack {
            Text(textElement.text)
                .font(.system(size: textElement.fontSize * textElement.scale))
                .foregroundColor(textElement.color)
                .rotationEffect(textElement.rotation + viewModel.rotation)
                .background(
                    GeometryReader { textGeometry in
                        Color.clear
                            .preference(key: TextSizePreferenceKey.self, value: textGeometry.size)
                    }
                )
                .onPreferenceChange(TextSizePreferenceKey.self) { size in
                    viewModel.updateTextSize(textElement.id, size: size)
                }
                .overlay(
                    Group {
                        if textElement.isSelected {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.blue, lineWidth: 2)
                                .frame(
                                    width: textElement.size.width + 8,
                                    height: textElement.size.height + 8
                                )
                                .rotationEffect(textElement.rotation + viewModel.rotation)
                                .position(x: textElement.size.width/2, y: textElement.size.height/2)
                        }
                    }
                )
                .position(textElement.position)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if textElement.isSelected {
                                viewModel.updateTextPosition(textElement.id, newPosition: value.location)
                            }
                        }
                )
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            if textElement.isSelected {
                                viewModel.updateTextScale(textElement.id, newScale: value)
                            }
                        }
                )
                .onTapGesture {
                    viewModel.deselectTextElements()
                    textElement.isSelected = true
                }
                .gesture(
                    TapGesture(count: 2)
                        .onEnded({ _ in
                            if textElement.isSelected {
                                withAnimation {
                                    viewModel.currentText = textElement.text
                                    viewModel.isAddingText = true
                                    viewModel.textElements.removeAll { $0.id == textElement.id }
                                }
                            }
                        })
                )
        }
    }
}
