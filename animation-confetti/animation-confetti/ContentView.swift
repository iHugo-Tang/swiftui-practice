
import SwiftUI

struct ContentView: View {
    @State private var showConfetti = false

    var body: some View {
        VStack {
            Text("You did it").font(.title.bold())
            Button("Celebrate") {
                self.showConfetti.toggle()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .displayConfetti(isActive: $showConfetti)
    }
}

#Preview {
    ContentView()
}
