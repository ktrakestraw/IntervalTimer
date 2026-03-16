//
//  ContentView.swift
//  IntervalTimer
//
//  Created by Kevin Rakestraw on 3/14/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = RoutineStore()

    var body: some View {
        RoutineListView()
            .environmentObject(store)
    }
}

#Preview {
    ContentView()
}
