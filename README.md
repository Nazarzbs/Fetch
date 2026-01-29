# Fetch

<img width="3292" height="2160" alt="Group 17" src="https://github.com/user-attachments/assets/09bff868-d382-47b1-b173-64d2ab6d4266" />

## Core Implementation

**Data Fetching & Networking**
- Source: [https://jsonplaceholder.typicode.com/posts](https://jsonplaceholder.typicode.com/posts)
- Layer: Dedicated PostNetworkService using URLSession and async/await.
- Error Handling: Implementation of a custom Error enum to handle invalid URLs, network failures, and decoding issues.

**User Interface**
- List View: A scrollable List displaying post titles and 2-line body previews.
- Search: Real-time, local filtering of the current dataset via `.searchable`.
- Detail Screen: A focused view displaying the full title and body, utilizing NavigationStack for hierarchical navigation.

**Technology Stack**
- UI: SwiftUI
- Logic: Observation framework (@Observable)
- Minimum Target: iOS 17.0+

## Advanced Implementation

**Offline Caching**
- Storage: SwiftData for structured persistence.
- Logic: The app first attempts a network fetch; if it fails (offline), it automatically populates the UI from the local database.

**Infinite Scrolling**
- Pagination: Fetching data in chunks (e.g., 10 posts per request) using _page and _limit parameters.
- UX: A ProgressView footer appears during loading, triggered when the user scrolls near the end of the current list.

| Component | Responsibility |
|-----------|----------------|
| **Model/Post.swift** | Defines `Post` (id, userId, title, body). |
| **Cache/PostEntity.swift** | SwiftData `@Model` for persistence; maps to `Post`. |
| **Network/PostNetworkService.swift** | Handles HTTP requests to JSONPlaceholder and JSON decoding. |
| **Cache/PostCacheService.swift** | Saves and loads posts via SwiftData (`PostEntity`). |
| **ViewModels/PostListViewModel.swift** | Coordinates fetch, search, pagination, and cache fallback. |
| **Views/ContentView.swift** | Root view: NavigationStack, wires VM + cache, triggers initial fetch. |
| **Views/PostListView.swift** | List, search bar, loading/error/empty states, infinite-scroll footer. |
| **Views/PostRow.swift** | List row: title and 2-line body preview. |
| **Views/PostDetailView.swift** | Detail screen: full title and body. |


