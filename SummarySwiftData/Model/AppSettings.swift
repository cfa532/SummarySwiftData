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
                                             speechLocale: Locale.current.identifier
    )
}

@propertyWrapper
struct AudioLevelDB {
    var wrappedValue: AppSettings {
        didSet {
            if let t = Int(wrappedValue.audioSilentDB) {
                if t>0 { wrappedValue.audioSilentDB = "0" }
                else if t < -80 {
                    wrappedValue.audioSilentDB = "-80"
                }
            } else {
                wrappedValue.audioSilentDB = "-40"
            }
        }
    }
    init(_ wrappedValue: AppSettings) {
        self.wrappedValue = wrappedValue
    }
}
