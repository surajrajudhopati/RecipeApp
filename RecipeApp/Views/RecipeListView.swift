import SwiftUI

struct RecipeListView: View {
    @StateObject private var viewModel = RecipeListViewModel()
    @State private var selectedLetter: String? = nil
    @State private var scrollToTop: Bool = false
    @State private var scrollProxy: ScrollViewProxy? = nil

    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                List {
                    ForEach(viewModel.sortedSectionTitles, id: \.self) { letter in
                        if let recipes = viewModel.groupedRecipes[letter] {
                            Section(header: Text(letter)) {
                                ForEach(recipes) { recipe in
                                    NavigationLink(destination: RecipeDetailView(recipe: recipe)
                                                    .environmentObject(FavoritesManager.shared)) {
                                        RecipeRow(recipe: recipe)
                                            .listRowInsets(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10))
                                    }
                                }
                            }
                            .listRowInsets(EdgeInsets())
                            .id(letter)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .searchable(text: $viewModel.searchText, prompt: "Search by name or cuisine")
                .onAppear {
                    scrollProxy = proxy
                }
                .onChange(of: scrollToTop) { newValue in
                    if newValue, let firstSection = viewModel.sortedSectionTitles.first {
                        withAnimation {
                            proxy.scrollTo(firstSection, anchor: .top)
                        }
                        scrollToTop = false
                    }
                }
                .navigationTitle("Recipes")
//                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            Task {
                                await viewModel.fetchRecipes()
                                scrollToTop = true
                            }
                        }) {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: FavoritesView()
                                            .environmentObject(FavoritesManager.shared)) {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
                .task {
                    await viewModel.fetchRecipes()
                }
            }
        }
        .safeAreaInset(edge: .trailing, spacing: 0) {
            AlphabetSelector(
                letters: viewModel.sortedSectionTitles,
                selectedLetter: $selectedLetter,
                onLetterSelected: { letter in
                    if let proxy = scrollProxy {
                        withAnimation {
                            proxy.scrollTo(letter, anchor: .center)
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        selectedLetter = nil
                    }
                }
            )
            .frame(width: 30, height: 250)
            .padding(.trailing, 10)
        }
    }
}





struct AlphabetSelector: View {
    let letters: [String]
    @Binding var selectedLetter: String?
    var onLetterSelected: (String) -> Void

    var body: some View {
        VStack(spacing: 2) {
            ForEach(letters, id: \.self) { letter in
                Text(letter)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(letter == selectedLetter ? .white : .blue)
                    .frame(maxWidth: .infinity)
                    .padding(2)
                    .background(letter == selectedLetter ? Color.blue : Color.clear)
                    .clipShape(Circle())
            }
        }
        .frame(width: 30, height: 250)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    // Use the fixed height (250) to calculate letter height.
                    let letterHeight = 250.0 / Double(letters.count)
                    let y = value.location.y
                    let index = min(max(Int(y / letterHeight), 0), letters.count - 1)
                    let letter = letters[index]
                    if selectedLetter != letter {
                        selectedLetter = letter
                        onLetterSelected(letter)
                    }
                }
                .onEnded { _ in
                    selectedLetter = nil
                }
        )
    }
}
