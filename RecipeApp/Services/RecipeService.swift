import Foundation

final class RecipeService {
    /* 
    private let url: URL
    // Dependency injection initializer.
       init(url: URL) {
           self.url = url
       }
       //Uncomment this for Unit testing
       // Default initializer uses the environment variable. //enable in edit scheme for unit testing
       convenience init() {
           if ProcessInfo.processInfo.environment["UseMalformedEndpoint"] == "true" {
               self.init(url: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-malformed.json")!)
           } else {
               self.init(url: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")!)
           }
       }
    */
    private let url = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")!
    // Swap the URL with the malformed or empty endpoints for testing.

    func fetchRecipes() async throws -> [Recipe] {
        let (data, _) = try await URLSession.shared.data(from: url)

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let recipeDictionaries = json["recipes"] as? [[String: Any]]
        else {
            throw URLError(.badServerResponse)
        }
        
        if recipeDictionaries.isEmpty {
            return []
        }
        
        let parsedRecipes = recipeDictionaries.map { Recipe(from: $0) }
        
        if parsedRecipes.contains(where: { $0 == nil }) {
            throw URLError(.badServerResponse)
        }
        
        return parsedRecipes.compactMap { $0 }
    }
}
