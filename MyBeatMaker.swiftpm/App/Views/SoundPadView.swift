import SwiftUI

struct SoundPadView: View {
    var body: some View {
        //#-learning-code-snippet(1.createTheGrid)
        SoundButton(sound: .SlowBeat, color: .purple, image: Image(systemName: "star"))
        //#-learning-code-snippet(1.addSoundButton)
    }
}
