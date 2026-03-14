import Foundation

struct Routine: Identifiable, Codable {
    var id = UUID()
    var name: String
    var sets: [Set]

    var totalDuration: TimeInterval {
        sets.reduce(0) { $0 + TimeInterval($1.repetitions) * $1.intervals.reduce(0) { $0 + $1.duration } }
    }
}

struct Set: Identifiable, Codable {
    var id = UUID()
    var intervals: [Interval]
    var repetitions: Int
}

struct Interval: Identifiable, Codable {
    var id = UUID()
    var name: String
    var duration: TimeInterval
    var color: String // "#RRGGBBAA"
}


class WorkoutStore: ObservableObject {
    @Published var workouts: [Routine] = []

    private let key = "saved_workouts"

    init() { load() }

    func add(_ workout: Routine) {
        workouts.append(workout)
        save()
    }

    func update(_ workout: Routine) {
        guard let i = workouts.firstIndex(where: { $0.id == workout.id }) else { return }
        workouts[i] = workout
        save()
    }

    func delete(at offsets: IndexSet) {
        workouts.remove(atOffsets: offsets)
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(workouts) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let decoded = try? JSONDecoder().decode([Routine].self, from: data)
        else { return }
        workouts = decoded
    }
}
