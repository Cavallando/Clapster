//
//  HomeView.swift
//  Clapster
//
//  Created by Michael Cavallaro on 3/11/25.
//

import SwiftUI

struct HomeView: View {
    // Convert strings to dates (interpreting them as MST) and filter out past dates
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    if ClapEventData.isEmpty {
                        ContentUnavailableView(
                            "No Upcoming Events",
                            systemImage: "calendar.badge.exclamationmark",
                            description: Text("All scheduled events have passed.")
                        )
                        .padding(.top, 50)
                    } else {
                        ForEach(ClapEventData.indices, id: \.self) { index in
                            DateTimeCard(date: ClapEventData[index])
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Clap Events")
        }
    }
}


#Preview {
    HomeView()
}
