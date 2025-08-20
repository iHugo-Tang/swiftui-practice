import SwiftUI
import AVFoundation

enum SoundEffect: Hashable {
    case lightOn
    case lightOff

    var fileName: String {
        switch self {
        case .lightOn: return "light_switch"
        case .lightOff: return "light_switch"
        }
    }
}

final class SoundPlayer {
    static let shared = SoundPlayer()
    private var players: [SoundEffect: AVAudioPlayer] = [:]

    func play(_ effect: SoundEffect) {
        if let player = players[effect] {
            player.currentTime = 0
            player.play()
            return
        }
        guard let url = Self.findURL(for: effect) else { return }
        guard let player = try? AVAudioPlayer(contentsOf: url) else { return }
        player.prepareToPlay()
        players[effect] = player
        player.play()
    }

    private static func findURL(for effect: SoundEffect) -> URL? {
        let bundle = Bundle.main
        if let wav = bundle.url(forResource: effect.fileName, withExtension: "wav") { return wav }
        if let mp3 = bundle.url(forResource: effect.fileName, withExtension: "mp3") { return mp3 }
        return nil
    }
}

struct ContentView: View {
    @State var isOn = true
    
    var body: some View {
        ZStack {
            LightBeamBackground(isOn: self.$isOn)
                .ignoresSafeArea()
            
            // Foreground content
            Button(action: {
                withAnimation {
                    self.isOn.toggle()
                }
            }) {
                VStack(spacing: 12) {
                    Image(systemName: "lightbulb.max.fill")
                        .font(.system(size: 44, weight: .regular))
                        .foregroundStyle(self.isOn ? .yellow : .white)
                    Text(self.isOn ? "Light On" :"Light Off")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
        }
        .overlay(alignment: .topTrailing) {
            PullCord(isOn: self.$isOn)
                .padding(.top, -40)
                .padding(.trailing, 12)
        }
        .onChange(of: self.isOn, initial: false) { newValue, _  in
            SoundPlayer.shared.play(newValue ? .lightOn : .lightOff)
        }
    }
}

struct LightBeamBackground: View {
    @Binding var isOn: Bool
    
    var lightOnColors = [
        Color(red: 1.00, green: 0.95, blue: 0.65),
        Color(red: 0.99, green: 0.82, blue: 0.35),
        Color(red: 0.20, green: 0.16, blue: 0.07)
    ]
    var lightOffColors = [
        Color(red: 0.20, green: 0.16, blue: 0.07)
    ]
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack {
                // Glow yellow full screen gradient (light at the top and dark at the bottom)
                LinearGradient(
                    colors: self.isOn ? lightOnColors : lightOffColors,
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                if self.isOn {
                    // Soft glow on top (enhanced "lighting" feel)
                    RadialGradient(
                        colors: [
                            Color(red: 1.00, green: 0.95, blue: 0.70).opacity(0.55),
                            Color.white.opacity(0)
                        ],
                        center: .top,
                        startRadius: 0,
                        endRadius: min(size.width, size.height) * 0.9
                    )
                    .frame(width: size.width, height: size.height)
                    .blur(radius: 10)
                    .blendMode(.screen)
                }
            }
            .frame(width: size.width, height: size.height)
        }
    }
}

struct PullCord: View {
    @Binding var isOn: Bool
    @State private var dragOffsetY: CGFloat = 0
    private let baseLineHeight: CGFloat = 140
    private let maxDragDistance: CGFloat = 140
    
    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .fill(Color.white.opacity(0.85))
                .frame(width: 2, height: baseLineHeight + dragOffsetY)
                .animation(.spring(response: 0.25, dampingFraction: 0.85), value: dragOffsetY)
            Circle()
                .fill(Color.white)
                .frame(width: 18, height: 18)
                .shadow(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 1)
                .overlay(
                    Circle()
                        .strokeBorder(Color.black.opacity(0.12), lineWidth: 0.5)
                )
                .offset(y: baseLineHeight + dragOffsetY - 9)
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let dy = max(0, value.translation.height)
                    dragOffsetY = min(dy, maxDragDistance)
                }
                .onEnded { value in
                    let shouldToggle = value.translation.height > maxDragDistance * 0.6
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        dragOffsetY = 0
                        if shouldToggle {
                            isOn.toggle()
                        }
                    }
                }
        )
        .accessibilityLabel("Light pull cord")
        .accessibilityAddTraits(.isButton)
        .padding(.leading, 12)
    }
}

#Preview {
    ContentView()
}
