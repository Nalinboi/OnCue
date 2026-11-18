import AVFoundation
import Darwin

@MainActor
final class LessonAudio {
    private let engine = AVAudioEngine()
    private let deckA = AVAudioPlayerNode()
    private let deckB = AVAudioPlayerNode()
    // Give the render thread time to start before the first scheduled player.
    static let startupLead = 0.15
    private let entryLead = 0.02

    private var startTime: UInt64?
    private var sessionActive = false

    init() {
        for deck in [deckA, deckB] {
            engine.attach(deck)
            engine.connect(deck, to: engine.mainMixerNode, format: LessonLoop.format)
        }
    }

    var currentBeat: Double {
        guard let startTime else { return 0 }
        return beat(at: max(startTime, mach_absolute_time()), from: startTime)
    }

    func start(guided: Bool) throws {
        stop()
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback)
        try session.setActive(true)
        sessionActive = true

        deckA.scheduleBuffer(try LessonLoop.make(.backing), at: nil, options: .loops)
        deckB.scheduleBuffer(try LessonLoop.make(.melody), at: nil, options: .loops)
        try engine.start()

        let start = mach_absolute_time() + AVAudioTime.hostTime(forSeconds: Self.startupLead)
        startTime = start
        deckA.play(at: AVAudioTime(hostTime: start))
        if guided {
            let delay = Double(PhraseLesson.targetBeat) * PhraseLesson.secondsPerBeat
            deckB.play(at: AVAudioTime(hostTime: start + AVAudioTime.hostTime(forSeconds: delay)))
        }
    }

    func enter() -> Double? {
        guard let startTime else { return nil }
        let entryTime = max(startTime, mach_absolute_time() + AVAudioTime.hostTime(forSeconds: entryLead))
        let entryBeat = beat(at: entryTime, from: startTime)
        guard entryBeat < Double(PhraseLesson.totalBeats) else { return nil }
        deckB.play(at: AVAudioTime(hostTime: entryTime))
        return entryBeat
    }

    func stop() {
        deckA.stop()
        deckB.stop()
        engine.stop()
        if sessionActive {
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            sessionActive = false
        }
        startTime = nil
    }

    private func beat(at time: UInt64, from start: UInt64) -> Double {
        AVAudioTime.seconds(forHostTime: time - start) / PhraseLesson.secondsPerBeat
    }
}
