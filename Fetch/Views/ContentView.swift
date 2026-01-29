//
//  ContentView.swift
//  Fetch
//
//  Created by Nazar on 29.01.2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .task {
            let service = PostNetworkService()
            do {
                let posts = try await service.fetchPosts()
                print(posts)
            } catch let error as PostNetworkError {
               
            } catch {
               
            }
        }
    }
}

#Preview {
    ContentView()
}
