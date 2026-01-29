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
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.blue)
            
            case .error(let message):
                ContentUnavailableView {
                    Label("Connection Error", systemImage: "wifi.router.fill")
                } description: {
                    Text(message)
                } actions: {
                    Button("Try Again", action: { Task { await viewModel.fetchPosts() } })
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                }
                
            case .success(let displayedPosts):
                if displayedPosts.isEmpty {
                    ContentUnavailableView.search(text: viewModel.searchText)
                } else {
                    postsList(displayedPosts)
                }
            }
        }
        .navigationTitle("Feeds")
        .navigationDestination(for: Post.self) { post in
            PostDetailView(post: post)
        }
        .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search posts")
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
                .listRowBackground(Color(.secondarySystemGroupedBackground))
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
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.insetGrouped) // Provides a much cleaner "card-like" look
        .refreshable { await viewModel.fetchPosts() }
    }
}
