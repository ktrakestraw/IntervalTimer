import SwiftUI

struct TimerView: View {
    @StateObject private var engine: TimerEngine
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) private var dismiss

    init(workout: Routine) {
        let e = TimerEngine()
        e.load(workout: workout)
        _engine = StateObject(wrappedValue: e)
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            phaseDisplay

            timeDisplay

            progressBar

            controls

            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                engine.syncToCurrentTime()
            }
        }
    }

    @ViewBuilder
    private var phaseDisplay: some View {
        switch engine.state {
        case .finished:
            VStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.green)
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
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(phase.label == "Work" ? Color.red : Color.blue)
                    Text(phase.detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var timeDisplay: some View {
        Text(formattedTime(engine.timeRemaining))
            .font(.system(size: 80, weight: .thin, design: .monospaced))
            .contentTransition(.numericText())
    }

    private var progressBar: some View {
        let total = engine.phases.count
        let current = min(engine.currentPhaseIndex, total)
        let progress = total > 0 ? Double(current) / Double(total) : 0

        return ProgressView(value: progress)
            .tint(engine.currentPhase?.label == "Work" ? .red : .blue)
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
                .tint(.orange)

                Button {
                    engine.stop()
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.title2)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .tint(.red)

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

                Button {
                    engine.stop()
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.title2)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .tint(.red)

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
                .tint(.green)
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
