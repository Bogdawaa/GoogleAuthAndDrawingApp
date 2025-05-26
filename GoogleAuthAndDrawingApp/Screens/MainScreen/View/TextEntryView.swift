//
//  TextImageOverlay.swift
//  GoogleAuthAndDrawingApp
//
//  Created by Bogdan Fartdinov on 23.05.2025.
//

import SwiftUI

struct TextEntryView: View {
    @ObservedObject var viewModel: DrawingViewModel
    
    @Binding var text: String
    @Binding var isPresented: Bool
    var onCommit: () -> Void
    
    
    var body: some View {
        VStack {

            HStack {
                // Выбор цвета
                ColorPicker("", selection: $viewModel.selectedTextColor)
                    .labelsHidden()
                    .frame(width: 30, height: 30)

                // Размер текста
                Stepper(value: $viewModel.selectedFontSize, in: 12...72) {
                    Text("Size: \(Int(viewModel.selectedFontSize))")
                }
            }
            
            TextField("Введите текст", text: $text, onCommit: {
                onCommit()
                isPresented = false
            })
            .textFieldStyle(.roundedBorder)
            .padding()
            
            Button("Готово") {
                onCommit()
                isPresented = false
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
