import SwiftUI

// Simple test to verify our SwiftUI components compile
@available(iOS 14.0, *)
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
        if #available(iOS 14.0, *) {
            if #available(iOS 15.0, *) {
                DashboardTest()
                    .previewDevice("iPad Pro (12.9-inch) (6th generation)")
                    .previewInterfaceOrientation(.landscapeLeft)
            } else {
                // Fallback on earlier versions
            }
            if #available(iOS 15.0, *) {
                DashboardTest()
                    .previewDevice("iPad Pro (12.9-inch) (6th generation)")
                    .previewInterfaceOrientation(.landscapeLeft)
            } else {
                // Fallback on earlier versions
            }
        } else {
            // Fallback on earlier versions
        }
    }
}
#endif
