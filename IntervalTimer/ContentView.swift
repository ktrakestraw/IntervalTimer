//
//  ContentView.swift
//  IntervalTimer
//
//  Created by Kevin Rakestraw on 3/14/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = WorkoutStore()

    var body: some View {
        WorkoutListView()
            .environmentObject(store)
    }
}

#Preview {
    ContentView()
}
