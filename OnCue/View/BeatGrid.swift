import SwiftUI

struct BeatGrid: View {
    let playhead: Double
    let entry: Double?
    let phraseMarker: Int?
    let accent: Color

    var body: some View {
        Canvas { context, size in
            let inset = 3.0
            let width = size.width - 2 * inset
            let totalBeats = Double(PhraseLesson.totalBeats)
            let baseline = size.height - 6

            func x(for beat: Double) -> Double {
                inset + width * beat / totalBeats
            }

            for beat in 0...PhraseLesson.totalBeats {
                let isTarget = beat == phraseMarker
                let isBar = beat.isMultiple(of: PhraseLesson.beatsPerBar)
                let height = isTarget ? baseline : (isBar ? 25 : 13)
                let lineWidth = isTarget ? 3.0 : (isBar ? 2.0 : 1.0)
                let color = isTarget ? accent : .white.opacity(isBar ? 0.55 : 0.27)
                let tick = CGRect(x: x(for: Double(beat)) - lineWidth / 2,
                                  y: baseline - height, width: lineWidth, height: height)
                context.fill(Path(tick), with: .color(color))
            }

            if let entry {
                let marker = CGRect(x: x(for: entry) - 3, y: baseline - 10, width: 6, height: 12)
                context.fill(Path(roundedRect: marker, cornerRadius: 2), with: .color(.orange))
            }

            let cursor = CGRect(x: x(for: playhead) - 1, y: 0, width: 2, height: baseline - 13)
            context.fill(Path(cursor), with: .color(.white))
        }
        .frame(height: 43)
        .accessibilityHidden(true)

        HStack {
            Text("Start")
                .frame(maxWidth: .infinity, alignment: .leading)
            if phraseMarker != nil {
                Text("Phrase")
                    .foregroundStyle(accent)
            }
            Text("End")
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }
}
