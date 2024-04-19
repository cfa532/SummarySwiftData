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
                .task {
//                    initContext(modelContext: modelContext, settings: settings)
                }
                .sheet(item: $errorWrapper) {
                    // store.records = AudioRecord.sampleData
                } content: { wrapper in
                    ErrorView(errorWrapper: wrapper)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}

func initContext(modelContext: ModelContext, settings: [AppSettings]) {
    let lc = NSLocale.current.language.languageCode?.identifier
    print(lc!)
    if settings.isEmpty {
        // first run of the App, settings not stored by SwiftData yet.
        
        let setting = AppSettings.defaultSettings
        switch lc {
        case "en":
            setting.speechLocale = RecognizerLocals.English.rawValue
        case "jp":
            setting.speechLocale = RecognizerLocals.Japanese.rawValue
        default:
            setting.speechLocale = RecognizerLocals.Chinese.rawValue
        }
        modelContext.insert(setting)
        try? modelContext.save()
    }
}
