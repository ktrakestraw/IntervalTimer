import SwiftUI

struct RoutineListView: View {
    @EnvironmentObject var store: RoutineStore
    @State private var showingEditor = false
    @State private var editingRoutine: Routine? = nil

    var body: some View {
        NavigationStack {
            Group {
                if store.routines.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle("Routines")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        editingRoutine = nil
                        showingEditor = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingEditor) {
                RoutineEditorView(routine: editingRoutine) { saved in
                    if editingRoutine != nil {
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
            ForEach(store.routines) { routine in
                NavigationLink(destination: TimerView(routine: routine)) {
                    RoutineRow(routine: routine)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        if let i = store.routines.firstIndex(where: { $0.id == routine.id }) {
                            store.delete(at: IndexSet(integer: i))
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }

                    Button {
                        editingRoutine = routine
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
            Text("No Routines Yet")
                .font(.title2.bold())
            Text("Tap + to create your first routine")
                .foregroundStyle(.secondary)
            Button("Create Routine") {
                showingEditor = true
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct RoutineRow: View {
    let routine: Routine

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(routine.name)
                .font(.headline)
            HStack(spacing: 12) {
                Label("\(routine.sets.count) set\(routine.sets.count == 1 ? "" : "s")", systemImage: "list.bullet")
                Label(formattedDuration(routine.totalDuration), systemImage: "clock")
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
