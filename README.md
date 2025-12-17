# Sakina App

Sakina is a Flutter-based Islamic application designed to provide users with a variety of features, including prayer times, Quranic verses, Azkar, Hadith, and more. The app is structured to ensure modularity, scalability, and ease of use.

## Technologies Used

- **State Management**: `flutter_bloc` for managing application state.
- **Data Storage**: `shared_preferences` for local storage, wrapped in a custom `LocalStorageService`.
- **Flutter Packages**:
  - `flutter_local_notifications`: For managing notifications.
  - `google_fonts`: For custom fonts.
  - `introduction_screen`: For onboarding screens.
  - `timezone`: For handling time zones.
  - `geolocator`: For location-based features like Qibla direction.
  - `flutter_background_service`: For running background tasks like Azan notifications.
- **Dependency Injection**: `get_it` for modular and testable code.
- **Networking**: `http` package for API calls.
- **UI/UX Enhancements**: `carousel_slider` and `smooth_page_indicator` for interactive UI components.

## Features

### 1. **Prayer Times**
- Displays prayer times for the day.
- Includes an Azan background service for notifications.
- Managed through the `prayer_times` feature.

### 2. **Quran**
- Displays Quranic surahs and verses.
- Includes a detailed view for each surah.
- Managed through the `quran` feature.

### 3. **Azkar**
- Morning and evening Azkar.
- Azkar for specific occasions like after prayer and before sleep.
- JSON files are used to store Azkar data.

### 4. **Hadith**
- Displays a collection of Hadith.
- Detailed view for each Hadith.
- Managed through the `hadeth_details_screen`.

### 5. **Qibla Direction**
- Provides Qibla direction for prayers.
- Managed through the `qibla` feature.

### 6. **Onboarding**
- Introduction screens to guide new users.
- Managed through the `introduction_screen`.

### 7. **Localization**
- Supports multiple languages.
- Managed through the `l10n` directory.

## Project Structure

### `lib/`
- **`main.dart`**: Entry point of the application. Initializes services, DI, and determines the initial route.
- **`home_screen.dart`**: Main screen with tabs for different features.
- **`introduction_screen.dart`**: Onboarding screen for new users.
- **`sura_details_screen.dart`**: Displays details of a selected surah.
- **`hadeth_details_screen.dart`**: Displays details of a selected Hadith.

### `assets/`
- **`audio/`**: Contains audio files for Azkar.
- **`azkar/`**: JSON files for Azkar data.
- **`data/`**: JSON files for daily duas, Hadith, and Islamic events.
- **`fonts/`**: Custom fonts used in the app.
- **`images/`**: Images for the UI.
- **`pray/`**: Prayer-related assets.
- **`quran/`**: JSON files for Quranic surahs.

### `features/`
- **`prayer_times/`**: Handles prayer time calculations and Azan notifications.
- **`quran/`**: Manages Quranic features.
- **`azkar/`**: Manages Azkar features.
- **`qibla/`**: Handles Qibla direction.

### `core/`
- **`di/`**: Dependency injection setup.
- **`services/`**: Core services like local storage.

## How to Run

1. Clone the repository:
   ```bash
   git clone <repository-url>
   ```
2. Navigate to the project directory:
   ```bash
   cd sakina2
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Future Enhancements

- Add more languages for localization.
- Include additional Azkar and Hadith collections.
- Enhance the UI/UX for better user experience.

---

### CV Summary

- **Idea**: Developed an Islamic app providing prayer times, Quranic verses, Azkar, and Hadith with a user-friendly interface.
- **Technologies**: Flutter, Dart, flutter_bloc, shared_preferences, flutter_local_notifications, and get_it for dependency injection.
