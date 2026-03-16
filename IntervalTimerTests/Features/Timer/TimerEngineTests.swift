import Foundation
import Testing
@testable import IntervalTimer

// MARK: - TimerEngine.buildPhases

@Suite("TimerEngine.buildPhases")
struct BuildPhasesTests {

    @Test("phase count matches reps × intervals")
    func phaseCount() {
        let set = makeSet(intervals: [makeInterval(), makeInterval()], reps: 3)
        let phases = TimerEngine.buildPhases(from: makeRoutine(sets: [set]))
        #expect(phases.count == 6)
    }

    @Test("phase count across multiple sets")
    func phaseCountMultipleSets() {
        let set1 = makeSet(intervals: [makeInterval()], reps: 2)
        let set2 = makeSet(intervals: [makeInterval(), makeInterval()], reps: 3)
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
        let set = makeSet(intervals: [makeInterval()], reps: 1)
        let phases = TimerEngine.buildPhases(from: makeRoutine(sets: [set]))
        #expect(phases[0].detail == "Rep 1/1  ·  Set 1/1")
    }

    @Test("detail string — rep counter increments correctly")
    func detailRepCounter() {
        let set = makeSet(intervals: [makeInterval()], reps: 3)
        let phases = TimerEngine.buildPhases(from: makeRoutine(sets: [set]))
        #expect(phases[0].detail == "Rep 1/3  ·  Set 1/1")
        #expect(phases[1].detail == "Rep 2/3  ·  Set 1/1")
        #expect(phases[2].detail == "Rep 3/3  ·  Set 1/1")
    }

    @Test("detail string — set counter increments correctly")
    func detailSetCounter() {
        let set1 = makeSet(intervals: [makeInterval()], reps: 1)
        let set2 = makeSet(intervals: [makeInterval()], reps: 1)
        let phases = TimerEngine.buildPhases(from: makeRoutine(sets: [set1, set2]))
        #expect(phases[0].detail == "Rep 1/1  ·  Set 1/2")
        #expect(phases[1].detail == "Rep 1/1  ·  Set 2/2")
    }

    @Test("detail string — multiple intervals keep same rep within a rep")
    func detailMultipleIntervalsPerRep() {
        let set = makeSet(intervals: [makeInterval(name: "Work"), makeInterval(name: "Rest")], reps: 2)
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

    @Test("zero reps treated as one rep")
    func zeroRepetitionsClampedToOne() {
        let set = makeSet(intervals: [makeInterval()], reps: 0)
        let phases = TimerEngine.buildPhases(from: makeRoutine(sets: [set]))
        #expect(phases.count == 1)
    }

    @Test("phase order: intervals within a rep are in order")
    func phaseOrderWithinRep() {
        let work = makeInterval(name: "Work", duration: 40)
        let rest = makeInterval(name: "Rest", duration: 20)
        let set = makeSet(intervals: [work, rest], reps: 1)
        let phases = TimerEngine.buildPhases(from: makeRoutine(sets: [set]))
        #expect(phases[0].label == "Work")
        #expect(phases[1].label == "Rest")
    }
}
