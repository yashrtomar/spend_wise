<div align="start">
  <!-- PLACEHOLDER: App Logo (e.g.,  -->
  <img src="assets/coins.png" width="120" />
  <!-- ) -->
  <h1>SpendWise</h1>
  <p>A beautiful, offline-first personal finance tracker built with Flutter and Supabase.</p>
</div>

<!-- PLACEHOLDER: Hero Image / App Demo GIF (Highly recommended for resumes!) -->
<!-- e.g. <img src="docs/demo.gif" width="100%" /> -->

## Overview

SpendWise is a modern personal finance application designed to help users track their expenses effortlessly. Built with a focus on performance and reliability, it features a robust **offline-first architecture** ensuring the app remains fully functional without an internet connection. Data is securely stored locally and synced seamlessly to the cloud in the background once connectivity is restored.

## Features

- **Offline-First Architecture:** Add, edit, or delete expenses with zero network latency. Local changes are securely queued in an on-device SQLite database and synchronized to the cloud when online.
- **Real-Time Cloud Sync:** Powered by Supabase to keep your data safely backed up and consistent.
- **Intuitive Expense Tracking:** Quickly categorize, filter, and monitor daily transactions.
- **Beautiful UI/UX:** A clean, responsive interface featuring skeleton loading states and fluid animations for maximum user engagement.
- **Robust State Management:** Utilizes Riverpod for predictable, scalable, and testable state management.

## Tech Stack

- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **Backend/BaaS:** [Supabase](https://supabase.com/) (PostgreSQL, Auth)
- **Local Storage:** [sqflite](https://pub.dev/packages/sqflite) (SQLite)
- **State Management:** [Riverpod](https://riverpod.dev/)

## Screenshots

| Dark Mode | Light Mode |
|:---:|:---:|

| **Home Screen** <br> <img width="200" alt="Home screen in dark mode" src="https://github.com/user-attachments/assets/ec7d6c17-c08a-48e0-b02e-4fb38ee16181" /> | 
**Home Screen ** <br> <img width="200" alt="Home screen in light mode" src="https://github.com/user-attachments/assets/bfb79528-be1a-4887-92df-13c829697017" /> |
| **Add Expense** <img width="200" alt="Add expense bottom sheet in dark mode" src="https://github.com/user-attachments/assets/dde9d1ba-f12a-445b-b944-c35d9f134f7e" /> | 
**Add Expense** <br> <img width="200" alt="Add expense bottom sheet in light mode" src="https://github.com/user-attachments/assets/8f2002c7-9b15-4b9e-a9db-aaef5242b178" /> |
| **Profile Screen** <br> <img width="200" alt="Profile and settings screen in dark mode" src="https://github.com/user-attachments/assets/6c2e8db3-696e-4730-9d0e-3fbf57d67c35" /> | 
**Profile Screen** <br> <img width="200" alt="Profile and settings screen in dark mode" src="https://github.com/user-attachments/assets/849d2d45-40c6-449e-bd51-90abc36300d8" /> |
| **Login Screen** <br> <img width="200" alt="login screen in dark mode" src="https://github.com/user-attachments/assets/6f82103c-d83d-4fd6-8b09-574816914f4a" /> | 
**Login Screen** <br> <img width="200" alt="login screen in light mode" src="https://github.com/user-attachments/assets/af62f35c-bb17-4523-a9b4-dfb80cc379b0" /> |

## Architecture

SpendWise follows a Clean Architecture approach to separate concerns and improve maintainability:
- **Presentation Layer:** Riverpod providers, UI widgets, and screens.
- **Domain Layer:** Business logic, Entities and Repository interfaces.
- **Data Layer:** 
  - `ExpenseLocalDataSource` (SQLite) acts as the single source of truth for the UI to guarantee instant load times.
  - `ExpenseRemoteDataSource` (Supabase) handles cloud synchronization.
  - `SyncService` manages background reconciliation of pending inserts, updates, and deletes.

## Getting Started

### Prerequisites
- Flutter SDK
- A Supabase Project

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/spend_wise.git
   cd spend_wise
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Set up your Supabase credentials by adding your URL and Anon Key to the main configuration.
4. Run the app:
   ```bash
   flutter run
   ```

<!-- PLACEHOLDER: Video Demo -->
<!-- ## Video Walkthrough -->

<!-- Link to a YouTube video, LinkedIn post, or embed a short MP4 here -->
<!-- e.g., [Watch the Demo on YouTube](https://youtube.com/link) -->

<!-- ## License -->

<!-- This project is licensed under the MIT License. -->
