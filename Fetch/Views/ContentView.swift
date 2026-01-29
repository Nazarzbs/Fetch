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
            PostListView(viewModel: viewModel)
                .navigationTitle("Posts")
        }
        .task {
            await viewModel.fetchPosts()
        }
    }
}

#Preview {
    ContentView()
}
