//
//  Post.swift
//  Fetch
//
//  Created by Nazar on 29.01.2026.
//

import Foundation

struct Post: Identifiable, Codable, Equatable, Hashable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}
