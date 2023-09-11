/* This content is from Apple's Sound Pad Playground */

import SwiftUI

struct PlaybackSheetView: View {
    @State var showAlert = false
    @Binding var showShareSheet: Bool
    @EnvironmentObject var mic: Recorder
    
    @State private var fullText: String = "Donne un nom à ta composition"
    @State private var oldText: String = "Sans titre"
    @AccessibilityFocusState private var textAccessibilityFocus: Bool
    var containsPlaceHolderText: Bool {
        fullText == "Donne un nom à ta composition"
    }
    var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    
    var body: some View {
        VStack(alignment: .center) {
            RecordingTitleView(fullText: $fullText, oldText: $oldText, url: url)
                .accessibilityElement(children: .combine)
                .accessibilityFocused($textAccessibilityFocus)
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 5)
                    .frame(height: 5)
                    .foregroundColor(.gray.opacity(0.7))
                    .opacity(0.6)
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: playbackDisplayCalc(geo.size.width), height: 5)
                    .foregroundColor(.white)
            }
            .frame(height:5)
            
            Button {
                mic.playbackToggle()
            } label: {
                Image(systemName: mic.isPlaying == .on ? "pause.fill" : "play.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
            .frame(width: 20, height: 20)
            .padding(.bottom)
            .accessibilityLabel(mic.isPlaying == .on ? "Pause" : "Play")
        }
        .onAppear {
            mic.intializePlayer()
            
            textAccessibilityFocus = true
        }
        .accessibilityAction(.magicTap) {
            mic.playbackToggle()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 40)
        .background(
            Color.purple.opacity(0.5)
                .ignoresSafeArea())
        .overlay(alignment: .bottomTrailing) {
            ShareLink(item: MusicURL(text: (containsPlaceHolderText ? oldText : fullText) + Recorder.fileExtension).url) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color.white)
            }
            .presentationDetents([.fraction(0.5), .large])
            .padding(.horizontal, 40)
            .padding(.vertical, 30)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                showAlert = true
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color.white)
            }
            .alert("As-tu terminé ?", isPresented: $showAlert, actions: {
                Button("Supprimer", role: .destructive, action: {
                    mic.isRecording = .off
                    showShareSheet  = false
                    mic.player?.stop()
                    mic.isPlaying = .off
                })
            }, message: {
                Text("Si tu fermes cette fenêtre, ta composition ne sera pas sauvegardée.")
            })
            .accessibilityLabel("Supprimer")
            .padding()
        }
    }
}

extension PlaybackSheetView {
    func playbackDisplayCalc(_ width: CGFloat) -> CGFloat {
        guard mic.progressTimeRecording != 0 else { return width }
        return CGFloat(Double(width) * (Double(mic.progressTimePlayback) / Double(mic.progressTimeRecording)))
    }
}

struct MusicURL {
    var text: String
    var url: URL {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(text) else {
            fatalError("not a valid URL")
        }
        return url
    }
}

struct RecordingTitleView: View {
    @Binding var fullText: String
    @Binding var oldText: String
    var url: URL?
    var containsPlaceHolderText: Bool {
        fullText == "Donne un nom à ta composition"
    }
    
    var body: some View {
        TextField("", text: $fullText)
            .padding()
            .font(.system(size: 17, weight: containsPlaceHolderText ? .regular : .semibold))
            .background(
                Color.black
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            )
            .foregroundColor(containsPlaceHolderText ? Color.gray : Color.white)
            .onChange(of: fullText) { _ in
                if oldText != fullText {
                    let newURL = url?.appendingPathComponent(fullText + Recorder.fileExtension)
                    let oldURL = url?.appendingPathComponent(oldText + Recorder.fileExtension)
                    oldText = fullText
                    do {
                        if let oldURL = oldURL, let newURL = newURL {
                            try FileManager.default.moveItem(atPath: oldURL.path, toPath: newURL.path)
                        }
                    } catch {
                        print("Error renaming file! Threw: \(error.localizedDescription)")
                    }
                }
            }
            .onTapGesture {
                if containsPlaceHolderText {
                    fullText = ""
                }
            }
            .padding(.bottom, 30)
    }
}
