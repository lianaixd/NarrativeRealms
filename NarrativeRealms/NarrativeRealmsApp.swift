//
//  NarrativeRealmsApp.swift
//  NarrativeRealms
//
//  Created by Liana O'Cleirigh on 02/06/2024.
//

import SwiftUI

@main
struct NarrativeRealmsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
