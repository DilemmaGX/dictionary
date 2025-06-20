# Dictionary Flutter App

A modern Flutter-based dictionary application with theme customization and favorites management, deployed to GitHub Pages.

## Features
- **Word Search**: Look up English word definitions using [Free Dictionary API](https://dictionaryapi.dev)
- **Favorites System**: Save favorite definitions with part-of-speech tracking
- **Theme Customization**:
  - Dark/Light mode toggle
  - 16 accent color options
- **Responsive Design**: Works on mobile and web
- **Offline Storage**: Persists favorites using SharedPreferences

## Installation
1. Clone the repository:
```bash
git clone https://github.com/yourusername/dictionary.git
```
2. Install dependencies:
```bash
flutter pub get
```

## Usage
```bash
# Run in development mode
flutter run -d chrome

# Build for production
flutter build web
```

## API Reference
This app uses the [Free Dictionary API](https://dictionaryapi.dev). Please note:
- Rate limiting: 50 requests/hour
- Only English words supported
- API availability not guaranteed

## Deployment
Automatically deployed to GitHub Pages via GitHub Actions. Ensure:
1. GitHub Pages enabled in repo settings
2. `gh-pages` branch selected
3. GitHub Token with repo permissions
