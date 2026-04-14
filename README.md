# PharmaPOS 💊 - Professional SaaS Smart Pharmacy POS

PharmaPOS is a robust, production-ready, SaaS-enabled Pharmacy Point of Sale (POS) system built with **Flutter** and **Dart Frog**. Designed with an **Offline-First** approach, it ensures that your pharmacy operations never stop, even without an internet connection.

<p align="center">
  <img src="assets/images/pharmapos_logo.png" alt="PharmaPOS Logo" width="200"/>
</p>

## 🚀 Key Features

- **Offline-First Architecture**: Sales and inventory updates are performed locally first using **Drift (SQLite)** and synced to the cloud in the background.
- **Smart Inventory Management**: Real-time stock deduction, low-stock warnings (visual alerts), and instant search by Medicine or Generic name.
- **SaaS Ready**: Built with multi-tenant isolation and centralized API management.
- **Robust Networking**: Centralized `ApiClient` with automated base URL switching (Emulator vs Localhost) and comprehensive error handling.
- **Professional UI/UX**: Clean, desktop-friendly layout with **Motion Toast** notifications and Google Fonts.
- **Atomicity**: Backend PostgreSQL transactions ensure stock integrity during sales sync.

## 🛠 Tech Stack

### Frontend (Mobile/Desktop)
- **Framework**: [Flutter](https://flutter.dev)
- **State Management**: [Bloc/Cubit](https://pub.dev/packages/flutter_bloc)
- **Local Database**: [Drift (Moor)](https://drift.simonbinder.eu/)
- **Dependency Injection**: [Get_it](https://pub.dev/packages/get_it)
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router)
- **Networking**: [Dio](https://pub.dev/packages/dio)

### Backend
- **Framework**: [Dart Frog](https://dartfrog.vgv.dev/) (Fast & Minimalist API)
- **Database**: [PostgreSQL](https://www.postgresql.org/)
- **Logging**: Categorized color-coded console logging for easier debugging.

## 🏗 Architecture: Clean Architecture (Feature-First)

PharmaPOS follows a strict **Clean Architecture** pattern divided into three layers:
1. **Data Layer**: Repositories, Data Sources (Remote/Local), and Models (DTOs).
2. **Domain Layer**: Entities, Repositories (Interfaces), and Use Cases.
3. **Presentation Layer**: UI Components, BLoC/Cubit, and State Management.

## 🔄 Sync Mechanism (Offline-First)

1. **Local Transaction**: Sale is saved to Drift DB -> Stock is deducted immediately in the local database.
2. **UI Feedback**: Success toast is shown; Inventory UI refreshes instantly from the local source.
3. **Background Sync**: The app attempts to push the sale to the PostgreSQL server.
4. **Finalization**: Upon server success, the local record is marked as `isSynced: true`.

## 📦 Installation & Setup

### Prerequisites
- Flutter SDK (Latest Stable)
- PostgreSQL Database
- Dart Frog CLI

### Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/PharmaPOS.git
   cd PharmaPOS
   ```

2. **Frontend Setup:**
   ```bash
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   flutter run
   ```

3. **Backend Setup:**
   ```bash
   cd server
   dart frog dev
   ```

## 📱 Screenshots (To be updated)
| POS Grid | Billing Cart |
| :---: | :---: |
| ![POS Grid View](https://via.placeholder.com/300x600?text=POS+Grid) | ![Billing Cart](https://via.placeholder.com/300x600?text=Billing+Cart) |

## 🛡 License
Distributed under the MIT License. See `LICENSE` for more information.

---
*Built with ❤️ for modern pharmacies by [ABiR](https://github.com/nsabir0)*
