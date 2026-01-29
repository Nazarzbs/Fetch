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

    private(set) var state: DataState = .loading
    
    private(set) var isLoadingMore = false
    private var posts: [Post] = []
    private var currentPage = 1
    private var hasMoreData = true
    private let pageSize = 10
    private let loadMoreThreshold = 3

    private let networkService: PostNetworkService
    private let cacheService: PostCacheService?

    private(set) var isShowingCachedData = false

    var searchText = ""

    var filteredPosts: [Post] {
        if searchText.isEmpty { return posts }
        return posts.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    init(networkService: PostNetworkService = PostNetworkService(), cacheService: PostCacheService? = nil) {
        self.networkService = networkService
        self.cacheService = cacheService
    }

    func fetchPosts() async {
        if posts.isEmpty { state = .loading }
        isShowingCachedData = false

        do {
            let firstPage = try await networkService.fetchPosts(page: 1, limit: pageSize)
            self.posts = firstPage
            self.currentPage = 1
            self.hasMoreData = firstPage.count >= pageSize
            try? cacheService?.savePosts(firstPage)
            updateUIState()
        } catch {
            let cached = cacheService?.loadPosts() ?? []
            if !cached.isEmpty {
                self.posts = cached
                self.currentPage = 1
                self.hasMoreData = false
                isShowingCachedData = true
                updateUIState()
            } else {
                state = .error(error.localizedDescription)
            }
        }
    }

    func loadMoreIfNeeded(currentItem: Post) {
      
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
                try? cacheService?.savePosts(newItems)
            }
            updateUIState()
        } catch {
          
            print("Pagination error: \(error.localizedDescription)")
        }
    }

    func updateUIState() {
        state = .success(filteredPosts)
    }
}

