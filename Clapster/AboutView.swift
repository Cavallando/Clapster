import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                HStack {
                    Image(systemName: "hands.clap.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading) {
                        Text("Clapster")
                            .font(.system(size: 28, weight: .bold))
                        Text("The World's Longest Slow Clap")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 10)
                
                Divider()
                
                Group {
                    Text("Our Story")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("It all started on April 1st, 2021, when a small group of friends said \"Let's clap and then not clap again for 2 years\"")
                    
                    Text("Since that moment, we have been coordinating the world's longest slow clap. Where we halve the interval between each clap eventually converging on a single moment in time for the grand finale.")
                }
                
                // How it works
                Group {
                    Text("How It Works")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 10)
                    
                    Text("The Clapster app coordinates this global event by:")
                        .padding(.bottom, 5)
                    
                    FeatureRow(icon: "calendar", text: "Displaying upcoming clap events in your local time")
                    FeatureRow(icon: "timer", text: "Providing precise countdowns to each clap")
                    FeatureRow(icon: "bell", text: "Automatically sending reminders so you never miss a clap")
                    FeatureRow(icon: "globe", text: "Converting times across global time zones")
                }
                
                // Participation
                Group {
                    Text("Join The Movement")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 10)
                    
                    Text("Whether you're clapping once or following along with every event, you're part of making history. The finale on April 2nd, 2025 will feature the most precisely timed sequence of claps ever coordinated - with the final seconds counting down in a rhythmic crescendo.")
                    
                    Text("Our goal? To have the final clap synchronized with participants from every continent, creating a moment of global unity through the simple act of applause.")
                }
                
                Spacer(minLength: 30)
                
                VStack(alignment: .center) {
                    Text("Version 1.0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("© 2025 The World's Longest Slow Clap")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
        }
        .navigationTitle("About")
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
            
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationView {
        AboutView()
    }
}
