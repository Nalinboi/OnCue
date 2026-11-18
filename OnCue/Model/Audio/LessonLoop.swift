import AVFoundation

enum LessonLoop {
    case backing
    case melody

    private static let sampleRate = 44_100.0
    static let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)

    private static let bassNotes = [55.0, 55.0, 65.41, 49.0]
    private static let backingNotes = [
        261.63, 329.63, 392.0, 329.63,
        220.0, 261.63, 329.63, 261.63,
        261.63, 349.23, 440.0, 349.23,
        293.66, 392.0, 293.66, 196.0
    ]
    private static let melodyNotes = [220.0, 261.63, 329.63, 293.66, 261.63, 220.0, 196.0, 261.63]

    static func make(_ part: Self) throws -> AVAudioPCMBuffer {
        let framesPerBeat = Int(sampleRate * PhraseLesson.secondsPerBeat)
        let frameCount = framesPerBeat * PhraseLesson.beatsPerPhrase
        guard let format,
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(frameCount)),
              let samples = buffer.floatChannelData?[0] else {
            throw CocoaError(.fileReadUnknown)
        }
        buffer.frameLength = AVAudioFrameCount(frameCount)

        let sample: (Int, Double) -> Double
        switch part {
        case .backing: sample = backing
        case .melody: sample = melody
        }

        for frame in 0..<frameCount {
            let beat = frame / framesPerBeat
            let time = Double(frame % framesPerBeat) / sampleRate
            // Fade each beat in and out to avoid clicks at the sample boundaries.
            let attack = min(time / 0.004, 1)
            let tail = min((PhraseLesson.secondsPerBeat - time) / 0.02, 1)
            samples[frame] = Float(sample(beat, time) * attack * tail)
        }
        return buffer
    }

    private static func backing(beat: Int, time: Double) -> Double {
        let kickPhase = 2 * Double.pi * (46 * time + 2.4 * (1 - exp(-38 * time)))
        let downbeat = beat.isMultiple(of: PhraseLesson.beatsPerBar)
        let kick = (downbeat ? 0.55 : 0.38) * sin(kickPhase) * exp(-16 * time)

        let bar = beat / PhraseLesson.beatsPerBar
        let note = bassNotes[bar % bassNotes.count]
        let bass = 0.19 * sin(2 * .pi * note * time) * exp(-5 * time)
        let lead = sin(2 * .pi * backingNotes[beat % backingNotes.count] * time)
        let pluck = 0.12 * lead * exp(-7 * time)
        return kick + bass + pluck
    }

    private static func melody(beat: Int, time: Double) -> Double {
        let note = melodyNotes[beat % melodyNotes.count]
        let tone = sin(2 * .pi * note * time) + 0.3 * sin(4 * .pi * note * time)
        return 0.24 * tone * exp(-8 * time)
    }
}
