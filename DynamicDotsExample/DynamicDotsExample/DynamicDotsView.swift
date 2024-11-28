import SwiftUI

struct DynamicDotsView: View {
    
    // MARK: - Public Properties
    
    let numberOfPages: Int = 4
    @Binding var currentIndex: Int
    @Binding var pageControlIndex: Int

    
    // MARK: - Drawing Constants
    
    private let selectedWidth: CGFloat = 14
    private let radius: CGFloat = 2
    private let spacing: CGFloat = 4
    
    //background: #52C3FF;
    private let primaryColor = Color(#colorLiteral(red: 0.3215686275, green: 0.7647058824, blue: 1, alpha: 1))
    //background: #EAEAEA;
    private let secondaryColor = Color(#colorLiteral(red: 0.9176470588, green: 0.9176470588, blue: 0.9176470588, alpha: 1))
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<numberOfPages, id: \.self) { index in // 1
                if shouldShowIndex(index) {
                    RoundedRectangle(cornerRadius: radius)
                        .fill(currentIndex == index ? primaryColor : secondaryColor) // 2
                        .frame(width: currentIndex == index ? selectedWidth : radius * 2, height: radius * 2)
                        .transition(AnyTransition.opacity.combined(with: .scale)) // 3
                        .onTapGesture {
                            withAnimation {
                                pageControlIndex = index
                            }
                        }
                }
            }
        }
    }
    
    
    // MARK: - Private Methods
    func shouldShowIndex(_ index: Int) -> Bool {
        true
    }
}

#Preview {
    DynamicDotsView(currentIndex: .constant(1), pageControlIndex: .constant(1))
}
