import Foundation

struct Recipe: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let cuisine: String
    let photoURLSmall: URL?
    let photoURLLarge: URL?
    let sourceURL: URL?
    let youtubeURL: URL?

    enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case name
        case cuisine
        case photoURLSmall = "photo_url_small"
        case photoURLLarge = "photo_url_large"
        case sourceURL = "source_url"
        case youtubeURL = "youtube_url"
    }

    init?(from dictionary: [String: Any]) {
        guard
            let id = dictionary["uuid"] as? String,
            let name = dictionary["name"] as? String,
            let cuisine = dictionary["cuisine"] as? String
        else { return nil }
        self.id = id
        self.name = name
        self.cuisine = cuisine
        self.photoURLSmall = URL(string: dictionary["photo_url_small"] as? String ?? "")
        self.photoURLLarge = URL(string: dictionary["photo_url_large"] as? String ?? "")
        self.sourceURL = URL(string: dictionary["source_url"] as? String ?? "")
        self.youtubeURL = URL(string: dictionary["youtube_url"] as? String ?? "")
    }
}
