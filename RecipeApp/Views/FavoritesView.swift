import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager

    var body: some View {
        List {
            if favoritesManager.favorites.isEmpty {
                Text("No favorites saved.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(favoritesManager.favorites) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                        RecipeRow(recipe: recipe)
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.inline)
        
    }
}
