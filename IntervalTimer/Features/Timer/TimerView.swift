import SwiftUI

struct TimerView: View {
    @StateObject private var engine: TimerEngine
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) private var dismiss

    init(routine: Routine) {
        let e = TimerEngine()
        e.load(routine: routine)
        _engine = StateObject(wrappedValue: e)
    }

    private var backgroundColor: Color {
        guard engine.state == .running || engine.state == .paused,
              let phase = engine.currentPhase
        else { return Color(.systemBackground) }
        return Color(hex: phase.color) ?? Color(.systemBackground)
    }

    /// Returns white or black depending on which has better contrast against `backgroundColor`.
    private var foregroundColor: Color {
        guard engine.state == .running || engine.state == .paused,
              let phase = engine.currentPhase,
              let uiColor = UIColor(hex: phase.color)
        else { return Color(.label) }
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        // Relative luminance (WCAG)
        let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return luminance > 0.35 ? .black : .white
    }

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.4), value: backgroundColor)

            VStack(spacing: 32) {
                Spacer()
                phaseDisplay
                timeDisplay
                progressBar
                controls
                Spacer()
            }
            .padding()
            .foregroundStyle(foregroundColor)
            .animation(.easeInOut(duration: 0.4), value: foregroundColor)
        }
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active { engine.syncToCurrentTime() }
        }
    }

    @ViewBuilder
    private var phaseDisplay: some View {
        switch engine.state {
        case .finished:
            VStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.displayIcon)
                Text("Done!")
                    .font(.largeTitle.bold())
            }
        case .idle:
            VStack(spacing: 8) {
                Text("Ready")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.secondary)
                if let first = engine.phases.first {
                    Text(first.detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        default:
            if let phase = engine.currentPhase {
                VStack(spacing: 8) {
                    Text(phase.label)
                        .font(.timerPhaseLabel)
                    Text(phase.detail)
                        .font(.subheadline)
                        .foregroundStyle(foregroundColor.opacity(0.7))
                }
            }
        }
    }

    private var timeDisplay: some View {
        Text(formattedTime(engine.timeRemaining))
            .font(.timerCountdown)
            .contentTransition(.numericText())
    }

    private var progressBar: some View {
        let total = engine.phases.count
        let current = min(engine.currentPhaseIndex, total)
        let progress = total > 0 ? Double(current) / Double(total) : 0

        return ProgressView(value: progress)
            .tint(foregroundColor)
            .animation(.linear(duration: 0.1), value: progress)
    }

    private var controls: some View {
        HStack(spacing: 24) {
            switch engine.state {
            case .idle:
                Button {
                    engine.start()
                } label: {
                    Label("Start", systemImage: "play.fill")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

            case .running:
                Button {
                    engine.pause()
                } label: {
                    Label("Pause", systemImage: "pause.fill")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(foregroundColor.opacity(0.2))

                Button {
                    engine.stop()
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.title2)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

            case .paused:
                Button {
                    engine.resume()
                } label: {
                    Label("Resume", systemImage: "play.fill")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(foregroundColor.opacity(0.2))

                Button {
                    engine.stop()
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.title2)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

            case .finished:
                Button {
                    dismiss()
                } label: {
                    Label("Done", systemImage: "checkmark")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
    }

    private func formattedTime(_ interval: TimeInterval) -> String {
        let total = max(0, Int(ceil(interval)))
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
