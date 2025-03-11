<img src="./assets/icon.png" width="100" height="100" style="margin-right: 10px;" alt="Clapster App Icon" align="left"/>

# Clapster: The World's Longest Slow Clap

Clapster is an iOS app for participating in "The World's Longest Slow Clap" - a global movement that started on April 1st, 2021, when a small group of friends decided to create the most drawn-out slow clap in history, with intervals halving over time to eventually converge on a grand finale.

[![Swift Version](https://img.shields.io/badge/Swift-5.5-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Features

- **Event Tracking**: View all upcoming clap events with exact dates and times
- **Precise Countdown**: Watch the days, hours, minutes, and seconds count down to the next clap
- **Automatic Notifications**: Get reminders at 15 minutes, 1 hour, and 1 day before each event
- **Global Time Conversion**: All events are shown in your local time zone
- **Interactive Clapping**: Enjoy confetti animations when a clap event occurs
- **Deep Linking**: Tap on notifications to navigate directly to the clap screen

## Installation

### Requirements
- iOS 15.0 or later
- Xcode 13.0 or later
- Swift 5.5 or later

### Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/Cavallando/Clapster.git
   cd Clapster
   ```

2. Open the project in Xcode:
   ```bash
   open Clapster.xcodeproj
   ```

3. Install dependencies via Swift Package Manager:
   - ConfettiSwiftUI

4. Build and run the application on your device or simulator

## How It Works

Clapster coordinates global clapping events that follow a specific pattern. What began as a 2-year break between claps gradually accelerates, with each interval halving:

- First clap: April 1, 2021
- Second clap: April 1, 2023 (2 years later)
- Third clap: April 1, 2024 (1 year later)
- Fourth clap: October 1, 2024 (6 months later)
- Fifth clap: January 1, 2025 (3 months later)
- ... and so on

The finale on April 2nd, 2025, will feature the most precisely timed sequence of claps ever coordinated - with the final seconds counting down in a rhythmic crescendo.

## Architecture

The app is built using SwiftUI and follows a tab-based navigation structure:
- **Home Tab**: Displays all upcoming events
- **Clap Tab**: Shows countdown to the next event
- **About Tab**: Provides information about the project

Core features:
- UserNotifications framework for scheduling reminders
- Combine for reactive timer updates
- Environment objects for shared state management

## Contributing

Contributions are welcome! If you'd like to contribute:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Contact

Project Link: [https://github.com/yourusername/clapster](https://github.com/yourusername/clapster)

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

Join us in creating a moment of global unity through the simple act of applause!
