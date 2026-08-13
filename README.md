# OpenCode Usage Monitor

A native macOS Menu Bar application built with SwiftUI to easily monitor your Opencode Go subscription usage (Rolling, Weekly, and Monthly limits).

![App Screenshot](assets/screenshot.png) <!-- Add your app screenshot here in the 'assets' folder -->

## Features

- **Real-Time Monitoring**: View your Rolling, Weekly, and Monthly usage directly from the menu bar.
- **Smart Progress Bars**: Progress bar colors dynamically change based on usage levels (Green for safe, Yellow for medium, Red for critical).
- **Auto-Refresh**: Automatically fetches new data every 5 minutes, or you can manually refresh.
- **Lightweight**: Runs as a background agent (`LSUIElement`) with no dock icon clutter.
- **Terminal-Driven**: No Xcode GUI required. Generated and built entirely via `xcodegen` and `make`.

## Prerequisites

- macOS with Command Line Tools / Xcode installed.
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (can be installed via Homebrew: `brew install xcodegen`).

## Installation & Setup

1. **Clone the repository** (or navigate to the project directory):
   ```bash
   cd opencode-usage
   ```

2. **Generate the Xcode project and build**:
   ```bash
   make build
   ```

3. **Run the app**:
   ```bash
   make run
   ```
   *(Note: The app will appear in your macOS Menu Bar. It does not have a dock icon).*

## Configuration: How to Get Your API Key

The app uses the official OpenCode API (`https://opencode.ai/zen/go/v1/usage`) to fetch your usage. You only need your OpenCode API key.

1. Open your opencode console.
2. Go to **Settings** → **API Keys**.
3. Copy your API key (starts with `sk-...`).
4. Open the **OpenCode Usage Monitor** from your Mac menu bar.
5. Click the **Settings (⚙️)** icon in the top right corner of the header.
6. Paste your API key into the text field and click **Save**.

The app will automatically fetch your usage every 5 minutes.

## Development Commands

A `Makefile` is provided for easy terminal workflows:

- `make setup`: Generates the `.xcodeproj` using XcodeGen.
- `make build`: Builds the application (Debug configuration).
- `make run`: Kills any existing instance and runs the freshly built app.
- `make clean`: Removes the generated `.xcodeproj` and the `build/` directory.
- `make logs`: Streams the unified logs specifically for this app subsystem (`com.wiscaksono.opencode-usage`).

## License

MIT License
