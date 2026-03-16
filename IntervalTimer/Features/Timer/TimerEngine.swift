import Foundation
import Combine

struct PhaseSpec {
    let label: String   // Interval name
    let detail: String  // "Rep 2/10 · Set 1/2"
    let duration: TimeInterval
    let color: String   // "#RRGGBBAA"
}

enum TimerState {
    case idle, running, paused, finished
}

class TimerEngine: ObservableObject {
    @Published var state: TimerState = .idle
    @Published var currentPhaseIndex: Int = 0
    @Published var timeRemaining: TimeInterval = 0

    private(set) var phases: [PhaseSpec] = []
    private var phaseEndDates: [Date] = []
    private var ticker: AnyCancellable?
    private var pausedRemaining: TimeInterval = 0

    var currentPhase: PhaseSpec? {
        guard currentPhaseIndex < phases.count else { return nil }
        return phases[currentPhaseIndex]
    }

    func load(routine: Routine) {
        phases = Self.buildPhases(from: routine)
        currentPhaseIndex = 0
        timeRemaining = phases.first?.duration ?? 0
        state = .idle
        ticker?.cancel()
    }

    func start() {
        guard !phases.isEmpty else { return }
        currentPhaseIndex = 0
        buildEndDates(startingNow: Date())
        timeRemaining = phases[0].duration
        state = .running
        startTicker()
    }

    func pause() {
        guard state == .running, currentPhaseIndex < phaseEndDates.count else { return }
        pausedRemaining = phaseEndDates[currentPhaseIndex].timeIntervalSinceNow
        ticker?.cancel()
        state = .paused
    }

    func resume() {
        guard state == .paused else { return }
        // Rebuild end dates from paused position
        let newCurrentEnd = Date().addingTimeInterval(pausedRemaining)
        var cursor = newCurrentEnd
        for i in currentPhaseIndex..<phaseEndDates.count {
            if i == currentPhaseIndex {
                phaseEndDates[i] = newCurrentEnd
            } else {
                cursor = cursor.addingTimeInterval(phases[i].duration)
                phaseEndDates[i] = cursor
            }
        }
        state = .running
        startTicker()
    }

    func stop() {
        ticker?.cancel()
        state = .idle
    }

    // Call when app returns to foreground to catch up on elapsed phases
    func syncToCurrentTime() {
        guard state == .running, !phaseEndDates.isEmpty else { return }
        while currentPhaseIndex < phaseEndDates.count && phaseEndDates[currentPhaseIndex] <= Date() {
            currentPhaseIndex += 1
        }
        if currentPhaseIndex >= phaseEndDates.count {
            timeRemaining = 0
            state = .finished
            ticker?.cancel()
        }
    }

    private func buildEndDates(startingNow start: Date) {
        var cursor = start
        phaseEndDates = phases.map { phase in
            cursor = cursor.addingTimeInterval(phase.duration)
            return cursor
        }
    }

    private func startTicker() {
        ticker?.cancel()
        ticker = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
    }

    private func tick() {
        guard state == .running, currentPhaseIndex < phaseEndDates.count else { return }
        let remaining = phaseEndDates[currentPhaseIndex].timeIntervalSinceNow
        if remaining <= 0 {
            currentPhaseIndex += 1
            if currentPhaseIndex >= phaseEndDates.count {
                timeRemaining = 0
                state = .finished
                ticker?.cancel()
            } else {
                timeRemaining = phaseEndDates[currentPhaseIndex].timeIntervalSinceNow
            }
        } else {
            timeRemaining = remaining
        }
    }

    static func buildPhases(from routine: Routine) -> [PhaseSpec] {
        var specs: [PhaseSpec] = []
        let totalSets = routine.sets.count
        for (si, set) in routine.sets.enumerated() {
            let reps = max(1, set.reps)
            for rep in 1...reps {
                for interval in set.intervals {
                    specs.append(PhaseSpec(
                        label: interval.name,
                        detail: "Rep \(rep)/\(reps)  ·  Set \(si + 1)/\(totalSets)",
                        duration: interval.duration,
                        color: interval.color
                    ))
                }
            }
        }
        return specs
    }
}
