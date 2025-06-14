import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "ipad")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Text("Welcome to iPad App")
                    .font(.largeTitle)
                    .padding()
            }
            .navigationTitle("My iPad App")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Optimized for iPad
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}