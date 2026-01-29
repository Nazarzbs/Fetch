//
//  FetchApp.swift
//  Fetch
//
//  Created by Nazar on 29.01.2026.
//

import SwiftData
import SwiftUI

@main
struct FetchApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: PostEntity.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(modelContainer: modelContainer)
        }
    }
}
