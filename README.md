<img width="754" height="1600" alt="app-home" src="https://github.com/user-attachments/assets/bf9f72c4-51ee-42fb-9708-b6b2f994dbc1" />
<img width="757" height="1600" alt="app-hydration" src="https://github.com/user-attachments/assets/0f879640-04ae-4e33-954b-9cb68acf998d" />
<img width="758" height="1600" alt="app-temp" src="https://github.com/user-attachments/assets/1980c352-8323-4846-aa15-7bc1da380c88" />
<img width="759" height="1600" alt="app-water" src="https://github.com/user-attachments/assets/927bf1f1-c121-4c43-99df-3ec3eea3c5e0" />
<img width="868" height="1156" alt="hardware-1" src="https://github.com/user-attachments/assets/d61e4062-4ba6-43a6-9f38-9018d369d8d0" />





# 💧 HYDRAX

A smart hydration ecosystem powered by IoT, Bluetooth communication, environmental adaptation, and intelligent water temperature management.

HYDRAX is a next-generation smart water bottle system designed to help users stay hydrated with real-time environmental monitoring, automatic temperature adjustment, Bluetooth connectivity, and hydration tracking.

---

# 🚀 Project Overview

HYDRAX combines modern mobile app development with IoT technology to create an intelligent hydration assistant.

The system automatically adapts water temperature based on environmental conditions and user location while allowing seamless communication between the Flutter application and ESP32 hardware through Bluetooth.

---

# ✨ Features

## 🌡️ Smart Environmental Adaptation

* Detects real-time weather conditions
* Fetches user location dynamically
* Automatically adjusts bottle temperature
* Cools water in hot environments
* Warms water in cold environments

---

## 📍 Live Location Tracking

* Real-time location access
* Weather API integration
* Dynamic environmental analysis
* No default city dependency

---

## 📲 Bluetooth Connectivity

* Bluetooth device discovery
* ESP32 connection support
* Serial communication
* Real-time temperature transmission
* Device connection management

---

## 💧 Hydration Tracking

* Daily water intake logging
* Hydration analytics
* Consumption monitoring
* Daily progress tracking

---

## 🎨 Modern UI/UX

* Fully responsive Flutter UI
* Smooth user experience
* Dark themed interface
* Modern component-based design
* Animated interactions

---

# 🛠️ Tech Stack

## Mobile Application

* Flutter
* Dart
* GetX State Management

## IoT & Hardware

* ESP32
* Bluetooth Serial Communication

## APIs & Services

* Weather API
* Geolocation Services
* Firebase

## Database & Backend

* Firebase Authentication
* Cloud Firestore

---

# 🧠 System Architecture

```text
User → Flutter App → Bluetooth Communication → ESP32 → Smart Bottle Temperature Control
                    ↓
            Weather & Location APIs
                    ↓
         Environmental Temperature Analysis
```

---

# 📂 Project Structure

```bash
hydrax/
│
├── lib/
│   ├── controllers/
│   ├── screens/
│   ├── widgets/
│   ├── services/
│   ├── models/
│   └── main.dart
│
├── assets/
├── android/
├── ios/
├── web/
└── pubspec.yaml
```

---

# 🔥 Core Modules

## 📱 Home Screen

* Environmental adaptation toggle
* Weather display
* Temperature monitoring
* Bluetooth connection controls

## 📡 Bluetooth Module

* Device discovery
* Pairing & connection
* Data transfer
* Serial communication handling

## 🌤️ Weather Module

* Real-time weather fetching
* Temperature analysis
* Environment adaptation logic

## 💧 Hydration Module

* Water intake logging
* Daily hydration statistics
* User hydration insights

---

# ⚙️ Installation & Setup

## 1️⃣ Clone Repository

```bash
git clone https://github.com/your-username/hydrax.git
```

---

## 2️⃣ Navigate to Project

```bash
cd hydrax
```

---

## 3️⃣ Install Dependencies

```bash
flutter pub get
```

---

## 4️⃣ Configure Firebase

* Create Firebase Project
* Enable Authentication
* Enable Firestore Database
* Download `google-services.json`
* Place it inside:

```text
android/app/
```

---

## 5️⃣ Run Application

```bash
flutter run
```

---

# 🔐 Firebase Features

* User Authentication
* Firestore Database
* Real-time Data Storage
* User Profile Management

---

# 📶 Bluetooth Workflow

```text
Search Devices → Select Device → Connect to ESP32 → Send Temperature Data → Smart Bottle Adjusts Temperature
```

---

# 🌡️ Environmental Adaptation Workflow

```text
Get User Location → Fetch Weather Data → Analyze Temperature → Determine Required Water Temperature → Send Data to ESP32
```

---

# 📊 Hydration Tracking Flow

```text
User Logs Water Intake → Store in Firestore → Calculate Daily Consumption → Display Analytics
```

---

# 🔒 Security Features

* Firebase Authentication
* Secure Firestore Rules
* Protected User Data
* Permission Handling
* Bluetooth Permission Management

---

# 📸 UI Highlights

* Modern Smart Bottle Dashboard
* Responsive Mobile Design
* Animated Components
* Real-time Status Indicators
* Smooth Navigation Experience

---

# 📈 Future Enhancements

* 🤖 AI-based Hydration Suggestions
* ⌚ Smartwatch Integration
* 📊 Advanced Analytics Dashboard
* ☁️ Cloud Synchronization
* 🔔 Smart Hydration Notifications
* 🧠 Machine Learning Adaptation
* 🌍 Multi-device Support
* 📱 WearOS & Apple Watch Support

---

# 🧪 Hardware Components

| Component           | Purpose                      |
| ------------------- | ---------------------------- |
| ESP32               | Main Controller              |
| Temperature Module  | Water Temperature Monitoring |
| Bluetooth Module    | Wireless Communication       |
| Smart Bottle System | Temperature Adjustment       |

---

# 🎯 Use Cases

* Daily hydration monitoring
* Smart temperature-controlled hydration
* Fitness & gym hydration tracking
* Travel hydration assistant
* Environment-aware smart bottle system

---

# 🤝 Contributing

Contributions are welcome.

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

---

# 👨‍💻 Team HYDRAX

| Team Member      | Role                          |
| ---------------- | ----------------------------- |
| Sivaprakasam T   | Flutter App & Web Development |
| Kavya S          | Flutter App & Web Development |
| Subasri R        | Research & Development        |
| Priyadharshini S | Research & Development        |
| Shriram S        | Hardware Development          |
| Senthilkumar D   | Hardware Development          |

---

# ⭐ Support

If you like this project:

* Give it a ⭐ on GitHub
* Share it with others
* Contribute to improve the project

---

# 🛡️ Intellectual Property & Patent

HYDRAX is an innovative team project developed as a real-world smart hydration solution.

The project has been officially applied for patent protection, and patent rights have been obtained for the innovation and system design behind HYDRAX.

This project represents a combination of IoT, intelligent environmental adaptation, smart hydration monitoring, and modern mobile application development.

---

# ❤️ Thank You

Thank you for exploring HYDRAX.

Built with innovation, IoT, and Flutter 🚀
