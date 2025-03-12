import Foundation
import Combine

@MainActor
final class RecipeListViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var searchText: String = ""
    @Published var isSearchBarVisible: Bool = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let recipeService = RecipeService()

    var filteredRecipes: [Recipe] {
        if searchText.isEmpty {
            return recipes
        } else {
            return recipes.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.cuisine.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var groupedRecipes: [String: [Recipe]] {
        Dictionary(grouping: filteredRecipes) { recipe in
            String(recipe.name.prefix(1)).uppercased()
        }
        .mapValues { $0.sorted { $0.name < $1.name } }
    }

    var sortedSectionTitles: [String] {
        groupedRecipes.keys.sorted()
    }

    func fetchRecipes() async {
        isLoading = true
        errorMessage = nil
        do {
            recipes = try await recipeService.fetchRecipes()
        } catch {
            errorMessage = "Failed to load recipes. Please try again."
        }
        isLoading = false
    }
}
