import SwiftUI

let OG_TZ = "MDT"

// Clap event times in the format yyyy-MM-dd HH:mm:ss
var Dates = [
    "2025-03-22 15:00:00",
    "2025-03-28 06:00:00",
    "2025-04-01 11:15:00",
    "2025-04-02 04:07:30",
    "2025-04-02 12:33:45",
    "2025-04-02 16:46:52",
    "2025-04-02 18:53:26",
    "2025-04-02 19:56:43",
    "2025-04-02 20:28:21",
    "2025-04-02 20:44:10",
    "2025-04-02 20:52:05",
    "2025-04-02 20:56:02",
    "2025-04-02 20:58:01",
    "2025-04-02 20:59:00",
    "2025-04-02 20:59:30",
    "2025-04-02 20:59:45",
    "2025-04-02 20:59:52",
    "2025-04-02 20:59:56",
    "2025-04-02 20:59:58",
    "2025-04-02 20:59:59",
    "2025-04-02 20:59:59",
]

var debugDateAdded = false

var ClapEventData: [Date] {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.timeZone = TimeZone(identifier: OG_TZ)
    let now = Date()
    
    #if DEBUG
        if !debugDateAdded {
            let fiveMinutesFromNow = now.addingTimeInterval(5 * 60)
            Dates.insert(dateFormatter.string(from: fiveMinutesFromNow), at: 0)
            debugDateAdded = true
        }
    #endif
  
    return Dates.compactMap { dateString in
        guard let date = dateFormatter.date(from: dateString) else {
            return nil
        }
        
        // Only include dates that are in the future
        return date > now ? date : nil
    }
}
