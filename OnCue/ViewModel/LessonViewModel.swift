import Combine

@MainActor
final class LessonViewModel: ObservableObject {
    enum Mode {
        case guided, practice
    }

    private let audio = LessonAudio()
    private var endTask: Task<Void, Never>?
    @Published private(set) var selectedLesson: PhraseLesson = .enterOnPhrase
    @Published private(set) var mode: Mode?
    @Published private(set) var entryBeat: Double?
    @Published private(set) var feedback: String?
    @Published private(set) var isPlaying = false
    private var stoppedBeat = 0.0

    var playhead: Double {
        isPlaying ? min(audio.currentBeat, Double(PhraseLesson.totalBeats)) : stoppedBeat
    }

    var canEnter: Bool {
        isPlaying && mode == .practice && entryBeat == nil
    }

    var showsPhraseMarker: Bool {
        selectedLesson == .enterOnPhrase || mode == .guided || stoppedBeat > 0
    }

    func select(_ lesson: PhraseLesson) {
        guard lesson != selectedLesson else { return }
        reset()
        selectedLesson = lesson
    }

    func start(_ mode: Mode) {
        reset()
        self.mode = mode

        do {
            try audio.start(guided: mode == .guided)
            isPlaying = true
            let duration = Double(PhraseLesson.totalBeats) * PhraseLesson.secondsPerBeat + LessonAudio.startupLead
            endTask = Task { [weak self] in
                do {
                    try await Task.sleep(for: .seconds(duration))
                } catch {
                    return
                }
                self?.finish()
            }
        } catch {
            audio.stop()
            feedback = "Audio couldn’t start. Try again."
        }
    }

    func enter() {
        guard canEnter, let beat = audio.enter() else { return }
        entryBeat = beat
        feedback = PhraseLesson.feedback(for: beat)
    }

    func reset() {
        endTask?.cancel()
        endTask = nil
        audio.stop()
        isPlaying = false
        stoppedBeat = 0
        entryBeat = nil
        mode = nil
        feedback = nil
    }

    private func finish() {
        stoppedBeat = Double(PhraseLesson.totalBeats)
        audio.stop()
        isPlaying = false

        if mode == .guided {
            feedback = "Deck B came in on the phrase. Try it yourself."
        } else if entryBeat == nil {
            feedback = "No entry this time. Try again at the start of the next phrase."
        }
    }
}
