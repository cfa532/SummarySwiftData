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
    @State private var isRecording = false
    @Binding var errorWrapper: ErrorWrapper?

    @StateObject private var websocket = Websocket("wss://leither.uk/ws")
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @StateObject private var recorderTimer = RecorderTimer()
    
    var body: some View {
        NavigationStack {
            if isRecording {
                VStack {
                    Label("Recording...", systemImage: "mic")
                        .padding()
                    Text(speechRecognizer.transcript)
                }
                .padding()
                Spacer()
            } else if websocket.isStreaming {
                VStack {
                    Label("Streaming from AI", systemImage: "theatermask.and.paintbrush")
                        .padding()
                    Text(websocket.streamedText)
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
                .navigationTitle("List")
                .navigationBarTitleDisplayMode(.inline)
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
                    speechRecognizer.startTranscribing()
                } else {
                    speechRecognizer.stopTranscribing()
                    recorderTimer.stopTimer()
                }
            }
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
                sendToAI(speechRecognizer.transcript) { summary in
                    records[index].summary = curDate+": "+summary
                }
            } else {
                let curRecord = AudioRecord(transcript: speechRecognizer.transcript+"。", summary: curDate)
                // If anything goes wrong wit AI, still have the transcript.
                modelContext.insert(curRecord)
                sendToAI(speechRecognizer.transcript) { summary in
                    curRecord.summary = curDate+": "+summary
                }
            }
        }
    }
    
    @MainActor private func sendToAI(_ rawText: String, action: @escaping (_ summary: String)->Void) {
        // Convert the dictionary to Data
//        let msg = ["input":["query": "为下述文字添加标点符号，并适当分段。 "+rawText], "parameters":["llm":"openai","temperature":"0.0","client":"mobile"]] as [String : Any]
        let msg = ["input":["prompt": "提取下述文字的摘要，并添加标点符号，适当分段，修改错别字。",["rawtext"]:rawText], "parameters":["llm":"openai","temperature":"0.0","client":"mobile"]] as [String : Any]
        let jsonData = try! JSONSerialization.data(withJSONObject: msg)
        Task {
            // Convert the Data to String
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
                websocket.send(jsonString) { error in
                    errorWrapper = ErrorWrapper(error: error, guidance: "Cannot connect to Websocket")
                }
                websocket.receive(action: action)
                websocket.resume()
            }
        }
    }
}

@MainActor
enum Globals {
//    static let recorderTimer = RecorderTimer()
//    static let websocket = Websocket("ws://52.221.183.236:8505")
}

#Preview {
    TranscriptView(errorWrapper: .constant(.emptyError))
        .modelContainer(for: AudioRecord.self, inMemory: true)
}
