//
//  ContentView.swift
//  Kira
//
//  Created by Karyna Budi Sanjaya on 15/10/26.
//

import SwiftUI

struct ContentView: View {
    
    @State private var repository = ProfileRepository()
    
    let testProfile = Profile(
      user_id: UUID().uuidString,
      display_name: "Test User",
      timezone: "Asia/Jakarta"
    )

    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            
            Button("Add Profile") {
              Task {
                do {
                  try await repository.insertProfile(testProfile)
                  print("✅ Profile added")
                } catch {
                  print("❌ Error: \(error)")
                }
              }
            }

            
            Button("Give comment") {
              Task {
                print("Hello")
              }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

