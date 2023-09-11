import SwiftUI

struct ContentView: View {
    @StateObject private var mic = Recorder()
    @State private var isPlaying = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "music.note.list")
                Text("Mon Clavier Musical")
            }
            .font(.title)
            .bold()
            .padding(30)
            
            ScrollView {
                SoundPadView()
            }
            .padding(.horizontal)
            .padding(.top)
            
            RecordingView()
                .frame(height: 100, alignment: .bottom)
                .padding(.top, 5)
        }
        .padding(.top)
        .environmentObject(mic)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.purple, .black]), 
                startPoint: .topLeading, 
                endPoint: .bottomTrailing
            )
            .opacity(0.3)
        )
        .onChange(of: mic.loopingButtons.isEmpty) { _ in
            withAnimation {
                isPlaying.toggle()
            }
        }
    }
}
