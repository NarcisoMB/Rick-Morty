# Rick & Morty iOS App

An iOS application built with SwiftUI that consumes the [Rick and Morty API](https://rickandmortyapi.com) to browse characters, manage favorites, track watched episodes, and visualize characters on an interactive world map.

---

## Requirements

| Tool | Version |
|---|---|
| Xcode | 26+ |
| iOS Deployment Target | 26.5+ |
| Swift | 5.0 |
| Device / Simulator | iPhone (portrait) |

No third-party dependencies — the project uses only Apple frameworks.

---

## How to Run

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/rick-and-morty.git
   cd "rick-and-morty"
   ```

2. Open the project in Xcode:
   ```bash
   open "R&M.xcodeproj"
   ```

3. Select a simulator or physical device (iPhone, iOS 26.5+).

4. Build and run with `Cmd + R`.

> **Note:** The app fetches data from `https://rickandmortyapi.com`. No API key is required.  
> **Face ID** requires a physical device; the simulator uses a passcode fallback.

---

## Architecture

The project follows **Clean Architecture** with three layers:

```
Domain      — Entities, repository protocols, use cases (pure Swift, no frameworks)
Data        — DTOs, repository implementations, CoreData persistence, network client
Presentation — SwiftUI views, ViewModels (@Observable), shared components
```

### Dependency Flow

```
Presentation → Domain ← Data
```

ViewModels depend only on use cases. Use cases depend only on repository protocols. Concrete implementations live in the Data layer.

### State Management

- **`@Observable`** macro (iOS 17+) for all ViewModels and managers
- **`@Environment`** injection for shared singletons (no global state in views)
- **`@State`** for local view state

---

## Project Structure

```
R&M/
├── Core/
│   ├── Biometrics/       BiometricAuthManager — Face ID / Touch ID
│   ├── Cache/            ImageCache — two-level memory + disk cache
│   ├── Characters/       CharacterStore — shared reactive character store
│   ├── Episodes/         WatchedEpisodesManager — UserDefaults persistence
│   ├── Favorites/        FavoritesManager — UserDefaults persistence
│   ├── Localization/     LanguageManager, LocalizationKeys
│   ├── Map/              MapNavigationManager, LocationManager
│   ├── Network/          HTTPClient, Endpoint, NetworkError, NetworkLogger
│   ├── Theme/            Color+Theme (rmBackground, rmCard, etc.)
│   └── Toast/            ToastManager — UIKit UIWindow overlay
│
├── Data/
│   ├── DTOs/             CharacterResponseDTO, EpisodeDTO
│   ├── Persistence/      CoreData stack, CharacterEntity, CharacterLocalDataSource
│   └── Repositories/     CharacterRepository (network + cache)
│
├── Domain/
│   ├── Entities/         Character, Episode, CharacterPage
│   ├── Repositories/     CharacterRepositoryProtocol
│   └── UseCases/         GetCharactersUseCase
│
└── Presentation/
    ├── Characters/        CharacterListView, CharacterListViewModel, CharacterDetailView
    ├── Components/        CharacterRow, EpisodeGridView, EpisodeListView,
    │                      CachedAsyncImage, SearchFilterHeader, GIFImageView, ToastView
    ├── Favorites/         FavoritesView
    ├── Map/               CharacterMapView, CharacterMapViewModel,
    │                      CharacterListSheet, CharacterAnnotation
    ├── Settings/          SettingsView, SettingsViewModel
    └── Splash/            SplashView
```

---

## Features

### Splash Screen
- Portal GIF animation plays on launch for 2.5 seconds
- Tab content loads in the background during splash to avoid lag on first interaction

### Characters Tab
- Paginated list from the Rick and Morty API with infinite scroll
- Pull-to-refresh forces a network fetch and overwrites the cache
- **Cache-first**: subsequent app launches load from CoreData; network is only hit on pull-to-refresh
- Search by name, status, or species
- Filter chips for status and species
- Character count badge per page

### Character Detail
- Bottom sheet with dynamic height (adapts to content)
- Status badge, species, gender, origin, location
- Favorite toggle (heart icon) — add is instant, remove requires Face ID
- Map pin button — dismisses detail and centers the map on that character's location (hidden when opened from the map)
- **Episode Grid** — calendar-style grid showing which episodes the character appears in, grouped by season (S1–S7). Cell colors:
  - Blue — character appears in this episode
  - Green — episode marked as watched
  - Diagonal split — both (appears + watched)
  - Dark — neither
- **Episode List** — collapsible list showing episode code (S01E03) and name, fetched from the API on expand

### Favorites Tab
- Persisted across sessions via `UserDefaults`
- **Face ID / Touch ID required** to unlock the tab on every visit
- Auth is cancelled and the tab re-locks when navigating away
- Search and filter work the same as the characters tab

### Map Tab
- Interactive world map (MapKit) with all loaded characters as pins
- Each pin shows the character's image in a circle with a status-colored border and a pointed tip
- Locations are **deterministic** per character ID (Wang hash — no visible sequential pattern)
- **New characters appear in real time** as you scroll the Characters list — both tabs share `CharacterStore`
- Tap a pin → centers map + opens character detail sheet
- **Find My-style bottom panel**:
  - Shows all loaded characters with avatar, location name, and species
  - Drag the handle up → expand to full list
  - Drag the handle down (collapsed) → minimize to a floating pill
  - Tap the pill → restore the panel
  - The panel follows the finger live during drag (spring animation on release)
  - Tap a row → centers map on that character
- **User location button** (top right):
  - Requests `NSLocationWhenInUseUsageDescription` permission on first tap
  - Centers map on user's location when authorized
  - Icon reflects authorization state (`location`, `location.fill`, `location.slash`)

### Toast Notifications
- Appear above all content including sheets, via a `UIWindow` at `windowLevel .alert + 1`
- Triggered for: add favorite, remove favorite, mark episode watched, unmark episode watched
- Auto-dismiss after 2.5 seconds with fade animation

### Localization
- Full **English / Spanish** support via `.xcstrings`
- Language can be toggled in real time from the toolbar in Characters and Favorites tabs
- All UI strings go through `LanguageManager` + `LocalizationKeys` (no raw string literals in views)

---

## Key Technical Decisions

| Decision | Reason |
|---|---|
| `@Observable` instead of `ObservableObject` | Finer-grained observation, no `@Published` boilerplate, iOS 17+ target |
| Programmatic CoreData model | Avoids `.xcdatamodeld` merge conflicts; schema reset on migration failure (dev-mode safety net) |
| UIKit `UIWindow` for toasts | SwiftUI `.overlay` renders below system sheet presentations; UIKit window level bypasses this |
| Wang hash for map coordinates | Deterministic, full avalanche — sequential IDs produce visually random scatter |
| `CharacterStore` singleton | Single source of truth shared between Characters and Map tabs; avoids duplicate network requests |
| Cancellable biometric `Task` | `LAContext.evaluatePolicy` can't be cancelled mid-flight; storing the task and checking `Task.isCancelled` after await prevents stale unlock on tab switch |
| `DragGesture` on panel handle only | Limits gesture conflict with `ScrollView` inside the panel |

---

## API

This app uses the public [Rick and Morty API](https://rickandmortyapi.com/documentation) — no authentication required.

**Endpoints used:**
- `GET /api/character?page={n}` — paginated character list
- `GET /api/episode/{id,id,...}` — single or batch episode details

---

## License

This project is for educational purposes. Character data and images belong to [rickandmortyapi.com](https://rickandmortyapi.com).
