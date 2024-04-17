//
//  SummarySwiftDataApp.swift
//  SummarySwiftData
//
//  Created by 超方 on 2024/4/5.
//

import SwiftUI
import SwiftData

@main
struct SummarySwiftDataApp: App {
    @State private var errorWrapper: ErrorWrapper?
//    @AppStorage("hasRunBefore") var hasRunBefore = false
//    @Environment(\.modelContext) private var modelContext
//    @Query private var settings: [AppSettings]
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            AudioRecord.self, AppSettings.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            TranscriptView(errorWrapper: $errorWrapper)
                .onAppear(perform: {
                })
            //                .task {
            //                    // do something
            //                }
                .sheet(item: $errorWrapper) {
                    // store.records = AudioRecord.sampleData
                } content: { wrapper in
                    ErrorView(errorWrapper: wrapper)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
