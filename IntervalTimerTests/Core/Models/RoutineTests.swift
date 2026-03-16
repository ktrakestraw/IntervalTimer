import Foundation
import Testing
@testable import IntervalTimer

// MARK: - Helpers

func makeInterval(name: String = "Work", duration: TimeInterval = 30) -> Interval {
    Interval(name: name, duration: duration, color: "#FF0000FF")
}

func makeSet(intervals: [Interval], reps: Int = 1) -> IntervalTimer.Set {
    IntervalTimer.Set(intervals: intervals, reps: reps)
}

func makeRoutine(sets: [IntervalTimer.Set], name: String = "Test") -> Routine {
    Routine(name: name, sets: sets)
}

// MARK: - Routine.totalDuration

@Suite("Routine.totalDuration")
struct RoutineTotalDurationTests {

    @Test("single interval, single rep")
    func singleIntervalSingleRep() {
        let routine = makeRoutine(sets: [makeSet(intervals: [makeInterval(duration: 30)])])
        #expect(routine.totalDuration == 30)
    }

    @Test("single interval, multiple reps")
    func singleIntervalMultipleReps() {
        let routine = makeRoutine(sets: [makeSet(intervals: [makeInterval(duration: 30)], reps: 3)])
        #expect(routine.totalDuration == 90)
    }

    @Test("multiple intervals per set")
    func multipleIntervals() {
        let set = makeSet(intervals: [makeInterval(duration: 30), makeInterval(duration: 10)], reps: 2)
        let routine = makeRoutine(sets: [set])
        #expect(routine.totalDuration == 80) // (30 + 10) * 2
    }

    @Test("multiple sets")
    func multipleSets() {
        let set1 = makeSet(intervals: [makeInterval(duration: 30)], reps: 2)
        let set2 = makeSet(intervals: [makeInterval(duration: 20)], reps: 3)
        let routine = makeRoutine(sets: [set1, set2])
        #expect(routine.totalDuration == 120) // 30*2 + 20*3
    }

    @Test("empty routine")
    func emptyRoutine() {
        let routine = makeRoutine(sets: [])
        #expect(routine.totalDuration == 0)
    }
}

// MARK: - RoutineStore

@Suite("RoutineStore")
struct RoutineStoreTests {

    @Test("add appends a routine")
    func add() {
        let store = RoutineStore()
        store.routines = []
        let routine = makeRoutine(sets: [])
        store.add(routine)
        #expect(store.routines.count == 1)
        #expect(store.routines[0].id == routine.id)
    }

    @Test("update replaces existing routine by id")
    func update() {
        let store = RoutineStore()
        var routine = makeRoutine(sets: [], name: "Original")
        store.routines = [routine]
        routine.name = "Updated"
        store.update(routine)
        #expect(store.routines[0].name == "Updated")
    }

    @Test("update ignores unknown id")
    func updateUnknownId() {
        let store = RoutineStore()
        store.routines = [makeRoutine(sets: [], name: "Existing")]
        let stranger = makeRoutine(sets: [], name: "Stranger")
        store.update(stranger)
        #expect(store.routines.count == 1)
        #expect(store.routines[0].name == "Existing")
    }

    @Test("delete removes routine at offset")
    func delete() {
        let store = RoutineStore()
        let a = makeRoutine(sets: [], name: "A")
        let b = makeRoutine(sets: [], name: "B")
        store.routines = [a, b]
        store.delete(at: IndexSet(integer: 0))
        #expect(store.routines.count == 1)
        #expect(store.routines[0].name == "B")
    }
}
