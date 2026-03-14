import SwiftUI

struct WorkoutEditorView: View {
    @Environment(\.dismiss) private var dismiss

    var onSave: (Routine) -> Void

    @State private var workout: Routine

    init(workout: Routine? = nil, onSave: @escaping (Routine) -> Void) {
        _workout = State(initialValue: workout ?? Routine(name: "", sets: [
            IntervalSet(workDuration: 30, restDuration: 30, repetitions: 10)
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
                        workout.sets.append(IntervalSet(workDuration: 30, restDuration: 30, repetitions: 10))
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
    @Binding var set: IntervalSet

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Stepper("Reps: \(set.repetitions)", value: $set.repetitions, in: 1...99)

            DurationStepper(label: "Work", duration: $set.workDuration)
            DurationStepper(label: "Rest", duration: $set.restDuration)
        }
        .padding(.vertical, 4)
    }
}

struct DurationStepper: View {
    let label: String
    @Binding var duration: TimeInterval

    private var seconds: Int {
        Int(duration)
    }

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
