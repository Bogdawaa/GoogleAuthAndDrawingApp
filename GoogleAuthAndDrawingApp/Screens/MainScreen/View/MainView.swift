import SwiftUI

struct MainView: View {
    
    @ObservedObject var router: Router = Router.shared
    @StateObject private var viewModel: MainViewModel = MainViewModel()
    
    var body: some View {        
        DrawingView()
    }
}

