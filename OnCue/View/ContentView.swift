import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var lesson = LessonViewModel()

    private let accent = Color(red: 0.80, green: 0.96, blue: 0.42)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("On Cue")
                        .font(.headline)
                        .foregroundStyle(accent)
                    Picker("Lesson", selection: Binding(
                        get: { lesson.selectedLesson },
                        set: { lesson.select($0) }
                    )) {
                        ForEach(PhraseLesson.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)

                    Text(lesson.selectedLesson.title)
                        .font(.largeTitle.bold())
                        .accessibilityAddTraits(.isHeader)
                    Text(lesson.selectedLesson.instruction)
                        .foregroundStyle(.secondary)
                }

                TimelineView(.animation(paused: !lesson.isPlaying)) { _ in
                    VStack(spacing: 12) {
                        deck("Deck A", detail: "Rhythm + melody", playhead: lesson.playhead)
                        deck("Deck B", detail: "Melody", playhead: lesson.playhead,
                             entry: lesson.entryBeat, showsButton: true)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    ViewThatFits(in: .horizontal) {
                        HStack { lessonControls }
                        VStack(alignment: .leading) { lessonControls }
                    }
                    .tint(accent)
                    .controlSize(.large)

                    if let feedback = lesson.feedback {
                        Text(feedback)
                            .font(.headline)
                            .accessibilityAddTraits(.updatesFrequently)
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: 620)
            .frame(maxWidth: .infinity)
        }
        .background(Color(red: 0.06, green: 0.08, blue: 0.10).ignoresSafeArea())
        .preferredColorScheme(.dark)
        .onChange(of: scenePhase) { _, phase in
            if phase != .active && lesson.isPlaying { lesson.reset() }
        }
        .onDisappear { lesson.reset() }
    }

    @ViewBuilder
    private var lessonControls: some View {
        Button("Watch demo") { lesson.start(.guided) }
            .buttonStyle(.bordered)
        Button("Start practice") { lesson.start(.practice) }
            .buttonStyle(.borderedProminent)
        if lesson.isPlaying {
            Button("Stop") { lesson.reset() }
                .buttonStyle(.bordered)
        }
    }

    private func deck(
        _ title: String,
        detail: String,
        playhead: Double,
        entry: Double? = nil,
        showsButton: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.headline)
                    Text("\(detail) · \(PhraseLesson.bpm) BPM")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if showsButton {
                    DeckPlayButton(
                        isEnabled: lesson.canEnter,
                        isPlaying: lesson.isPlaying && lesson.entryBeat != nil,
                        action: lesson.enter
                    )
                }
            }

            BeatGrid(playhead: playhead, entry: entry,
                     phraseMarker: lesson.showsPhraseMarker ? PhraseLesson.targetBeat : nil,
                     accent: accent)
        }
        .padding(16)
        .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 16))
    }
}
