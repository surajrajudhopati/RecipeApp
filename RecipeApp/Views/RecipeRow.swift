import SwiftUI

struct RecipeRow: View {
    let recipe: Recipe
    @State private var showLargeImage: Bool = false
    @EnvironmentObject var favoritesManager: FavoritesManager

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let smallURL = recipe.photoURLSmall {
                CachedImage(url: smallURL)
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
                    .shadow(radius: 2)
                    .onTapGesture {
                        if recipe.photoURLLarge != nil {
                            showLargeImage.toggle()
                        }
                    }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(recipe.name)
                        .font(.headline)
//                        .lineLimit(1)
                    Spacer()
                    Button(action: {
                        favoritesManager.toggleFavorite(recipe: recipe)
                    }) {
                        Image(systemName: favoritesManager.isFavorite(recipe: recipe) ? "heart.fill" : "heart")
                            .foregroundColor(favoritesManager.isFavorite(recipe: recipe) ? .red : .gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Text(recipe.cuisine)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack(spacing: 16) {
                    if let sourceURL = recipe.sourceURL {
                        Link(destination: sourceURL) {
                            Label("Source", systemImage: "link.circle")
                                .labelStyle(IconOnlyLabelStyle())
                                .frame(width: 36, height: 36)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                    if let youtubeURL = recipe.youtubeURL {
                        Link(destination: youtubeURL) {
                            Label("YouTube", systemImage: "video.circle")
                                .labelStyle(IconOnlyLabelStyle())
                                .frame(width: 36, height: 36)
                                .background(Color.red.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                }
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .sheet(isPresented: $showLargeImage) {
            if let largeURL = recipe.photoURLLarge {
                PopupImageView(imageURL: largeURL)
            }
        }
    }
}



struct PopupCachedImage: View {
    let imageURL: URL
    @State private var image: UIImage?
    @State private var isLoading = false

    var body: some View {
        ZStack {
            if let uiImage = image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else if isLoading {
                ProgressView()
            } else {
                Color.gray.opacity(0.1)
            }
        }
        .onAppear {
            loadImage()
        }
    }

    private func loadImage() {
        guard image == nil, !isLoading else { return }
        isLoading = true
        Task {
            if let fetchedImage = await ImageCache.shared.getImage(for: imageURL) {
                image = fetchedImage
            }
            isLoading = false
        }
    }
}




extension CGSize {
    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
}

struct PopupImageView: View {
    let imageURL: URL
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @Environment(\.dismiss) private var dismiss

    private func clampedOffset(geometry: GeometryProxy, proposedOffset: CGSize, scale: CGFloat) -> CGSize {

        let maxOffsetX = max(0, (geometry.size.width * scale - geometry.size.width) / 2)
        let maxOffsetY = max(0, (geometry.size.height * scale - geometry.size.height) / 2)
        let clampedX = min(max(proposedOffset.width, -maxOffsetX), maxOffsetX)
        let clampedY = min(max(proposedOffset.height, -maxOffsetY), maxOffsetY)
        return CGSize(width: clampedX, height: clampedY)
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            GeometryReader { geometry in
                AsyncImage(url: imageURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
                            .scaleEffect(scale)
                            .offset(offset)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        let newOffset = offset + value.translation
                                        offset = clampedOffset(geometry: geometry, proposedOffset: newOffset, scale: scale)
                                    }
                                    .onEnded { _ in
                                        withAnimation(.spring()) {
                                            offset = clampedOffset(geometry: geometry, proposedOffset: offset, scale: scale)
                                        }
                                    }
                            )
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        scale = value
                                        offset = clampedOffset(geometry: geometry, proposedOffset: offset, scale: scale)
                                    }
                                    .onEnded { _ in
                                        withAnimation(.spring()) {
                                            scale = max(1.0, scale)
                                            offset = clampedOffset(geometry: geometry, proposedOffset: offset, scale: scale)
                                        }
                                    }
                            )
                            .gesture(
                                TapGesture(count: 2)
                                    .onEnded {
                                        withAnimation(.spring()) {
                                            scale = 1.0
                                            offset = .zero
                                        }
                                    }
                            )
                    } else if phase.error != nil {
                        Text("Failed to load image")
                            .foregroundColor(.white)
                    } else {
                        ProgressView()
                    }
                }
            }
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                            .shadow(radius: 4)
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}
