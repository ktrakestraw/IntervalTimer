import SwiftUI

struct WorkoutListView: View {
    @EnvironmentObject var store: WorkoutStore
    @State private var showingEditor = false
    @State private var editingWorkout: Routine? = nil

    var body: some View {
        NavigationStack {
            Group {
                if store.workouts.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle("Workouts")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        editingWorkout = nil
                        showingEditor = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingEditor) {
                WorkoutEditorView(workout: editingWorkout) { saved in
                    if editingWorkout != nil {
                        store.update(saved)
                    } else {
                        store.add(saved)
                    }
                }
            }
        }
    }

    private var list: some View {
        List {
            ForEach(store.workouts) { workout in
                NavigationLink(destination: TimerView(workout: workout)) {
                    WorkoutRow(workout: workout)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        if let i = store.workouts.firstIndex(where: { $0.id == workout.id }) {
                            store.delete(at: IndexSet(integer: i))
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }

                    Button {
                        editingWorkout = workout
                        showingEditor = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.orange)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "timer")
                .font(.displayIcon)
                .foregroundStyle(.secondary)
            Text("No Workouts Yet")
                .font(.title2.bold())
            Text("Tap + to create your first workout")
                .foregroundStyle(.secondary)
            Button("Create Workout") {
                showingEditor = true
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct WorkoutRow: View {
    let workout: Routine

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(workout.name)
                .font(.headline)
            HStack(spacing: 12) {
                Label("\(workout.sets.count) set\(workout.sets.count == 1 ? "" : "s")", systemImage: "list.bullet")
                Label(formattedDuration(workout.totalDuration), systemImage: "clock")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
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
