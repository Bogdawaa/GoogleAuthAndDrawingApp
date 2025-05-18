//
//  Router.swift
//  GoogleAuthAndDrawingApp
//
//  Created by Bogdan Fartdinov on 16.05.2025.
//

import Foundation

final class Router: ObservableObject {
    
    static let shared = Router()

    @Published var path = [Route]()
    @Published var modal: ModalRoute? = nil
    
}

// MARK: - Route
extension Router {
    func goToRegistration() {
        path.append(.goToRegistration)
    }
    
    func goToEmailConfirmation() {
        path.append(.goToEmailConfirmation)
    }
    
    func backToRoot() {
        path.removeAll()
    }
    
    func back() {
        path.removeLast()
    }
}

// MARK: - Modal
extension Router {
    func showRecoverPasswordModal() {
        modal = .showRecoverPasswordModal
    }
    
    func showRecoveryPasswordConfirmationModal() {
        modal = .showRecoverPasswordConfirmation
    }
    
    func dismissModal() {
        modal = nil
    }
}

