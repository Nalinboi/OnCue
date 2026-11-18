import Foundation

enum PhraseLesson: String, CaseIterable, Identifiable {
    case enterOnPhrase
    case findThePhrase

    var id: Self { self }

    var title: String {
        switch self {
        case .enterOnPhrase: "Enter on the phrase"
        case .findThePhrase: "Find the phrase"
        }
    }

    var instruction: String {
        switch self {
        case .enterOnPhrase:
            "Start Deck B when the playhead reaches the green phrase marker."
        case .findThePhrase:
            "Listen to Deck A’s melody. Count four bars and start Deck B when the melody returns to its opening notes."
        }
    }

    static let bpm = 120
    static let beatsPerBar = 4
    static let beatsPerPhrase = 16
    static let targetBeat = beatsPerPhrase
    static let totalBeats = 2 * beatsPerPhrase
    static let secondsPerBeat = 60.0 / Double(bpm)

    static func feedback(for entry: Double) -> String {
        let difference = entry - Double(targetBeat)
        guard abs(difference) >= 0.1 else { return "On cue!" }

        let distance = (abs(difference) * 10).rounded() / 10
        let unit = distance == 1 ? "beat" : "beats"
        return "\(distance.formatted()) \(unit) \(difference < 0 ? "early" : "late")"
    }
}
