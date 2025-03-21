import SwiftUI

struct DateTimeCard: View {
    let date: Date
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                Text(formattedDate)
                    .font(.headline)
            }
            
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.blue)
                Text(formattedTime)
                    .font(.subheadline)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(cardBackgroundColor)
                .shadow(color: shadowColor, radius: 5, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: 0.5)
                )
        )
    }
    
    // Dynamic card background color based on color scheme
    private var cardBackgroundColor: Color {
        colorScheme == .dark ? 
            Color(.systemGray6) : // Slightly lighter in dark mode
            Color(.systemBackground)
    }
    
    // Dynamic shadow color based on color scheme
    private var shadowColor: Color {
        colorScheme == .dark ?
            Color.black.opacity(0.3) :
            Color.black.opacity(0.2)
    }
    
    // Subtle border color for better definition in dark mode
    private var borderColor: Color {
        colorScheme == .dark ?
            Color.gray.opacity(0.3) :
            Color.clear
    }
    
    // Format date to show day and month in local timezone
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        // No need to set timeZone - will use system default
        return formatter.string(from: date)
    }
    
    // Format time with the user's local timezone abbreviation
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm:ss a"
        formatter.timeZone = TimeZone.current
        
        let timeString = formatter.string(from: date)
        let timezoneAbbr = TimeZone.current.abbreviation() ?? TimeZone.current.identifier
        
        return "\(timeString) (\(timezoneAbbr))"
    }
}

#Preview {
    VStack {
        DateTimeCard(date: Date())
        DateTimeCard(date: Date().addingTimeInterval(86400))
    }
    .padding()
}

#Preview {
    VStack {
        DateTimeCard(date: Date())
        DateTimeCard(date: Date().addingTimeInterval(86400))
    }
    .padding()
    .preferredColorScheme(.dark)
} 

#Preview {
    HStack {
        DateTimeCard(date: Date())
        DateTimeCard(date: Date().addingTimeInterval(86400))
    }
}




// Guides and Surveys Preview
#Preview {
    
    
}

