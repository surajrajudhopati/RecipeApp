import Foundation
import Combine

final class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    
    @Published var favorites: [Recipe] = []
    private let favoritesKey = "favorites"

    private init() {
        loadFavorites()
    }
    
    func isFavorite(recipe: Recipe) -> Bool {
        favorites.contains { $0.id == recipe.id }
    }
    
    func toggleFavorite(recipe: Recipe) {
        if isFavorite(recipe: recipe) {
            favorites.removeAll { $0.id == recipe.id }
        } else {
            favorites.append(recipe)
        }
        saveFavorites()
    }
    
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey) {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([Recipe].self, from: data) {
                favorites = decoded
            }
        }
    }
    
    private func saveFavorites() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(favorites) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }
}
