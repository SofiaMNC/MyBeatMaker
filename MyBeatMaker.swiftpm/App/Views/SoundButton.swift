import AVFoundation
import SwiftUI

struct SoundButton: View {
    @EnvironmentObject private var mic: Recorder
    @StateObject private var soundPlayer = SoundPlayer(engine: Recorder.engine)

    @State var isLooping = false
    @State private var animationAmount = 1.0

    let node = AVAudioPlayerNode()
    let color: Color
    let sound: Sound
    let image: Image
    
    init(sound: Sound, color: Color, image: Image) {
        self.sound = sound
        self.color = color
        self.image = image
    }
    
    var body: some View {
        Button(
            action: {
                animationAmount = animationAmount == 0.95 ? 1.0 : 0.95
                isLooping.toggle()

                if isLooping {
                    soundPlayer.playLoop(
                        sound, 
                        node: node, 
                        pitch: 0.0, 
                        speed: 1.0, 
                        volume: 1.0, 
                        filter: nil, 
                        isRecording: $mic.isRecording, 
                        isLooping: $isLooping, 
                        loopingButtons: $mic.loopingButtons
                    )
                }
            }, 
            label: {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 95, height: 95, alignment: .center)
                    .padding(20)
            }
        )
        .foregroundColor(.white)
        .background(color.gradient)
        .cornerRadius(15, antialiased: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
        .scaleEffect(animationAmount, anchor: .center)
        .animation(
            isLooping ? 
                .easeInOut(duration: 0.5).repeatForever(autoreverses: true) :
                .easeInOut(duration: 0.5), 
            value: animationAmount
        )
    }
}

struct SoundButton_Previews: PreviewProvider {
    static var previews: some View {
        SoundButton(sound: .CosmicBass, color: .pink, image: Image(systemName: "star"))
            .environmentObject(Recorder())
    }
}
