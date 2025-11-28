# APU The Manager

A Flutter application to manage Google File Search Stores.

## Features

- List File Search Stores
- Create a new Store
- Delete a Store
- List Documents in a Store
- Upload a Document to a Store
- Delete a Document from a Store

## Architecture

This project follows **Clean Architecture** principles and uses **Riverpod** for state management.

- **Domain Layer**: Entities, Repository Interfaces, Use Cases (implied via Repository usage in Providers for simplicity in this MVP).
- **Data Layer**: Models, Data Sources (API Client), Repository Implementations.
- **Presentation Layer**: Riverpod Providers, Screens, Widgets.

## Setup

1.  **Clone the repository.**
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Configure API Key:**
    - Create a `.env` file in the root directory.
    - Add your Google API Key:
      ```
      GEMINI_API_KEY=your_api_key_here
      ```
4.  **Run the app:**
    ```bash
    flutter run
    ```

## Testing

Run unit tests:
```bash
flutter test
```

## Extending the Project

- **Add new features**: Add new methods to `FileSearchRepository` and `FileSearchRemoteDataSource`.
- **State Management**: Create new providers in `lib/presentation/providers`.
- **UI**: Add new screens in `lib/presentation/screens`.

