import Foundation

struct Routine: Identifiable, Codable {
    var id = UUID()
    var name: String
    var sets: [IntervalSet]

    var totalDuration: TimeInterval {
        sets.reduce(0) { $0 + TimeInterval($1.repetitions) * ($1.workDuration + $1.restDuration) }
    }
}

struct IntervalSet: Identifiable, Codable {
    var id = UUID()
    var workDuration: TimeInterval  // seconds
    var restDuration: TimeInterval  // seconds
    var repetitions: Int
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
