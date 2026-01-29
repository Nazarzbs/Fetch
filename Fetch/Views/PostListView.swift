//
//  PostListView.swift
//  Fetch
//
//  Created by Nazar on 29.01.2026.
//

import SwiftUI

struct PostListView: View {
    @Bindable var viewModel: PostListViewModel

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView("Fetching posts...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            case .error(let message):
                ContentUnavailableView {
                    Label("Connection Error", systemImage: "wifi.exclamationmark")
                } description: {
                    Text(message)
                } actions: {
                    Button("Try Again") {
                        Task { await viewModel.fetchPosts() }
                    }
                }
                
            case .success(let displayedPosts):
                postsList(displayedPosts)
            }
        }
        .navigationDestination(for: Post.self) { post in
            PostDetailView(post: post)
        }
        .searchable(text: $viewModel.searchText, prompt: "Search title")
        .onChange(of: viewModel.searchText) { _, _ in
            viewModel.updateUIState()
        }
    }
    
    @ViewBuilder
    private func postsList(_ posts: [Post]) -> some View {
        List {
            ForEach(posts) { post in
                NavigationLink(value: post) {
                    PostRow(post: post)
                }
                .onAppear {
                    viewModel.loadMoreIfNeeded(currentItem: post)
                }
            }

            if viewModel.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .refreshable { await viewModel.fetchPosts() }
    }
}
