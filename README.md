# Study Planner App

A Flutter-based study planner application with task management, calendar integration, and reminder functionality.

## Features

### 📋 Task Management
- Create, edit, and delete tasks
- Add task title, description, and due date
- Mark tasks as completed
- Tasks stored locally using shared_preferences

### 📅 Calendar View
- Monthly calendar with highlighted task dates
- View tasks by date
- Visual indicators for days with tasks
- Navigate through months

### 🔔 Reminders
- Set reminders for tasks
- Popup notifications when reminders are due
- Quick actions to mark tasks as done from reminder popup

### 📱 Multi-Screen Navigation
- Bottom navigation bar with three screens:
  - **Today**: View all tasks due today
  - **Calendar**: Monthly calendar view with task dates
  - **Settings**: App information and data management

### 🎨 Material Design
- Clean and modern UI
- Material Design 3 components
- Responsive layouts
- Intuitive user experience

## Technology Stack

- **Framework**: Flutter
- **State Management**: StatefulWidget
- **Local Storage**: shared_preferences
- **Calendar**: table_calendar package
- **Date Formatting**: intl package

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.2.2
  intl: ^0.18.1
  table_calendar: ^3.0.9
```

## Project Structure

```
lib/
├── main.dart                 # App entry point and main navigation
├── models/
│   └── task.dart            # Task data model
├── screens/
│   ├── today_screen.dart    # Today's tasks screen
│   ├── calendar_screen.dart # Calendar view screen
│   └── settings_screen.dart # Settings screen
├── services/
│   ├── storage_service.dart # Local storage operations
│   └── reminder_service.dart # Reminder functionality
└── widgets/
    ├── task_card.dart       # Task list item widget
    └── task_dialog.dart     # Add/Edit task dialog
```

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Android SDK / Xcode (for iOS)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/uwambajeddy/study_planner_app.git
cd study_planner_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Usage

### Adding a Task

1. Navigate to the Today or Calendar screen
2. Tap the floating action button (+)
3. Fill in the task details:
   - Title (required)
   - Description (optional)
   - Due date and time
   - Set reminder (optional)
4. Tap "Add" to save

### Editing a Task

1. Tap on any task card
2. Modify the task details
3. Tap "Save" to update

### Deleting a Task

1. Tap the delete icon on any task card
2. Confirm deletion in the dialog

### Setting Reminders

1. When adding/editing a task, toggle "Set Reminder"
2. Select the reminder date and time
3. The app will show a popup when the reminder time arrives

### Calendar Navigation

1. Navigate to the Calendar screen
2. Tap any date to view tasks for that day
3. Swipe left/right to change months
4. Days with tasks are highlighted with orange markers

## Screenshots

[Screenshots would be added here showing the app in action]

## Building for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```


## License

This project is open source and available under the MIT License.

## Author

Uwambaje Eddy
