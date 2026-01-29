//
//  PostListViewModel.swift
//  Fetch
//
//  Created by Nazar on 29.01.2026.
//

import Foundation
import Observation

@Observable
@MainActor
final class PostListViewModel {

    private let networkService: PostNetworkService

    private(set) var posts: [Post] = []
    private(set) var isLoading = false
    private(set) var isLoadingMore = false
    private(set) var errorMessage: String?

    private var currentPage = 0
    private(set) var hasMoreData = true
    private let pageSize = 10
    private let loadMoreThreshold = 5

    var searchText = ""

    var filteredPosts: [Post] {
        if searchText.isEmpty {
            return posts
        }
        return posts.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }

    init(networkService: PostNetworkService = PostNetworkService()) {
        self.networkService = networkService
    }

    func fetchPosts() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let firstPage = try await networkService.fetchPosts(page: 1, limit: pageSize)
            posts = firstPage
            currentPage = 1
            hasMoreData = firstPage.count >= pageSize
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadMoreIfNeeded(currentItem: Post) {
        guard hasMoreData, !isLoadingMore, !isLoading else { return }
        guard let index = posts.firstIndex(where: { $0.id == currentItem.id }) else { return }
        if index >= posts.count - loadMoreThreshold {
            Task { await loadNextPage() }
        }
    }

    private func loadNextPage() async {
        guard hasMoreData, !isLoadingMore, !isLoading else { return }

        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            let nextPage = currentPage + 1
            let newItems = try await networkService.fetchPosts(page: nextPage, limit: pageSize)
            if newItems.isEmpty {
                hasMoreData = false
                return
            }
            posts.append(contentsOf: newItems)
            currentPage = nextPage
            hasMoreData = newItems.count >= pageSize
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

