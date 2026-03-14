//
//  IntervalTimerTests.swift
//  IntervalTimerTests
//
//  Created by Kevin Rakestraw on 3/14/26.
//

import Foundation
import Testing
@testable import IntervalTimer

// MARK: - Helpers

private func makeInterval(name: String = "Work", duration: TimeInterval = 30) -> Interval {
    Interval(name: name, duration: duration, color: "#FF0000FF")
}

private func makeSet(intervals: [Interval], repetitions: Int = 1) -> IntervalTimer.Set {
    IntervalTimer.Set(intervals: intervals, repetitions: repetitions)
}

private func makeRoutine(sets: [IntervalTimer.Set], name: String = "Test") -> Routine {
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
        let routine = makeRoutine(sets: [makeSet(intervals: [makeInterval(duration: 30)], repetitions: 3)])
        #expect(routine.totalDuration == 90)
    }

    @Test("multiple intervals per set")
    func multipleIntervals() {
        let set = makeSet(intervals: [makeInterval(duration: 30), makeInterval(duration: 10)], repetitions: 2)
        let routine = makeRoutine(sets: [set])
        #expect(routine.totalDuration == 80) // (30 + 10) * 2
    }

    @Test("multiple sets")
    func multipleSets() {
        let set1 = makeSet(intervals: [makeInterval(duration: 30)], repetitions: 2)
        let set2 = makeSet(intervals: [makeInterval(duration: 20)], repetitions: 3)
        let routine = makeRoutine(sets: [set1, set2])
        #expect(routine.totalDuration == 120) // 30*2 + 20*3
    }

    @Test("empty routine")
    func emptyRoutine() {
        let routine = makeRoutine(sets: [])
        #expect(routine.totalDuration == 0)
    }
}

// MARK: - TimerEngine.buildPhases

@Suite("TimerEngine.buildPhases")
struct BuildPhasesTests {

    @Test("phase count matches reps × intervals")
    func phaseCount() {
        let set = makeSet(intervals: [makeInterval(), makeInterval()], repetitions: 3)
        let phases = TimerEngine.buildPhases(from: makeRoutine(sets: [set]))
        #expect(phases.count == 6)
    }

    @Test("phase count across multiple sets")
    func phaseCountMultipleSets() {
        let set1 = makeSet(intervals: [makeInterval()], repetitions: 2)
        let set2 = makeSet(intervals: [makeInterval(), makeInterval()], repetitions: 3)
        let phases = TimerEngine.buildPhases(from: makeRoutine(sets: [set1, set2]))
        #expect(phases.count == 8) // 1*2 + 2*3
    }

    @Test("phase label matches interval name")
    func phaseLabel() {
        let set = makeSet(intervals: [makeInterval(name: "Sprint")])
        let phases = TimerEngine.buildPhases(from: makeRoutine(sets: [set]))
        #expect(phases[0].label == "Sprint")
    }

    @Test("phase duration matches interval duration")
    func phaseDuration() {
        let set = makeSet(intervals: [makeInterval(duration: 45)])
        let phases = TimerEngine.buildPhases(from: makeRoutine(sets: [set]))
        #expect(phases[0].duration == 45)
    }

    @Test("phase color matches interval color")
    func phaseColor() {
        let interval = Interval(name: "Work", duration: 30, color: "#AABBCCFF")
        let phases = TimerEngine.buildPhases(from: makeRoutine(sets: [makeSet(intervals: [interval])]))
        #expect(phases[0].color == "#AABBCCFF")
    }

    @Test("detail string — single set, single rep")
    func detailSingleSetSingleRep() {
        let set = makeSet(intervals: [makeInterval()], repetitions: 1)
        let phases = TimerEngine.buildPhases(from: makeRoutine(sets: [set]))
        #expect(phases[0].detail == "Rep 1/1  ·  Set 1/1")
    }

    @Test("detail string — rep counter increments correctly")
    func detailRepCounter() {
        let set = makeSet(intervals: [makeInterval()], repetitions: 3)
        let phases = TimerEngine.buildPhases(from: makeRoutine(sets: [set]))
        #expect(phases[0].detail == "Rep 1/3  ·  Set 1/1")
        #expect(phases[1].detail == "Rep 2/3  ·  Set 1/1")
        #expect(phases[2].detail == "Rep 3/3  ·  Set 1/1")
    }

    @Test("detail string — set counter increments correctly")
    func detailSetCounter() {
        let set1 = makeSet(intervals: [makeInterval()], repetitions: 1)
        let set2 = makeSet(intervals: [makeInterval()], repetitions: 1)
        let phases = TimerEngine.buildPhases(from: makeRoutine(sets: [set1, set2]))
        #expect(phases[0].detail == "Rep 1/1  ·  Set 1/2")
        #expect(phases[1].detail == "Rep 1/1  ·  Set 2/2")
    }

    @Test("detail string — multiple intervals keep same rep within a rep")
    func detailMultipleIntervalsPerRep() {
        let set = makeSet(intervals: [makeInterval(name: "Work"), makeInterval(name: "Rest")], repetitions: 2)
        let phases = TimerEngine.buildPhases(from: makeRoutine(sets: [set]))
        // Rep 1: Work, Rest — Rep 2: Work, Rest
        #expect(phases[0].detail == "Rep 1/2  ·  Set 1/1")
        #expect(phases[1].detail == "Rep 1/2  ·  Set 1/1")
        #expect(phases[2].detail == "Rep 2/2  ·  Set 1/1")
        #expect(phases[3].detail == "Rep 2/2  ·  Set 1/1")
    }

    @Test("empty routine produces no phases")
    func emptyRoutine() {
        let phases = TimerEngine.buildPhases(from: makeRoutine(sets: []))
        #expect(phases.isEmpty)
    }

    @Test("zero repetitions treated as one rep")
    func zeroRepetitionsClampedToOne() {
        let set = makeSet(intervals: [makeInterval()], repetitions: 0)
        let phases = TimerEngine.buildPhases(from: makeRoutine(sets: [set]))
        #expect(phases.count == 1)
    }

    @Test("phase order: intervals within a rep are in order")
    func phaseOrderWithinRep() {
        let work = makeInterval(name: "Work", duration: 40)
        let rest = makeInterval(name: "Rest", duration: 20)
        let set = makeSet(intervals: [work, rest], repetitions: 1)
        let phases = TimerEngine.buildPhases(from: makeRoutine(sets: [set]))
        #expect(phases[0].label == "Work")
        #expect(phases[1].label == "Rest")
    }
}

// MARK: - WorkoutStore (in-memory)

@Suite("WorkoutStore")
struct WorkoutStoreTests {

    @Test("add appends a routine")
    func add() {
        let store = WorkoutStore()
        store.workouts = []
        let routine = makeRoutine(sets: [])
        store.add(routine)
        #expect(store.workouts.count == 1)
        #expect(store.workouts[0].id == routine.id)
    }

    @Test("update replaces existing routine by id")
    func update() {
        let store = WorkoutStore()
        var routine = makeRoutine(sets: [], name: "Original")
        store.workouts = [routine]
        routine.name = "Updated"
        store.update(routine)
        #expect(store.workouts[0].name == "Updated")
    }

    @Test("update ignores unknown id")
    func updateUnknownId() {
        let store = WorkoutStore()
        store.workouts = [makeRoutine(sets: [], name: "Existing")]
        let stranger = makeRoutine(sets: [], name: "Stranger")
        store.update(stranger)
        #expect(store.workouts.count == 1)
        #expect(store.workouts[0].name == "Existing")
    }

    @Test("delete removes routine at offset")
    func delete() {
        let store = WorkoutStore()
        let a = makeRoutine(sets: [], name: "A")
        let b = makeRoutine(sets: [], name: "B")
        store.workouts = [a, b]
        store.delete(at: IndexSet(integer: 0))
        #expect(store.workouts.count == 1)
        #expect(store.workouts[0].name == "B")
    }
}
