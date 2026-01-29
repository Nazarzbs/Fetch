//
//  PostRow.swift
//  Fetch
//
//  Created by Nazar on 29.01.2026.
//

import SwiftUI

struct PostRow: View {
        let post: Post
        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(post.title).font(.headline)
                Text(post.body).font(.subheadline).foregroundStyle(.secondary).lineLimit(2)
            }
            .padding(.vertical, 4)
        }
    }
