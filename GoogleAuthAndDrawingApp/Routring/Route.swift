import Foundation

enum Route: Hashable, Identifiable {
    case goToMain
    case goToRegistration
    case goToEmailConfirmation
    
    var id: Int {
            hashValue
    }
}

enum ModalRoute: Identifiable {
    case showRecoverPasswordModal
    case showRecoverPasswordConfirmation
    
    var id : Int {
        hashValue
    }
}
