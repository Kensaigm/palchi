import SwiftUI

// Simple test to verify our SwiftUI components compile
struct DashboardTest: View {
    @StateObject private var palchiApp = PALCHIApp()
    
    var body: some View {
        NavigationView {
            ContentView()
        }
        .environmentObject(palchiApp)
    }
}

#if DEBUG
struct DashboardTest_Previews: PreviewProvider {
    static var previews: some View {
        DashboardTest()
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
#endif