<div align="start">
  <!-- PLACEHOLDER: App Logo (e.g.,  -->
  <img src="assets/coins.png" width="120" />
  <!-- ) -->
  <h1>SpendWise</h1>
  <p>A beautiful, offline-first personal finance tracker built with Flutter and Supabase.</p>
</div>

<!-- PLACEHOLDER: Hero Image / App Demo GIF (Highly recommended for resumes!) -->
<!-- e.g. <img src="docs/demo.gif" width="100%" /> -->

## 🚀 Overview

SpendWise is a modern personal finance application designed to help users track their expenses effortlessly. Built with a focus on performance and reliability, it features a robust **offline-first architecture** ensuring the app remains fully functional without an internet connection. Data is securely stored locally and synced seamlessly to the cloud in the background once connectivity is restored.

## ✨ Features

- **Offline-First Architecture:** Add, edit, or delete expenses with zero network latency. Local changes are securely queued in an on-device SQLite database and synchronized to the cloud when online.
- **Real-Time Cloud Sync:** Powered by Supabase to keep your data safely backed up and consistent.
- **Intuitive Expense Tracking:** Quickly categorize, filter, and monitor daily transactions.
- **Beautiful UI/UX:** A clean, responsive interface featuring skeleton loading states and fluid animations for maximum user engagement.
- **Robust State Management:** Utilizes Riverpod for predictable, scalable, and testable state management.

## 🛠️ Tech Stack

- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **Backend/BaaS:** [Supabase](https://supabase.com/) (PostgreSQL, Auth)
- **Local Storage:** [sqflite](https://pub.dev/packages/sqflite) (SQLite)
- **State Management:** [Riverpod](https://riverpod.dev/)

<!-- PLACEHOLDER: Screenshots Section -->
## 📱 Screenshots

<div>
  <!-- Add your screenshots here side-by-side -->

  <!-- <img src="docs/screenshot2.png" width="250" hspace="10"/> -->
  <!-- <img src="docs/screenshot3.png" width="250" hspace="10"/> -->
</div>

## 🏗️ Architecture

SpendWise follows a Clean Architecture approach to separate concerns and improve maintainability:
- **Presentation Layer:** Riverpod providers, UI widgets, and screens.
- **Domain Layer:** Business logic, Entities and Repository interfaces.
- **Data Layer:** 
  - `ExpenseLocalDataSource` (SQLite) acts as the single source of truth for the UI to guarantee instant load times.
  - `ExpenseRemoteDataSource` (Supabase) handles cloud synchronization.
  - `SyncService` manages background reconciliation of pending inserts, updates, and deletes.

## 🚀 Getting Started

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
## 🎥 Video Walkthrough

<!-- Link to a YouTube video, LinkedIn post, or embed a short MP4 here -->
<!-- e.g., [Watch the Demo on YouTube](https://youtube.com/link) -->

## 📄 License

This project is licensed under the MIT License.
