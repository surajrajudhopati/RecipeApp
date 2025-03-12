import SwiftUI

@main
struct RecipeAppApp: App {
    var body: some Scene {
        WindowGroup {
            RecipeListView()
                           .environmentObject(FavoritesManager.shared)
        }
    }
}
