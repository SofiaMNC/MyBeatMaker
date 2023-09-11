/* This content is adapted from Apple's Sound Pad Playground */

import SwiftUI
import AudioToolbox
import CoreMedia

struct RecordingView: View {
    @EnvironmentObject var mic: Recorder
    @State private var showShareSheet = false
    
    let startRecordingGreen = LinearGradient(
        gradient: Gradient(colors: [.purple, .black]), 
        startPoint: .top, 
        endPoint: .bottom
    )
    let stopRecordingRed = LinearGradient(
        gradient: Gradient(colors: [.pink, .black]), 
        startPoint: .top, 
        endPoint: .bottom
    )
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .center) {
                ZStack {
                    HStack {
                        Image(systemName: "record.circle")
                        Text(mic.isRecording == .on ? "Stop Enregistrement" : "Enregistrer")
                    }
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(20)
                    .background(mic.isRecording == .on ? stopRecordingRed : startRecordingGreen)
                    .clipShape(Capsule())
                    .padding(3)
                    .background(.white)
                    .clipShape(Capsule())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            mic.isRecording = mic.isRecording == .on ? .off : .on
                            showShareSheet = mic.startRecording(countSamples: Int(geo.size.width*0.2))
                        }
                    }
                    .sheet(isPresented: $showShareSheet) {
                        PlaybackSheetView(showShareSheet: $showShareSheet)
                            .environmentObject(mic)
                            .presentationDetents([.fraction(0.4)])
                            .interactiveDismissDisabled()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(10)
            }
            .background(.thinMaterial)
        }
    }
}
