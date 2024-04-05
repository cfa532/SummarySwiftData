//
//  DetailView.swift
//  SummaryAI
//
//  Created by 超方 on 2024/3/29.
//

import SwiftUI

struct DetailView: View {
    var record: AudioRecord
    @State private var presentRawText = false
    
    var body: some View {
        VStack (alignment: .leading, spacing: 20) {
            HStack {
                Label() {
                    Text(AudioRecord.recordDateFormatter.string(from: record.recordDate))
                        .font(.headline) // Makes the date text larger
                        .foregroundColor(.primary) // Changes the color of the date text
                } icon: {
                    Image(systemName: "calendar")
                        .foregroundColor(.secondary) // Changes the color of the calendar icon
                }
                Spacer()
                
                Button(action: {
                    presentRawText.toggle()
                }, label: {
                    Text("Raw Text >>")
                        .font(.subheadline) // Makes the button text smaller
                        .foregroundColor(.blue) // Changes the color of the button text
                })
                //                .padding(.horizontal) // Adds horizontal padding to the button
            }
            .padding(.horizontal) // Adds horizontal padding to the HStack
            
//            Text("Summary")
//                .font(.headline)
//                .padding(.top)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.horizontal)
            
            ScrollView {
                Text(record.summary)
                    .font(.subheadline) // Increase the font size to make it more readable
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading) // Aligns the text to the top
                .padding()
            }
            .navigationTitle("Summary")

        }
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
}

#Preview {
    DetailView(record: (AudioRecord.sampleData[0]))
}
