# VitalSync 🏥

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green.svg?style=for-the-badge)

**The bridge between patient vitality and medical data.**

VitalSync is a modern, full-stack medical application built with Flutter and Firebase. It facilitates seamless booking of medical tests (Home & Lab visits), real-time order tracking, and health profile management using a "Neo-Medical" aesthetic with glassmorphism and smooth animations.

---

## 📸 App Screenshots

| Login & Auth | Home Dashboard | Test Booking |
|:---:|:---:|:---:|
| <img src="assets/screenshots/login.png" width="200" alt="Login Screen"> | <img src="assets/screenshots/home.png" width="200" alt="Home Screen"> | <img src="assets/screenshots/booking.png" width="200" alt="Booking"> |

| Cart & Checkout | Order Tracking | Profile & Settings |
|:---:|:---:|:---:|
| <img src="assets/screenshots/cart.png" width="200" alt="Cart"> | <img src="assets/screenshots/tracking.png" width="200" alt="Tracking"> | <img src="assets/screenshots/profile.png" width="200" alt="Profile"> |

*(Note: Replace `assets/screenshots/...` with your actual image paths)*

---

## ✨ Key Features

* **🔐 Secure Authentication:** Robust Login and Sign-up flow using **Firebase Auth** with persistent user sessions.
* **🧪 Dynamic Test Booking:**
    * Toggle between **Home Visit** and **Lab Visit**.
    * Slot selection logic ensuring availability.
    * Address capture for home collections.
* **🛍️ Smart Cart System:** Add multiple tests or health packages, view discounts, and checkout securely.
* **📦 Health Packages:** Special "Bundles" (e.g., Full Body Checkup, Heart Health) populated via a custom **Data Seeder**.
* **🚚 Real-time Order Tracking:** Visual stepper UI showing order status (Placed → Sample Collected → Processing → Report Ready).
* **🔔 Notification System:** In-app notification center for booking updates.
* **🎨 Neo-Medical UI:** Custom "GlassCard" components, skeleton loading states (`shimmer`), and micro-interactions using `flutter_animate`.

---

## 🛠️ Tech Stack & Architecture

This project follows a clean **Layered Architecture** to ensure scalability and maintainability.

### Core Technologies
* **Frontend:** Flutter (Dart 3.0+)
* **Backend:** Firebase (Firestore Database, Authentication)
* **State Management:** `Provider` (MVVM pattern)
* **Dependency Injection:** `GetIt`
* **Routing:** Standard Flutter Navigation

### Architecture Overview
* **`lib/core`**: Constants, Theme data, DI setup, and Utilities (Result types).
* **`lib/models`**: Data classes (Order, Test, User) with JSON serialization.
* **`lib/repositories`**: The data layer that communicates directly with Firestore.
* **`lib/providers`**: The view-model layer that holds state and business logic.
* **`lib/ui`**: Screens and reusable widgets (`GlassCard`, `VitalAppBar`, `SpeedDialFab`).

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (v3.0.0 or higher)
* Dart SDK
* Android Studio / VS Code

### Installation

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/Muhammad-Bilal-03/campus_event_companion.git](https://github.com/Muhammad-Bilal-03/vital_sync.git)
    cd vital_sync
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Firebase Setup:**
    * Create a project in the [Firebase Console](https://console.firebase.google.com/).
    * Add an Android App with package name: `com.example.fire_base_project`.
    * Download `google-services.json` and place it in `android/app/`.
    * Enable **Authentication** (Email/Password) and **Firestore Database** in the console.

4.  **Run the App:**
    ```bash
    flutter run
    ```

> **Note:** On the first run, the app includes a `DataSeeder` that will automatically populate your Firestore with sample Tests and Packages if the collection is empty.

---

## 📂 Folder Structure


```

lib/
├── core/               # App-wide constants, themes, and utils
├── models/             # Data models (JSON/Firestore serializable)
├── providers/          # State management (ChangeNotifiers)
├── repositories/       # Data fetching logic (Firebase calls)
├── ui/
│   ├── screens/        # Full application screens
│   │   ├── auth/       # Login/Signup
│   │   ├── booking/    # Lab & Home booking logic
│   │   ├── cart/       # Cart management
│   │   ├── checkout/   # Order placement
│   │   ├── home/       # Dashboard & Navigation
│   │   ├── orders/     # Order history & Details
│   │   └── profile/    # User settings
│   └── widgets/        # Reusable UI components (GlassCard, etc.)
└── main.dart           # App entry point

```

---

## 📦 Dependencies

Major packages used in this project:

| Package | Purpose |
| :--- | :--- |
| `provider` | State Management |
| `firebase_core` | Firebase Initialization |
| `cloud_firestore` | Database |
| `firebase_auth` | User Authentication |
| `flutter_animate` | UI Animations |
| `google_nav_bar` | Modern Bottom Navigation |
| `lucide_icons` | Clean Iconography |
| `another_stepper` | Order Tracking UI |
| `shimmer` | Loading Effects |

---

## 🤝 Contributing

Contributions are welcome! Please fork the repository and submit a pull request for any features or bug fixes.

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

**Muhammad Bilal**A

* **Role:** Lead Developer
* **LinkedIn:** [linkedin.com/in/muhammad-bilal-bsse](https://www.linkedin.com/in/muhammad-bilal-bsse/)
* **GitHub:** [github.com/Muhammad-Bilal-03](https://www.google.com/search?q=https://github.com/Muhammad-Bilal-03)
