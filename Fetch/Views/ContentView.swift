//
//  ContentView.swift
//  Fetch
//
//  Created by Nazar on 29.01.2026.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    let modelContainer: ModelContainer

    @State private var viewModel: PostListViewModel?

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    var body: some View {
        NavigationStack {
            if let viewModel {
                PostListView(viewModel: viewModel)
                    .navigationTitle("Posts")
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task {
            guard viewModel == nil else { return }
            let cacheService = PostCacheService(modelContainer: modelContainer)
            let vm = PostListViewModel(networkService: PostNetworkService(), cacheService: cacheService)
            viewModel = vm
            await vm.fetchPosts()
        }
    }
}
