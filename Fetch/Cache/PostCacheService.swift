//
//  PostCacheService.swift
//  Fetch
//
//  Created by Nazar on 29.01.2026.
//

import Foundation
import SwiftData

final class PostCacheService {

    private let modelContainer: ModelContainer
    private var context: ModelContext { modelContainer.mainContext }

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    func savePosts(_ posts: [Post]) throws {
        let descriptor = FetchDescriptor<PostEntity>(sortBy: [SortDescriptor(\.id)])
        let existing = try context.fetch(descriptor)
        var byId = Dictionary(uniqueKeysWithValues: existing.map { ($0.id, $0) })

        for post in posts {
            if let entity = byId[post.id] {
                entity.userId = post.userId
                entity.title = post.title
                entity.body = post.body
            } else {
                let entity = PostEntity(post: post)
                context.insert(entity)
                byId[post.id] = entity
            }
        }
        try context.save()
    }

    func loadPosts() -> [Post] {
        let descriptor = FetchDescriptor<PostEntity>(sortBy: [SortDescriptor(\.id)])
        do {
            let entities = try context.fetch(descriptor)
            return entities.map(\.asPost)
        } catch {
            return []
        }
    }
}
