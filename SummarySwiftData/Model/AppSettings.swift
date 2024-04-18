//
//  Settings.swift
//  SummarySwiftData
//
//  Created by 超方 on 2024/4/16.
//

import Foundation
import SwiftData

@Model
final class AppSettings {
    var prompt: String
    var wssURL: String
    var audioSilentDB: String
    var speechLocale: String
    
    init(prompt: String, wssURL: String, audioSilentDB: String, speechLocale: String ) {
        self.prompt = prompt
        self.wssURL = wssURL
        self.audioSilentDB = audioSilentDB
        self.speechLocale = speechLocale
    }
}

extension AppSettings {
    static var defaultSettings = AppSettings(prompt: "提取下述文字的摘要，并添加标点符号，适当分段，修改错别字。",
                                             wssURL: "wss://leither.uk/ws",
                                             audioSilentDB: "-40",
                                             speechLocale: RecognizerLocals.Chinese.rawValue
//                                             speechLocale: Locale.current.identifier
    )
}

enum RecognizerLocals: String, CaseIterable, Identifiable {
    case English = "en_US"
    case Japanese = "ja_JP"
    case Chinese = "zh_CN"
    
    var id: Self { self }
}

// system constants
final class AppConstants {
    static let MaxSilentSeconds = 1800      // max waiting time if no audio input, 30min
    static let MaxRecordSeconds = 28800     // max working hours, 8hrs
}
