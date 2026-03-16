import SwiftUI

extension Font {
    /// Large countdown clock displayed during a routine phase.
    static let timerCountdown = Font.system(size: 80, weight: .bold).monospacedDigit()

    /// Phase name shown above the countdown (e.g. "Work", "Rest").
    static let timerPhaseLabel = Font.system(size: 48, weight: .bold)

    /// Oversized icon used in empty and finished states.
    static let displayIcon = Font.system(size: 64)
}
