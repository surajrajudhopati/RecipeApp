# Recipe App

This Recipe App is a SwiftUI-based application that fetches and displays recipes from a remote API endpoint. It demonstrates the use of modern iOS development practices, including Swift Concurrency (async/await), custom image caching, a custom and basic ad-blocking WebView which works for predefined domains but may require more robust rules for a production environment., and an offline-capable favorites system—all without any external dependencies.

---

## Summary

The app displays a list of recipes, each showing its name, photo, and cuisine type. Key features include:

- **SwiftUI Interface:**  
  A modern, clean UI built entirely in SwiftUI.

- **Asynchronous Data Fetching:**  
  Uses Swift Concurrency (async/await) for networking and image loading.

- **Efficient Image Caching:**  
  A custom image caching system with in‑memory (NSCache) and disk caching to minimize bandwidth consumption.

- **Error Handling:**  
  Gracefully handles malformed data by disregarding the entire recipes list and displays an empty state if no recipes are available.

- **Refresh Capability:**  
  Users can refresh the recipe list at any time via a toolbar button.

- **Alphabetical Navigation:**  
  A fixed, Contacts-like AlphabetSelector allows quick scrolling through recipes grouped by the first letter of their names.

- **Favorites System:**  
  Users can save recipes as favorites (persisted using UserDefaults) from both the list and detail views. A dedicated Favorites view displays saved recipes even when offline.

- **Recipe Details:**  
  A detail view with a segmented control allows users to view either the recipe’s source webpage or play its YouTube video using an ad-blocking WebView.

- **Interactive Image Popup:**  
  Tapping on a recipe’s image opens a zoomable, draggable popup that prevents the image from moving off-screen.


---

## Focus Areas

- **Performance & Efficiency:**  
  Prioritized efficient network usage by implementing custom image caching, reducing redundant network calls.

- **Modern Concurrency:**  
  Employed Swift Concurrency (async/await) throughout networking and image loading tasks to create a responsive user experience.

- **User Experience:**  
  Enhanced usability with features like quick alphabetical navigation, a favorites system for offline access, and an interactive image viewer.

- **SwiftUI Best Practices:**  
  Leveraged native SwiftUI components and design patterns for a clean, maintainable codebase without relying on third-party libraries.


## Trade-offs and Decisions

- **Data Persistence:**  
  Chose UserDefaults for persisting favorites for simplicity, even though a more robust solution (like Core Data) could be used in a production app.

- **Image Caching:**  
  Implemented custom caching using NSCache and disk storage to meet the requirement of not relying on URLSession’s HTTP caching.

- **Error Handling:**  
  The decision to discard the entire recipes list when encountering a malformed recipe was made to keep error handling simple and predictable.

- **Testing:**  
  Core logic (such as data fetching and caching) was the focus for testing. UI and integration tests were omitted due to time constraints but would be necessary in a production environment.

---


## Additional Information

- **iOS Version Support:**  
  The app is designed to support iOS 16.6 and up.
- **No External Dependencies:**  
  All functionality is implemented using native Apple frameworks.
- **Potential Enhancements:**  
  Future improvements could include more robust error handling, expanded caching mechanisms, and comprehensive UI testing.

---
