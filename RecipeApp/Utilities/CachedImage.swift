import SwiftUI

struct CachedImage: View {
    let url: URL
    @State private var image: UIImage?
    @State private var isLoading = false

    var body: some View {
        ZStack {
            if let uiImage = image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else if isLoading {
                ProgressView()
            } else {
                // Placeholder while no image is available
                Color.gray.opacity(0.1)
            }
        }
        .onAppear {
            loadImage()
        }
        .clipped()
    }

    private func loadImage() {
        guard image == nil, !isLoading else { return }
        isLoading = true
        Task {
            if let fetchedImage = await ImageCache.shared.getImage(for: url) {
                image = fetchedImage
            }
            isLoading = false
        }
    }
}
