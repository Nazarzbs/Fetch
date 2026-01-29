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

final class PostNetworkService {

    private let session: URLSession
    private let baseURLString = "https://jsonplaceholder.typicode.com"

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchPosts() async throws -> [Post] {
        let url = try makePostsURL()
        let data = try await performRequest(url: url)
        return try decodePosts(data: data)
    }

    private func makePostsURL() throws -> URL {
        guard let url = URL(string: "\(baseURLString)/posts") else {
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
            
            print(data)
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
