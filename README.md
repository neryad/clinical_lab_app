# Clinical Lab App

## Description
This is a new Flutter project designed to manage various aspects of a clinical laboratory. The application is structured into several key feature modules, providing a comprehensive solution for clinical lab operations.

## Features
The application includes the following modules, indicating its capabilities:
- **Admin:** Administrative functionalities.
- **Auth:** User authentication and authorization.
- **Branches:** Management of different lab branches.
- **Home:** The main dashboard or landing page.
- **Profile:** User profile management.
- **Quotes:** Handling of quotes for services.
- **Results:** Management and viewing of lab test results.
- **Tests:** Definition and management of lab tests.
- **Users:** User management within the system.

## Technologies Used
This project leverages the following key technologies and packages:
- **Flutter:** UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.
- **Supabase:** Backend-as-a-Service for real-time databases, authentication, and more.
- **Flutter Riverpod:** A reactive caching and data-binding framework.
- **GoRouter:** A declarative routing package for Flutter.
- **Google Fonts:** Integrates Google Fonts into Flutter apps.
- **url_launcher:** Flutter plugin for launching URLs.
- **intl:** Internationalization and localization for Dart.
- **pdf:** A library for creating, reading, and updating PDF files.
- **printing:** Flutter plugin for printing documents.

## Getting Started

### Prerequisites
- Flutter SDK installed.
- A Supabase project set up (details on connection to be added).

### Installation
1. Clone the repository:
   ```bash
   git clone [repository_url]
   cd clinical_lab_app
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```

### Running the App
```bash
flutter run
```

## Project Structure
The project follows a modular structure:
- `lib/core`: Contains core functionalities like constants, models, routing, and theme.
- `lib/features`: Houses distinct feature modules (e.g., `auth`, `admin`, `results`).
- `lib/main.dart`: The entry point of the application.

## Contributing
(To be added later - e.g., guidelines for contributions)

## License
[MIT License](LICENSE)