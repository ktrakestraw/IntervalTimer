import Foundation

struct Routine: Identifiable, Codable {
    var id = UUID()
    var name: String
    var sets: [Set]

    var totalDuration: TimeInterval {
        sets.reduce(0) { $0 + TimeInterval($1.reps) * $1.intervals.reduce(0) { $0 + $1.duration } }
    }
}

struct Set: Identifiable, Codable {
    var id = UUID()
    var intervals: [Interval]
    var reps: Int
}

struct Interval: Identifiable, Codable {
    var id = UUID()
    var name: String
    var duration: TimeInterval
    var color: String // "#RRGGBBAA"
}


class RoutineStore: ObservableObject {
    @Published var routines: [Routine] = []

    private let key = "saved_routines"

    init() { load() }

    func add(_ routine: Routine) {
        routines.append(routine)
        save()
    }

    func update(_ routine: Routine) {
        guard let i = routines.firstIndex(where: { $0.id == routine.id }) else { return }
        routines[i] = routine
        save()
    }

    func delete(at offsets: IndexSet) {
        routines.remove(atOffsets: offsets)
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(routines) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let decoded = try? JSONDecoder().decode([Routine].self, from: data)
        else { return }
        routines = decoded
    }
}
