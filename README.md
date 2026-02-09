# 🏥 Medical Lab Management Application

A powerful, cross-platform mobile application built with **Flutter** and **Firebase**, designed to streamline laboratory workflows, patient data management, and real-time medical reporting.

---

## 🚀 Key Features

### 👤 Patient Experience
- **Secure Authentication**: Instant login and registration via Firebase Auth.
- **Health Dashboard**: Quick access to medical history and latest reports.
- **Report Management**: View, download, and upload medical documents (PDF/Images).
- **Profile Management**: Update personal details for accurate record keeping.

### 🛡️ Admin & Lab Personnel
- **Dynamic Dashboard**: Monitor patient activities and laboratory stats.
- **Data Oversight**: Full control over medical records stored in Firestore.
- **Resource Management**: Manage laboratory reports and patient documents.
- **Secure File Storage**: Integrated with Firebase Storage for high-speed document retrieval.

---

## 🛠️ Technical Stack

### **Frontend & Framework**
- 📱 **Flutter**: Cross-platform mobile development (iOS & Android).
- 🎯 **Dart**: The core programming language for the app.
- 📦 **Provider**: Sophisticated state management and dependency injection.

### **Cloud & Backend (Firebase)**
- 🔥 **Authentication**: Secure user sign-in and session management.
- 🗄️ **Cloud Firestore**: Scalable NoSQL database for real-time patient data.

### **Integrated Utilities**
- 🛡️ **File/Image Picker**: Seamless document and photo selection.
- 📑 **PDF Viewer**: Built-in support for viewing medical reports directly in-app.
- 🌐 **URL Launcher**: Easy integration for external links and contact services.

---

## 📂 System Architecture

```mermaid
flowchart LR
    subgraph Client["Client Layer (Flutter App)"]
        UI[UI Screens]
        SM[State Management (Provider)]
    end

    subgraph Services["Application Services"]
        AUTH[Auth Service]
        DB[Firestore Service]
        ST[Storage Service]
    end

    subgraph Firebase["Firebase Cloud"]
        FA[Firebase Authentication]
        CF[Cloud Firestore]
        CS[Cloud Storage]
    end

    UI --> SM
    SM --> AUTH
    SM --> DB
    SM --> ST

    AUTH --> FA
    DB --> CF
    ST --> CS

    
```

---

## 📱 App Journey
```mermaid
flowchart TD
    A[App Launch] --> B[Splash Screen]
    B --> C{Authenticated?}

    C -- No --> D[Login / Register]
    D --> E[Authentication Success]

    C -- Yes --> F[Role Check]
    E --> F

    F -- Patient --> G[Patient Dashboard]
    F -- Admin --> H[Admin Dashboard]

    G --> G1[View Reports]
    G --> G2[Upload Documents]
    G --> G3[Manage Profile]

    H --> H1[Manage Patients]
    H --> H2[Upload Reports]
    H --> H3[Monitor Activity]

    G --> I[Logout]
    H --> I
    I --> D


---

## ⚙️ Getting Started

### **Prerequisites**
- Flutter SDK installed (v3.10.4 or higher)
- Android Studio / VS Code
- Firebase Project setup

### **Installation Pointers**
1. **Clone the Repository**
   ```bash
   git clone https://github.com/Sidd1374/Medical-Application.git
   ```
2. **Setup Dependencies**
   ```bash
   flutter pub get
   ```
3. **Configure Firebase**
   - Place `google-services.json` in `android/app/`.
   - Place `GoogleService-Info.plist` in `ios/Runner/`.
4. **Launch Application**
   ```bash
   flutter run
   ```

---

## 📝 Assignment Context
This project serves as a comprehensive demonstration of modern mobile application architecture, cloud-sync capabilities, and healthcare-focused user experience design.

---

<p align="center">
  <b>Developed by [Sidd1374](https://github.com/Sidd1374)</b><br>
  <i>Medical Solutions Through Technology</i>
</p>
