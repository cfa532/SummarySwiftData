//
//  SettingsView.swift
//  SummarySwiftData
//
//  Created by 超方 on 2024/4/17.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var settings: [AppSettings]
    @State private var setting: AppSettings  = AppSettings.defaultSettings {
        didSet {
            if let t = Int(setting.audioSilentDB) {
                if t>0 { setting.audioSilentDB = "0" }
                else if t < -80 {
                    setting.audioSilentDB = "-80"
                }
            } else {
                setting.audioSilentDB = "-40"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextEditor(text: $setting.prompt)
                    .frame(height: 60, alignment: .topLeading)
                TextField("Locale", text: $setting.speechLocale)
                TextField("最低音量", text: $setting.audioSilentDB)
                TextField("URL", text: $setting.wssURL)
            }
            .onAppear(perform: {
                guard !settings.isEmpty else { return }
                setting = settings[0]
            })
            .onDisappear(perform: {
                print(settings[0].prompt)
            })
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button("Reset") {
                    settings[0].prompt = AppSettings.defaultSettings.prompt
                    settings[0].speechLocale = AppSettings.defaultSettings.speechLocale
                    settings[0].audioSilentDB = AppSettings.defaultSettings.audioSilentDB
                    settings[0].wssURL = AppSettings.defaultSettings.wssURL
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: AppSettings.self, inMemory: false)
}
