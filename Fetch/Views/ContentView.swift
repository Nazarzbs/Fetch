//
//  ContentView.swift
//  Fetch
//
//  Created by Nazar on 29.01.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = PostListViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading posts…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let message = viewModel.errorMessage {
                    ContentUnavailableView {
                        Label("Error", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(message)
                    }
                } else {
                    List {
                        ForEach(viewModel.posts) { post in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(post.title)
                                    .font(.headline)
                                Text(post.body)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                            .padding(.vertical, 4)
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
                            .padding(.vertical, 16)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Posts")
            .task {
                await viewModel.fetchPosts()
            }
        }
    }
}

#Preview {
    ContentView()
}
