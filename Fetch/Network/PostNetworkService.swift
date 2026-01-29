//
//  PostNetworkService.swift
//  Fetch
//
//  Created by Nazar on 29.01.2026.
//

import Foundation

enum PostNetworkError: LocalizedError {
    case invalidURL
    case requestFailed(underlying: Error)
    case invalidResponse
    case decodingFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}

final class PostNetworkService: Sendable {

    private let session: URLSession
    private let baseURLString = "https://jsonplaceholder.typicode.com"

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchPosts() async throws -> [Post] {
        try await fetchPosts(page: 1, limit: 20)
    }

    func fetchPosts(page: Int, limit: Int) async throws -> [Post] {
        let url = try makePostsURL(page: page, limit: limit)
        let data = try await performRequest(url: url)
        return try decodePosts(data: data)
    }

    private func makePostsURL(page: Int = 1, limit: Int = 20) throws -> URL {
        var components = URLComponents(string: "\(baseURLString)/posts")
        components?.queryItems = [
            URLQueryItem(name: "_page", value: "\(page)"),
            URLQueryItem(name: "_limit", value: "\(limit)")
        ]
        guard let url = components?.url else {
            throw PostNetworkError.invalidURL
        }
        return url
    }

    private func performRequest(url: URL) async throws -> Data {
        do {
            let (data, response) = try await session.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw PostNetworkError.invalidResponse
            }
            return data
        } catch {
            throw PostNetworkError.requestFailed(underlying: error)
        }
    }

    private func decodePosts(data: Data) throws -> [Post] {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([Post].self, from: data)
        } catch {
            throw PostNetworkError.decodingFailed(underlying: error)
        }
    }
}
