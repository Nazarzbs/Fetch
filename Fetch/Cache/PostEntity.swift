//
//  PostEntity.swift
//  Fetch
//
//  Created by Nazar on 29.01.2026.
//

import Foundation
import SwiftData

@Model
final class PostEntity {

    var id: Int
    var userId: Int
    var title: String
    var body: String

    init(id: Int, userId: Int, title: String, body: String) {
        self.id = id
        self.userId = userId
        self.title = title
        self.body = body
    }

    convenience init(post: Post) {
        self.init(id: post.id, userId: post.userId, title: post.title, body: post.body)
    }

    var asPost: Post {
        Post(id: id, userId: userId, title: title, body: body)
    }
}
