# 🗂️ PlanDeck – Smart Task Planner

**PlanDeck** is a modern, dependency-aware **task planning app** built with **Flutter**, powered by **Provider** for reactive state management and **Hive** for offline persistence.  
It helps users break complex goals into smaller, dependent tasks — bringing structure, clarity, and accountability to everyday productivity.

---

## 🚀 Features

- ✅ **Add, Edit, and Delete Tasks**
- 🔗 **Task Dependencies** – mark which tasks must be done before others
- 📆 **Track Progress** – automatic task status updates
- 📦 **Offline Storage** – all data saved locally with Hive
- 🌓 **Light & Dark Theme** support
- ⚡ **Reactive UI** – instant updates with Provider

---

## 🧰 Tech Stack

| Layer | Technology | Purpose |
|--------|-------------|----------|
| **Frontend** | Flutter | Cross-platform UI |
| **State Management** | Provider | Reactive and scalable logic |
| **Local Database** | Hive | Lightweight, offline-first data persistence |
| **Language** | Dart | Core logic and architecture |
| **Design** | Material 3 | Modern and adaptive UI |

---

## 🧱 Architecture Overview

PlanDeck follows a **Clean MVVM-inspired architecture** integrated with Provider.

- lib/
- │
- ├── main.dart
- │
- ├── models/
- │ └── task_model.dart # Task data model (Hive object)
- │
- ├── providers/
- │ ├── task_provider.dart # CRUD + business logic
- │ └── theme_provider.dart # Dark/light mode management
- │
- ├── screens/
- │ ├── task_list_screen.dart # Home screen
- │ ├── add_edit_task_screen.dart # Create/edit tasks
- │ └── settings_screen.dart # Theme toggle
- │
- ├── widgets/
- │ ├── task_tile.dart # Individual task item
- │ ├── dependency_selector.dart # Task dependency input
- │ └── empty_state.dart # Placeholder when no tasks exist
- 
- └── theme/
- ├── app_theme.dart # Theme definitions
- └── theme_colors.dart # Color palette


This separation ensures:
- 🔹 Scalable and readable codebase  
- 🔹 Easy maintainability  
- 🔹 Reactive UI updates tied to app state  

---

## 💾 Data Persistence with Hive

Each task is stored locally using **Hive**.  
Tasks persist between app restarts — no external backend required.


🧪 How to Run Locally

# Clone the repository
git clone https://github.com/Ans-Younas/plan-deck.git

# Navigate into the project directory
cd plan-deck

# Install dependencies
flutter pub get

# Run the app
flutter run
🧩 Future Enhancements

📊 Graph-based dependency visualization

☁️ Cloud backup with Firebase sync

🔔 Smart reminders & daily summaries

🧾 Export tasks (CSV / PDF)

🧠 AI-powered “auto-task planner” suggestions

## 👨‍💻 Author

# Ans Younas 
- Flutter & FlutterFlow Developer
- Software Engineer
- 📍 Punjab, Pakistan
- 🔗 [GitHub Profile](https://github.com/Ans-Younas/)
- 🔗 [LinkedIn Profile](https://www.linkedin.com/in/ans-younas/)

---

This version clearly shows **Hive + Provider integration** and **offline-first design**, which immediately signals to recruiters that you understand real-world app architecture.  


