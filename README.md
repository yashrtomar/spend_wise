<div align="start">
  <!-- PLACEHOLDER: App Logo (e.g.,  -->
  <img src="assets/coins_padded.png" width="120" />
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

<div align="center">
  <!-- Add your screenshots here side-by-side -->
  <img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 Pro - 2026-08-15 at 20 01 13" src="https://github.com/user-attachments/assets/c436e726-37b6-430b-9263-832b87ece090" />
  <img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 Pro - 2026-08-15 at 20 01 36" src="https://github.com/user-attachments/assets/ba9e7f33-a1c9-455a-93a3-afea4aabfde7" />
<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 Pro - 2026-08-15 at 20 02 03" src="https://github.com/user-attachments/assets/33770574-05d8-4fdc-8f41-3aeec6474b95" />
<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 Pro - 2026-08-15 at 20 02 37" src="https://github.com/user-attachments/assets/a4bd5f58-c50d-433c-893d-c4e14e573cc5" />
  <img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 Pro - 2026-08-15 at 20 02 51" src="https://github.com/user-attachments/assets/72500d5b-6b0b-4fee-915b-ee0eb4f923cd" />
<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 Pro - 2026-08-15 at 20 03 04" src="https://github.com/user-attachments/assets/ed065d79-5fba-4332-8fb2-327f16ed3433" />
<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 Pro - 2026-08-15 at 20 03 13" src="https://github.com/user-attachments/assets/dcaf1e45-c0f9-49b3-b4ed-24c8d0449036" />

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
