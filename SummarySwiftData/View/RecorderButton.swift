//
//  RoundButton.swift
//  SummaryAI
//
//  Created by 超方 on 2024/3/24.
//

import SwiftUI

struct RecorderButton: View {
    @Binding var isRecording: Bool
    let buttonAction: ()->Void
    
    var body: some View {
        HStack {
            Button(action: {
                isRecording.toggle()
                buttonAction()
            }, label: {
                Text(self.isRecording ? "Stop":"Start")
                    .padding(24)
                    .font(.title)
                    .background(Color.white)
                    .foregroundColor(.red)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            })
            if isRecording {
                Image(systemName: "mic")
                let now = Date.now
                let start = Calendar.current.date(byAdding: .second, value: Int(0), to: now)!
                let end = Calendar.current.date(byAdding: .second, value: Int(3600*8), to: start)!
                 
                Text(timerInterval: start...end, countsDown: false)
            }
        }
    }
}

#Preview {
    //    RoundButton(image: Image(systemName: "stop.circle"))
    RecorderButton(isRecording: .constant(false), buttonAction: {})
}
