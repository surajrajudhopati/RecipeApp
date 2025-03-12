import SwiftUI
import WebKit


func createWebViewWithAdBlocker() -> WKWebView {
    let configuration = WKWebViewConfiguration()
    let contentController = WKUserContentController()
    configuration.userContentController = contentController
    
    let blockerRules = """
    [
      {
        "trigger": {
          "url-filter": ".*",
          "if-domain": ["ads.example.com", "popads.example.com", "tracker.example.com"]
        },
        "action": {
          "type": "block"
        }
      }
    ]
    """
    
    // Compile the content rule list and add it to the userContentController.
    WKContentRuleListStore.default().compileContentRuleList(
        forIdentifier: "AdBlocker",
        encodedContentRuleList: blockerRules
    ) { ruleList, error in
        if let error = error {
            print("Error compiling content rule list: \(error)")
            return
        }
        if let ruleList = ruleList {
            contentController.add(ruleList)
        }
    }
    
    return WKWebView(frame: .zero, configuration: configuration)
}


struct AdBlockingWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        return createWebViewWithAdBlocker()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

struct RecipeDetailView: View {
    let recipe: Recipe
    @State private var selectedSegment: DetailSegment = .source
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    enum DetailSegment: String, CaseIterable, Identifiable {
        case source = "Source"
        case video = "Video"
        var id: String { self.rawValue }
    }
    
    var availableSegments: [DetailSegment] {
        var segments: [DetailSegment] = []
        if recipe.sourceURL != nil { segments.append(.source) }
        if recipe.youtubeURL != nil { segments.append(.video) }
        return segments
    }
    
    var body: some View {
        VStack {
            if availableSegments.count > 1 {
                Picker("Detail", selection: $selectedSegment) {
                    ForEach(availableSegments) { segment in
                        Text(segment.rawValue).tag(segment)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
            }
            
            if selectedSegment == .source, let sourceURL = recipe.sourceURL {
                AdBlockingWebView(url: sourceURL)
                    .edgesIgnoringSafeArea(.bottom)
            } else if selectedSegment == .video, let youtubeURL = recipe.youtubeURL {
                let embedURL = youtubeURL.youtubeEmbedURL()
                AdBlockingWebView(url: embedURL)
                    .edgesIgnoringSafeArea(.bottom)
            } else {
                Text("No content available.")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle(recipe.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let first = availableSegments.first {
                selectedSegment = first
            }
        }
        .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            favoritesManager.toggleFavorite(recipe: recipe)
                        }) {
                            Image(systemName: favoritesManager.isFavorite(recipe: recipe) ? "heart.fill" : "heart")
                                .foregroundColor(favoritesManager.isFavorite(recipe: recipe) ? .red : .gray)
                        }
                    }
                }
    }
}

extension URL {
    func youtubeEmbedURL() -> URL {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let host = self.host, host.contains("youtube.com"),
              let queryItems = components.queryItems,
              let videoId = queryItems.first(where: { $0.name == "v" })?.value
        else {
            return self
        }
        let embedString = "https://www.youtube.com/embed/\(videoId)"
        return URL(string: embedString) ?? self
    }
}
