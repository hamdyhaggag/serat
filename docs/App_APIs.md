# Documentation of APIs Used in Serat App

This document provides a comprehensive overview of all external APIs used within the Serat application, including their endpoints, usage, and integration details.

## 1. Prayer Times & Calendar API (Aladhan)

The application uses the **Aladhan API** to fetch accurate prayer times and calendar data based on the user's location.

- **Base URL**: `https://api.aladhan.com/v1/`
- **Implementation**: Managed by `DioHelper` (`lib/Data/utils/dio_helper.dart`).

### Endpoints
#### 1.1. Get Calendar (Monthly Prayer Times)
- **Endpoint**: `GET /calendar/{year}/{month}`
- **Parameters**:
  - `latitude` (double): User's latitude.
  - `longitude` (double): User's longitude.
  - `method` (int): Calculation method ID (e.g., Muslim World League, Umm Al-Qura).
- **Usage**: 
  - Called in `LocationCubit` (`getTimings` method).
  - Fetches prayer times for the entire month to allow for offline scheduling of Adhan notifications.
  - Response is cached locally as `CalendarModel` and `TimesModel` for offline access.

#### 1.2. Get Qibla Direction
- **Endpoint**: `GET /qibla/{latitude}/{longitude}`
- **Parameters**:
  - `latitude` (double): User's latitude.
  - `longitude` (double): User's longitude.
- **Usage**: 
  - Called in `QiblaCubit` (`_syncWithApi` method).
  - Used to verify and correct the locally calculated Qibla direction.
  - Result is cached to improve performance.

---

## 2. MP3Quran API

The application relies heavily on the **MP3Quran API (V3)** for recitations, videos, and radio stations.

- **Base URL**: `https://mp3quran.net/api/v3/` or `https://www.mp3quran.net/api/v3/`

### Endpoints
#### 2.1. Get Reciters
- **Endpoint**: `GET /reciters`
- **Parameters**:
  - `language` (String, optional): Language of the response (e.g., 'ar').
  - `reciter` (int, optional): Specific reciter ID.
  - `rewaya` (int, optional): Specific rewaya ID.
  - `sura` (int, optional): Specific surah ID.
- **Usage**: 
  - Called in `RecitersCubit`.
  - Fetches the list of all available reciters, their available Moshafs (recitation styles), and the server URLs for their audio files.
  - Data is cached via `RecitersCacheService`.

#### 2.2. Get Quran Videos
- **Endpoint**: `GET /videos`
- **Parameters**:
  - `language`: set to `ar`.
- **Usage**: 
  - Called in `QuranVideoWebServices`.
  - display a curated list of Quranic videos.

#### 2.3. Get Radio Stations
- **Endpoint**: `GET /radios`
- **Parameters**:
  - `language`: set to `ar`.
- **Usage**: 
  - Called in `RadioService` (`lib/features/radio/data/radio_service.dart`).
  - Fetches a list of 24/7 Quran radio stations.

### Audio Streaming & Downloading
- **Audio Source**: The audio files are not fetched via a typical REST API endpoint but are streamed/downloaded directly from the **server URLs** provided in the Reciters API response.
- **Format**: `http://{server_url}/{surah_number}.mp3` (e.g., `https://server8.mp3quran.net/ahmad_huth/001.mp3`).
- **Usage**: Handled by `DownloadService` and the audio player.

---

## 3. Hadith API (AlQuran Cloud)

Used to provide random Hadith content.

- **Base URL**: `https://api.alquran.cloud/v1/`

### Endpoints
#### 3.1. Get Random Hadith
- **Endpoint**: `GET /hadith/random`
- **Usage**: 
  - Called in `HadithService` (`getRandomHadiths` method).
  - Fetches a random hadith for display (likely for a "Hadith of the Day" feature).

---

## 4. Local Data & Offline Capabilities

The app prioritizes offline functionality by using local assets and caching API responses.

### 4.1. Local Json Assets
- **Quran Text**: Full Quran text is stored in `assets/data/quran.json` and loaded via `QuranService`.
- **Adhkar**: Adhkar content is stored in `assets/data/adhkar.json` and loaded via `AdhkarService`.
- **Nawawi Hadiths**: The 40 Nawawi Hadiths are stored in `assets/nawawi_hadiths.json` (Used as primary source in `HadithService` before falling back to API or cache).

### 4.2. Caching Mechanisms
- **SharedPreferences**: Used to store:
  - `CalendarModel` (Monthly prayer times).
  - `TimesModel` (Today's prayer times).
  - `ReciterModel` (List of reciters).
  - `RadioStation` list.
  - User preferences (location, settings).
- **File System**:
  - Downloaded Quran audio files are stored in the app's document directory (`quran_downloads/`) via `DownloadService`.
