import SwiftUI

struct ContentView: View {
    @State private var store = AppStore()

    var body: some View {
        TabView {
            ProjectListView(store: store)
                .tabItem {
                    Label("Projects", systemImage: "square.grid.2x2")
                }

            DrillStockView(store: store)
                .tabItem {
                    Label("Drill Stock", systemImage: "cylinder.split.1x2")
                }

            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
    }
}

#Preview {
    ContentView()
}
