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
//    @Environment(\.dismiss) private var dismiss
    
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
            
            Text("Summary")
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .padding(.top)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            Text(record.summary)
                .font(.title2) // Increase the font size to make it more readable
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading) // Aligns the text to the top
                .padding()
            Spacer()
        }
        .padding() // Adds padding to the VStack
        .sheet(isPresented: $presentRawText, content: {
            @Environment(\.dismiss) var dismiss
            NavigationStack {
                VStack {
                    Text(record.transcript)
                        .padding()
                }
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
//                            dismiss()
                            presentRawText.toggle()
                        }) {
                            Image(systemName: "xmark.circle")
                                .font(.system(size: 20))
                                .foregroundColor(Color.red)
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
