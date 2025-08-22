import SwiftUI

struct ConfettiView: View {
    @State private var animate = false
    @State private var xSpeed = Double.random(in: 0.7...2.0)
    @State private var zSpeed = Double.random(in: 1.0...2.0)
    @State private var anchor = CGFloat.random(in: 0...1).rounded()
    @State private var color: Color = [.orange, .green, .blue, .red, .yellow].randomElement() ?? .green

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 14, height: 14)
            .onAppear { animate = true }
            .rotation3DEffect(.degrees(animate ? 360 : 0), axis: (x: 1, y: 0, z: 0))
            .animation(.linear(duration: xSpeed).repeatForever(autoreverses: false), value: animate)
            .rotation3DEffect(.degrees(animate ? 360 : 0),
                              axis: (x: 0, y: 0, z: 1),
                              anchor: UnitPoint(x: anchor, y: anchor))
            .animation(.linear(duration: zSpeed).repeatForever(autoreverses: false), value: animate)
            .animation(.linear(duration: max(zSpeed, xSpeed)).repeatForever(autoreverses: false), value: animate)
    }
}

struct ConfettiContainerView: View {
    var count: Int = 50
    @State private var ySeed: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<count, id: \.self) { _ in
                    ConfettiView()
                        .position(
                            x: CGFloat.random(in: 0...geo.size.width),
                            y: ySeed == 0 ? 0 : CGFloat.random(in: 0...geo.size.height)
                        )
                }
            }
            .ignoresSafeArea()
            .onAppear { ySeed = .random(in: 0...geo.size.height) }
        }
    }
}

struct ConfettiModifier: ViewModifier {
    @Binding var isActive: Bool
    @State private var opacity = 1.0

    private let animationTime = 30.0       // full timing controls in source link
    private let fadeTime = 1.6

    func body(content: Content) -> some View {
        content
            .overlay(isActive ? ConfettiContainerView().opacity(opacity) : nil)
            .onChange(of: isActive, initial: false) { _, value in
                guard value else { return }
                Task {
                    await sequence()
                }
            }
    }

    private func sequence() async {
        do {
            try await Task.sleep(nanoseconds: UInt64(animationTime * 1_000_000_000))
            withAnimation(.easeOut(duration: fadeTime)) {
                isActive = false
                opacity = 0
            }
        } catch {}
    }
}

extension View {
    func displayConfetti(isActive: Binding<Bool>) -> some View {
        modifier(ConfettiModifier(isActive: isActive))
    }
}

#Preview {
    ConfettiContainerView()
}
