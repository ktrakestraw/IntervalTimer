import SwiftUI

struct RoutineEditorView: View {
    @Environment(\.dismiss) private var dismiss

    var onSave: (Routine) -> Void

    @State private var routine: Routine

    init(routine: Routine? = nil, onSave: @escaping (Routine) -> Void) {
        _routine = State(initialValue: routine ?? Routine(name: "", sets: [
            Set(intervals: [
                Interval(name: "Warm Up", duration: 30, color: "34C759FF")
            ], reps: 1),
             Set(intervals: [
                Interval(name: "On", duration: 30, color: "FF3B30FF"),
                Interval(name: "Off", duration: 30, color: "34C759FF")
            ], reps: 10)
        ]))
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Routine name", text: $routine.name)
                }

                Section("Sets") {
                    ForEach($routine.sets) { $set in
                        IntervalSetRow(set: $set)
                    }
                    .onDelete { routine.sets.remove(atOffsets: $0) }
                    .onMove { routine.sets.move(fromOffsets: $0, toOffset: $1) }

                    Button {
                        routine.sets.append(Set(intervals: [
                            Interval(name: "Warm Up", duration: 30, color: "34C759FF")
                        ], reps: 1))
                        routine.sets.append(Set(intervals: [
                            Interval(name: "On", duration: 30, color: "FF3B30FF"),
                            Interval(name: "Off", duration: 30, color: "34C759FF")
                        ], reps: 10))
                    } label: {
                        Label("Add Set", systemImage: "plus")
                    }
                }
            }
            .navigationTitle(routine.name.isEmpty ? "New Routine" : routine.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(routine)
                        dismiss()
                    }
                    .disabled(routine.name.isEmpty || routine.sets.isEmpty)
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
            Stepper("Reps: \(set.reps)", value: $set.reps, in: 1...99)

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
