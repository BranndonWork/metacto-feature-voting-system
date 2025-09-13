//
//  ContentView.swift
//  FeatureVoting
//
//  Created by Branndon Coelho on 9/13/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authService = AuthService()

    var body: some View {
        MainView()
            .environmentObject(authService)
    }
}

#Preview {
    ContentView()
}