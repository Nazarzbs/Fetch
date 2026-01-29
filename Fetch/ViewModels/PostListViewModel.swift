//
//  PostListViewModel.swift
//  Fetch
//
//  Created by Nazar on 29.01.2026.
//

import Foundation
import Observation

enum DataState {
    case loading
    case success([Post])
    case error(String)
}

@Observable
@MainActor
final class PostListViewModel {
    // Single Source of Truth for the UI
    private(set) var state: DataState = .loading
    
    // Pagination helpers (kept private as the View doesn't need to see them)
    private(set) var isLoadingMore = false
    private var posts: [Post] = []
    private var currentPage = 1
    private var hasMoreData = true
    private let pageSize = 10
    private let loadMoreThreshold = 3 // Adjusted for smoother scrolling

    private let networkService: PostNetworkService
    var searchText = ""

    var filteredPosts: [Post] {
        if searchText.isEmpty { return posts }
        return posts.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    init(networkService: PostNetworkService = PostNetworkService()) {
        self.networkService = networkService
    }

    func fetchPosts() async {
        // Prevent showing loading screen if we already have data (e.g., on pull-to-refresh)
        if posts.isEmpty { state = .loading }
        
        do {
            let firstPage = try await networkService.fetchPosts(page: 1, limit: pageSize)
            self.posts = firstPage
            self.currentPage = 1
            self.hasMoreData = firstPage.count >= pageSize
            updateUIState()
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func loadMoreIfNeeded(currentItem: Post) {
        // Don't paginate if searching, already loading, or no more data
        guard searchText.isEmpty, hasMoreData, !isLoadingMore else { return }
        if case .loading = state { return }
        
        guard let index = posts.firstIndex(where: { $0.id == currentItem.id }) else { return }
        
        if index >= posts.count - loadMoreThreshold {
            Task { await loadNextPage() }
        }
    }

    private func loadNextPage() async {
        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            let nextPage = currentPage + 1
            let newItems = try await networkService.fetchPosts(page: nextPage, limit: pageSize)
            
            if newItems.isEmpty {
                hasMoreData = false
            } else {
                posts.append(contentsOf: newItems)
                currentPage = nextPage
                hasMoreData = newItems.count >= pageSize
            }
            updateUIState()
        } catch {
            // We don't switch the whole view to .error here because
            // we don't want to hide the posts we already loaded.
            print("Pagination error: \(error.localizedDescription)")
        }
    }

    // This method handles the logic for Search vs List vs Empty
    func updateUIState() {
        state = .success(filteredPosts)
    }
}

