//
//  PostDetailView.swift
//  Fetch
//
//  Created by Nazar on 29.01.2026.
//

import SwiftUI

struct PostDetailView: View {
    let post: Post

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                
                    Text(post.title)
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .lineSpacing(4)
                }
                .padding(.horizontal)

                Divider()
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 20) {
                   
                    Text(post.body)
                        .font(.system(.body, design: .serif))
                        .lineSpacing(8)
                        .foregroundStyle(.secondary)
                    
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
}
