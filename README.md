# Serat

<p align="center">
  <img src="assets/logo.png" alt="Serat Logo" width="150"/>
</p>

<p align="center">
  <strong>A comprehensive Islamic app designed to assist Muslims in their daily worship and spiritual journey.</strong>
  <br />
  <br />
  <img src="https://img.shields.io/github/license/hamdyhaggag/serat?style=for-the-badge" alt="License">
  <img src="https://img.shields.io/badge/version-v1.0.0-blue?style=for-the-badge" alt="Version">
  <img src="https://img.shields.io/badge/platform-Flutter-blue?style=for-the-badge" alt="Platform">
</p>

---

## 📸 Screenshots

| Home | Prayer Times | Quran |
| :---: | :---: | :---: |
| <img src="assets/screenshots/1.png" alt="Screenshot 1" width="250"/> | <img src="assets/screenshots/2.png" alt="Screenshot 2" width="250"/> | <img src="assets/screenshots/3.png" alt="Screenshot 3" width="250"/> |

| Hadith | Azkar | Sebha |
| :---: | :---: | :---: |
| <img src="assets/screenshots/4.png" alt="Screenshot 4" width="250"/> | <img src="assets="assets/screenshots/5.png" alt="Screenshot 5" width="250"/> | <img src="assets/screenshots/6.png" alt="Screenshot 6" width="250"/> |

## ✨ Features

- Prayer Times & Qibla Direction
- Full Quran with Tafsir
- Morning & Evening Azkar (Supplications)
- Hadith Collection (Al-Nawawi's Forty Hadith)
- Digital Tasbih (Sebha)
- Islamic Radio & Quran Videos
- Hijri Calendar & Zakat Calculator
- Daily Goal Tracking
- Customizable Notifications
- Light & Dark Mode Support
- Arabic Language Support

## 🛠 Tech Stack

- **Framework**: Flutter
- **State Management**: BLoC
- **Dependency Injection**: GetIt & Injectable
- **Networking**: Dio
- **Local Storage**: Shared Preferences & Secure Storage
- **Audio/Video**: `just_audio`, `audio_service`, `video_player`
- **Location**: Geolocator & Flutter Compass
- **Notifications**: Flutter Local Notifications
- **Database**: (Likely using local JSON files)

## ⚙️ Development Requirements

- Flutter SDK >= 3.2.3
- Dart SDK >= 3.0.0
- Android Studio / VS Code
- Git

## 🚀 Getting Started

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/hamdyhaggag/serat.git
    cd serat
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Set up YouTube API Key:**
    - Obtain an API key from [Google Cloud Console](https://console.cloud.google.com).
    - Enable the "YouTube Data API v3" for your project.
    - Add the key to your environment variables. Replace `your_api_key_here` with your actual key:

    ```bash
    # For Linux/macOS
    export YOUTUBE_API_KEY=your_api_key_here

    # For Windows (PowerShell)
    $env:YOUTUBE_API_KEY="your_api_key_here"
    ```

4.  **Run the app:**
    ```bash
    flutter run
    ```

## 🔒 Security and Privacy

- All user data is stored locally on the user's device.
- No personal data is collected by the application.
- HTTPS is utilized for all network communications to ensure data security.
- Users have the ability to delete their data at any time.

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1.  Fork the project.
2.  Create a new feature branch (`git checkout -b feature/AmazingFeature`).
3.  Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4.  Push to the branch (`git push origin feature/AmazingFeature`).
5.  Open a Pull Request.

## 📄 License

This project is licensed under the MIT License. See the `LICENSE` file for details.
*(Note: If you don't have a `LICENSE` file in your project, you should add one to match this section.)*

## 📧 Contact

- Email: arabianatech@gmail.com
- App Page: [Google Play Store](https://play.google.com/store/apps/details?id=com.serat.app)