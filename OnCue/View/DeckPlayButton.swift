import SwiftUI

struct DeckPlayButton: View {
    let isEnabled: Bool
    let isPlaying: Bool
    let action: () -> Void

    private let indicator = Color(red: 0.64, green: 0.95, blue: 0.45)

    var body: some View {
        Button(action: action) {
            Image(systemName: "playpause.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(isPlaying ? .black : indicator.opacity(isEnabled ? 1 : 0.48))
                .frame(width: 56, height: 56)
                .background(isPlaying ? indicator : Color(white: 0.11), in: Circle())
                .overlay {
                    Circle().strokeBorder(indicator.opacity(isEnabled || isPlaying ? 0.9 : 0.33), lineWidth: 2)
                }
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel("Play Deck B")
    }
}
