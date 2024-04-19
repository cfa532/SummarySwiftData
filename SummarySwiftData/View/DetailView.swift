//
//  DetailView.swift
//  SummaryAI
//
//  Created by 超方 on 2024/3/29.
//

import SwiftUI
import SwiftData

struct DetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @Query private var settings: [AppSettings]
    @State private var presentRawText = false
    @StateObject private var websocket = Websocket()
    @State private var isShowingDialog = false
    @State private var showShareSheet = false
    var record: AudioRecord
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                Label() {
                    Text(AudioRecord.recordDateFormatter.string(from: record.recordDate))
                        .font(.subheadline) // Makes the date text larger
                        .foregroundColor(.secondary) // Changes the color of the date text
                } icon: {
                    Image(systemName: "calendar")
                        .foregroundColor(.primary) // Changes the color of the calendar icon
                }
                Spacer()
                
                Button(action: {
                    presentRawText.toggle()
                }, label: {
                    Text("Transcript>>")
                        .font(.subheadline) // Makes the button text smaller
                        .foregroundColor(.secondary) // Changes the color of the button text
                })
                //                .padding(.horizontal) // Adds horizontal padding to the button
            }
            .padding(.horizontal) // Adds horizontal padding to the HStack
            
            ScrollView {
                if self.websocket.isStreaming {
                    ScrollViewReader { proxy in
                        let message = "Streaming....\n"+self.websocket.streamedText
                        Text(message)
                            .id(message)
                            .onChange(of: message, {
                                proxy.scrollTo(message, anchor: .bottom)
                            })
                    }
                } else {
                    Text( record.summary )
                        .padding()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Summary")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItemGroup(placement: .topBarLeading) {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "arrow.uturn.left")
                        .resizable()
                        .foregroundColor(.primary)
//                        .fontWeight(.bold)
                })
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: {
                    // sharing menu
                    showShareSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .resizable()
                        .foregroundColor(.primary)
                }
                .sheet(isPresented: $showShareSheet, content: {
                    let textToShare = AudioRecord.recordDateFormatter.string(from: record.recordDate)+": "+record.summary
                    ShareSheet(activityItems: [textToShare])
                })
            }
            ToolbarItemGroup(placement: .bottomBar) {
                Button(action: {
                    // regenerate AI summary
                    isShowingDialog = true
                }) {
                    Text("Redo summary")
                        .padding(5)
                }
//                .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: 0.3)
                .foregroundColor(.black)
                .background(Color(white: 0.8))
                .cornerRadius(5.0)
                .shadow(color:.gray, radius: 2, x: 2, y: 2)
                .confirmationDialog(
                    Text("Regenerate summary?"),
                    isPresented: $isShowingDialog
                ) {
                    Button("Just do it", role: .destructive) {
                        Task {
                            self.websocket.sendToAI(record.transcript, settings: self.settings[0]) { summary in
                                record.summary = summary
                                try? modelContext.save()
                            }
                        }
                    }
                }
            }
        })
        .padding() // Adds padding to the VStack
        .sheet(isPresented: $presentRawText, content: {
            NavigationStack {
                ScrollView {
                    Text(record.transcript)
                        .padding()
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            presentRawText.toggle()
                        }) {
                            Image(systemName: "xmark.circle")
                                .font(.system(size: 20))
                                .foregroundColor(Color.orange)
                        }
                    }
                }
            }
        })
    }
    
    struct ShareSheet: UIViewControllerRepresentable {
        let activityItems: [Any]
        func makeUIViewController(context: Context) -> UIActivityViewController {
            return UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        }

        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    }
}

#Preview {
    DetailView(record: (AudioRecord.sampleData[0]))
}
