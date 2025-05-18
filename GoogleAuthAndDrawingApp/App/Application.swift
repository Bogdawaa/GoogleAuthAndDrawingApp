//
//  Application.swift
//  GoogleAuthAndDrawingApp
//
//  Created by Bogdan Fartdinov on 15.05.2025.
//

import UIKit
import SwiftUI

final class Application {
    static var rootViewController: UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        
        return root
    }
}
