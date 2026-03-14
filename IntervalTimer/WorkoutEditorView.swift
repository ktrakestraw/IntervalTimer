import SwiftUI

struct WorkoutEditorView: View {
    @Environment(\.dismiss) private var dismiss

    var onSave: (Routine) -> Void

    @State private var workout: Routine

    init(workout: Routine? = nil, onSave: @escaping (Routine) -> Void) {
        _workout = State(initialValue: workout ?? Routine(name: "", sets: [
            Set(intervals: [
                Interval(name: "Work", duration: 30, color: "FF3B30FF"),
                Interval(name: "Rest", duration: 30, color: "34C759FF")
            ], repetitions: 10)
        ]))
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Workout name", text: $workout.name)
                }

                Section("Sets") {
                    ForEach($workout.sets) { $set in
                        IntervalSetRow(set: $set)
                    }
                    .onDelete { workout.sets.remove(atOffsets: $0) }
                    .onMove { workout.sets.move(fromOffsets: $0, toOffset: $1) }

                    Button {
                        workout.sets.append(Set(intervals: [
                            Interval(name: "Work", duration: 30, color: "FF3B30FF"),
                            Interval(name: "Rest", duration: 30, color: "34C759FF")
                        ], repetitions: 10))
                    } label: {
                        Label("Add Set", systemImage: "plus")
                    }
                }
            }
            .navigationTitle(workout.name.isEmpty ? "New Workout" : workout.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(workout)
                        dismiss()
                    }
                    .disabled(workout.name.isEmpty || workout.sets.isEmpty)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    }
}

struct IntervalSetRow: View {
    @Binding var set: Set

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Stepper("Reps: \(set.repetitions)", value: $set.repetitions, in: 1...99)

            ForEach($set.intervals) { $interval in
                IntervalRow(interval: $interval)
            }
            .onDelete { set.intervals.remove(atOffsets: $0) }

            Button {
                set.intervals.append(Interval(name: "Interval", duration: 30, color: "007AFFFF"))
            } label: {
                Label("Add Interval", systemImage: "plus")
            }
            .font(.subheadline)
        }
        .padding(.vertical, 4)
    }
}

struct IntervalRow: View {
    @Binding var interval: Interval

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                ColorPicker("", selection: colorBinding, supportsOpacity: false)
                    .labelsHidden()
                    .frame(width: 28)
                TextField("Name", text: $interval.name)
            }
            DurationStepper(label: "Duration", duration: $interval.duration)
        }
        .padding(.leading, 8)
    }

    private var colorBinding: Binding<Color> {
        Binding(
            get: { Color(hex: interval.color) ?? .blue },
            set: { interval.color = $0.hexString }
        )
    }
}

struct DurationStepper: View {
    let label: String
    @Binding var duration: TimeInterval

    var body: some View {
        HStack {
            Text("\(label): \(formattedDuration(duration))")
                .frame(minWidth: 140, alignment: .leading)
            Spacer()
            Stepper("", value: $duration, in: 5...3600, step: 5)
                .labelsHidden()
        }
    }

    private func formattedDuration(_ interval: TimeInterval) -> String {
        let total = Int(interval)
        let m = total / 60
        let s = total % 60
        if m > 0 {
            return s > 0 ? "\(m)m \(s)s" : "\(m)m"
        }
        return "\(s)s"
    }
}

private extension Color {
    init?(hex: String) {
        var int: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&int), hex.count == 8 else { return nil }
        let r = Double((int >> 24) & 0xFF) / 255
        let g = Double((int >> 16) & 0xFF) / 255
        let b = Double((int >> 8)  & 0xFF) / 255
        let a = Double( int        & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }

    var hexString: String {
        let c = UIColor(self).cgColor.components ?? [0, 0, 0, 1]
        let r = c[0], g = c[1], b = c[2], a = c.count > 3 ? c[3] : 1
        return String(format: "%02X%02X%02X%02X",
            Int(r * 255), Int(g * 255), Int(b * 255), Int(a * 255))
    }
}
