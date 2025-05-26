//
//  TextModel.swift
//  GoogleAuthAndDrawingApp
//
//  Created by Bogdan Fartdinov on 23.05.2025.
//

import Foundation
import SwiftUI

struct TextElement: Identifiable {
    let id = UUID()
    var text: String
    var position: CGPoint
    var rotation: Angle = .zero
    var scale: CGFloat = 1.0
    var color: Color = .black
    var fontSize: CGFloat = 24
    var isSelected = false
    var isEditing = false
    var size: CGSize = .zero
}
