//
//  ContentView.swift
//  SummarySwiftData
//
//  Created by 超方 on 2024/4/5.
//

import SwiftUI
import SwiftData

struct TranscriptView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AudioRecord.recordDate, order: .reverse) private var records: [AudioRecord]
    @Query private var settings: [AppSettings]
    
    @State private var isRecording = false
    @Binding var errorWrapper: ErrorWrapper?
    @StateObject private var websocket = Websocket()
    @StateObject private var recorderTimer = RecorderTimer()
    @StateObject private var speechRecognizer = SpeechRecognizer()

    var body: some View {
        NavigationStack {
            if isRecording {
                VStack {
                    Label("Recognizing....in "+String(describing: RecognizerLocals(rawValue: settings[0].speechLocale)!), systemImage: "mic")
                        .font(.headline)
                        .padding()
                    ScrollView {
                        Text(speechRecognizer.transcript)
                    }
                }
                .padding()
            } else if websocket.isStreaming {
                VStack {
                    Label("Streaming from AI", systemImage: "theatermask.and.paintbrush")
                        .padding()
                    ScrollView {
                        Text(websocket.streamedText)
//                            .frame(alignment: .topLeading)
                    }
                }
                .padding()
                Spacer()
            }
            else {
                List {
                    ForEach(records) { item in
                        NavigationLink {
                            DetailView(record: item)
                        } label: {
                            Text(item.summary)
                                .font(.subheadline)
                                .lineLimit(4)
                        }
                    }
                }
                .overlay(content: {
                    if records.isEmpty {
                        ContentUnavailableView(label: {
                            Label("No records", systemImage: "list.bullet.rectangle.portrait")
                        }, description: {
                            Text("Push the START button to record your own speech. A summary will be generated automatically after STOP button is pushed.")
                        })
                    }
                })
                .navigationTitle("Daily Records")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing, content: {
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                    })
                }
                .task {
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
            }
            
            RecorderButton(isRecording: $isRecording) {
                if isRecording {
                    print("start timer")
                    recorderTimer.delegate = self
                    recorderTimer.startTimer() {
                        
                        // body of isSilent()
                        print("audio level=", SpeechRecognizer.currentLevel)
                        if SpeechRecognizer.currentLevel < -40 {
                            return true
                        } else {
                            return false
                        }
                    }
                    Task { @MainActor in
                        await self.speechRecognizer.setup(locale: settings[0].speechLocale)
                        speechRecognizer.startTranscribing()
                    }
                } else {
                    speechRecognizer.stopTranscribing()
                    recorderTimer.stopTimer()
                }
            }
            .disabled(websocket.isStreaming)
            .frame(alignment: .bottom)
        }
    }
}

extension TranscriptView: TimerDelegate {
    
    @MainActor func timerStopped() {
        
        // body of action() closure
        isRecording = false
        guard speechRecognizer.transcript != "" else { print("No audio input"); return }
        
        let curDate: String = AudioRecord.recordDateFormatter.string(from: Date())
        Task {
            if let index = records.firstIndex(where: {curDate == AudioRecord.recordDateFormatter.string(from: $0.recordDate)}) {
                // check if today's record exists
                records[index].transcript +=  speechRecognizer.transcript+"。"
                websocket.sendToAI(speechRecognizer.transcript, settings: self.settings[0]) { summary in
                    records[index].summary = summary
                }
            } else {
                let curRecord = AudioRecord(transcript: speechRecognizer.transcript+"。", summary: curDate)
                // If anything goes wrong wit AI, still have the transcript.
                modelContext.insert(curRecord)
                websocket.sendToAI(speechRecognizer.transcript, settings: self.settings[0]) { summary in
                    curRecord.summary = summary
                }
            }
        }
    }
    
//    @MainActor private func sendToAI(_ rawText: String, action: @escaping (_ summary: String)->Void) {
//        // Convert the dictionary to Data
//        //        let msg = ["input":["query": "为下述文字添加标点符号，并适当分段。 "+rawText], "parameters":["llm":"openai","temperature":"0.0","client":"mobile"]] as [String : Any]
//        guard !settings.isEmpty else { return }
//        let msg = ["input":["prompt": settings[0].prompt, "rawtext": rawText], "parameters":["llm":"openai","temperature":"0.0","client":"mobile","model":"gpt-4"]] as [String : Any]
//        let jsonData = try! JSONSerialization.data(withJSONObject: msg)
//        Task {
//            // Convert the Data to String
//            if let jsonString = String(data: jsonData, encoding: .utf8) {
//                websocket.prepare(self.settings[0].wssURL)
//                websocket.send(jsonString) { error in
//                    errorWrapper = ErrorWrapper(error: error, guidance: "Cannot connect to Websocket")
//                }
//                websocket.receive(action: action)
//                websocket.resume()
//            }
//        }
//    }
}

#Preview {
    TranscriptView(errorWrapper: .constant(.emptyError))
        .modelContainer(for: AudioRecord.self, inMemory: false)
}
