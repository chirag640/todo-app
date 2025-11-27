# 📝 Flutter Todo App - Complete Documentation

A modern, feature-rich task management application built with Flutter, featuring a clean architecture, state management with BLoC, and a beautiful, responsive UI.

---

## 📑 Table of Contents

- [Features](#-features)
- [Complete User Flows](#-complete-user-flows)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [Step-by-Step Setup](#-step-by-step-setup)
- [Running the App](#-running-the-app)
- [State Management](#-state-management)
- [Notification System](#-notification-system)
- [Testing](#-testing)
- [Troubleshooting](#-troubleshooting)

---

## ✨ Features

### Core Features
- ✅ **User Authentication** - Secure login and registration with JWT tokens
- ✅ **Task CRUD Operations** - Create, Read, Update, and Delete tasks
- ✅ **Task Prioritization** - Set priority levels (High, Medium, Low)
- ✅ **Due Dates** - Assign due dates to tasks
- ✅ **Task Categories** - Organize tasks by categories
- ✅ **Task Status** - Track task status (Pending, In Progress, Completed)

### Advanced Features
- 🔔 **Smart Notifications** 
  - Local notifications for task reminders
  - Firebase Cloud Messaging (FCM) for push notifications
  - Scheduled reminders (24h before, 1h before due date)
  - Background notification handling
- 🔍 **Search & Filter**
  - Real-time search by title/description
  - Filter by priority, status, and date
  - Sort by creation date, due date, or priority
- 📱 **Responsive Design** - Optimized for all screen sizes using Sizer
- 🎨 **Modern UI** - Beautiful gradient designs, glassmorphism effects
- 🔄 **Pull to Refresh** - Refresh tasks with a simple gesture
- 💾 **Backend Integration** - RESTful API with automatic sync

---

## 🔄 Complete User Flows

### 1. 🚀 App Launch Flow

```
App Starts
    ↓
Splash Screen (Initialization)
    ↓
Check Authentication Status
    ↓
    ├─→ [User Logged In] → Navigate to Home Page
    └─→ [No User] → Navigate to Login Page
```

**What Happens:**
1. App displays splash screen while initializing
2. Firebase & Notification Service initialize
3. App checks for stored JWT token in secure storage
4. If valid token exists → User goes to Home Page
5. If no token or expired → User goes to Login Page

---

### 2. 🔐 Authentication Flows

#### **A. Login Flow (Existing User)**

```
Login Page
    ↓
User enters email & password
    ↓
Tap "Login" button
    ↓
Validation Check
    ├─→ [Invalid] → Show error message (e.g., "Invalid email format")
    └─→ [Valid] → Send request to backend
                     ↓
                Backend Response
                     ├─→ [Success] → Store JWT token
                     │                    ↓
                     │              Navigate to Home Page
                     │                    ↓
                     │              Load user's tasks
                     │                    ↓
                     │              Register FCM token for notifications
                     │
                     └─→ [Error] → Show error message
                                   ├─→ "Invalid credentials" (Wrong password)
                                   ├─→ "User not found" (Email doesn't exist)
                                   └─→ "Network error" (No internet)
```

**User Actions on Login Page:**
- **Email Field**: Enter registered email address
- **Password Field**: Enter password (hidden text)
- **Login Button**: Tap to submit credentials
- **"Don't have an account? Register"**: Navigate to Register Page
- **Error Messages**: Displayed above form if login fails

**Success Scenario:**
```
Email: johndoe@example.com
Password: •••••••
    ↓
[Login Button] → Loading indicator shows
    ↓
✅ Success → "Welcome back, John!"
    ↓
Navigate to Home → Show tasks list
```

**Error Scenarios:**
```
1. Empty Fields:
   → "Please enter email and password"

2. Invalid Email Format:
   john@invalid
   → "Please enter a valid email address"

3. Wrong Credentials:
   → "Invalid email or password. Please try again."

4. User Doesn't Exist:
   → "No account found with this email. Please register."

5. Network Error:
   → "Connection failed. Please check your internet."
```

---

#### **B. Registration Flow (New User)**

```
Register Page
    ↓
User fills registration form:
├─→ First Name (e.g., "John")
├─→ Last Name (optional, e.g., "Doe")
├─→ Email (e.g., "johndoe@example.com")
├─→ Password (min 6 characters)
└─→ Confirm Password (must match)
    ↓
Tap "Register" button
    ↓
Frontend Validation
    ├─→ [Invalid] → Show specific error
    │                ├─→ "Passwords don't match"
    │                ├─→ "Email already in use"
    │                ├─→ "Password too short"
    │                └─→ "Invalid email format"
    │
    └─→ [Valid] → Send to backend
                     ↓
                Backend Creates Account
                     ├─→ [Success] → Auto-login
                     │                    ↓
                     │              Store JWT token
                     │                    ↓
                     │              Show success message
                     │                    ↓
                     │              Navigate to Home Page
                     │
                     └─→ [Error] → Show error
                                   └─→ "Email already registered"
```

**Registration Form Fields:**
```
┌─────────────────────────────────────┐
│ First Name: [John................] │
│ Last Name:  [Doe.................] │
│ Email:      [john@example.com....] │
│ Password:   [••••••••............] │
│ Confirm:    [••••••••............] │
│                                     │
│        [Register Button]            │
│                                     │
│  Already have an account? Login     │
└─────────────────────────────────────┘
```

**Validation Rules:**
- First Name: Required, min 2 characters
- Last Name: Optional
- Email: Required, valid email format
- Password: Required, min 6 characters
- Confirm Password: Must match Password

**Success Flow:**
```
Fill all fields → Tap Register
    ↓
✅ Account Created!
    ↓
Auto-login → Navigate to Home
    ↓
Welcome Screen: "Welcome, John! Let's create your first task."
```

---

### 3. 🏠 Home Page Flow

```
Home Page Loads
    ↓
Fetch User's Tasks from Backend
    ↓
Display Tasks
    ├─→ [Has Tasks] → Show task list with cards
    └─→ [No Tasks] → Show empty state
                      "No tasks yet. Tap + to create your first task!"
```

**Home Page Layout:**
```
┌────────────────────────────────────────┐
│  👤 [Profile]    My Tasks    [Filter]  │
│                 5 active                │
├────────────────────────────────────────┤
│  🔍 [Search your tasks...]             │
├────────────────────────────────────────┤
│                                        │
│  ┌──────────────────────────────┐     │
│  │ 🔴 HIGH | Complete Assignment│     │
│  │ Due: Tomorrow                │     │
│  │ [✓] Mark Complete            │     │
│  └──────────────────────────────┘     │
│                                        │
│  ┌──────────────────────────────┐     │
│  │ 🟡 MEDIUM | Buy groceries    │     │
│  │ Due: Dec 25                  │     │
│  │ [✓] Mark Complete            │     │
│  └──────────────────────────────┘     │
│                                        │
│  Pull down to refresh ↓               │
│                                        │
│                         [🔔] [➕]     │
│                  (Test) (Add Task)    │
└────────────────────────────────────────┘
```

**Header Actions:**
- **Profile Icon (👤)**: Navigate to Profile Page
- **Filter Icon**: Open filter bottom sheet
- **Active Count**: Shows number of incomplete tasks

**Search Functionality:**
```
User types: "assignment"
    ↓
Real-time filter applied
    ↓
Show only matching tasks
    ↓
Clear search → Show all tasks again
```

**Filter & Sort Options:**
```
┌─────────────────────────────────┐
│    Filter Tasks                 │
├─────────────────────────────────┤
│ Priority:                       │
│  [ ] High  [ ] Medium  [ ] Low  │
│                                 │
│ Status:                         │
│  [ ] Pending                    │
│  [ ] In Progress                │
│  [ ] Completed                  │
│                                 │
│ Sort By:                        │
│  ( ) Creation Date              │
│  (•) Due Date                   │
│  ( ) Priority                   │
│                                 │
│ Date Range:                     │
│  ( ) All                        │
│  ( ) Today                      │
│  ( ) This Week                  │
│  ( ) Overdue                    │
│                                 │
│  [Clear All]  [Apply Filters]   │
└─────────────────────────────────┘
```

**Floating Action Buttons:**
1. **🔔 Test Notification** (Orange) - Sends test notification
2. **➕ Add Task** (Gradient) - Opens task creation form

---

### 4. ➕ Create Task Flow

```
User taps "+" button
    ↓
Navigate to Task Form Page
    ↓
User fills form:
├─→ Title (Required)
├─→ Description (Optional)
├─→ Priority (High/Medium/Low)
├─→ Due Date (Optional, date picker)
├─→ Category (Optional)
└─→ Reminder Setting
    ↓
Tap "Create Task"
    ↓
Frontend Validation
    ├─→ [Invalid] → Show error "Title is required"
    └─→ [Valid] → Send to backend
                     ↓
                Save task + Schedule notifications
                     ↓
                Success message: "Task created successfully!"
                     ↓
                Navigate back to Home
                     ↓
                New task appears in list
                     ↓
                [If due date set] → Notification scheduled
```

**Task Form:**
```
┌─────────────────────────────────────┐
│  ← Back          Create Task        │
├─────────────────────────────────────┤
│                                     │
│ Title *                             │
│ [Complete Assignment..............] │
│                                     │
│ Description                         │
│ [Finish chapter 5 exercises.......] │
│ [.................................]  │
│                                     │
│ Priority *                          │
│ ( ) High  (•) Medium  ( ) Low       │
│                                     │
│ Due Date                            │
│ [📅 Dec 25, 2024  ▼]               │
│                                     │
│ Category                            │
│ [Work ▼]                            │
│                                     │
│ Reminders                           │
│ [☑] 24 hours before                 │
│ [☑] 1 hour before                   │
│                                     │
│         [Create Task]               │
│                                     │
└─────────────────────────────────────┘
```

**Validation:**
- Title: Required (shows red border if empty)
- Priority: Default to Medium if not selected
- Due Date: Optional, opens date-time picker
- Reminders: Only available if due date is set

**After Creating Task:**
```
✅ Task created!
    ↓
Home Page refreshes
    ↓
New task appears at top (sorted by creation date)
    ↓
Green SnackBar: "Task created successfully!"
    ↓
[If due date = Tomorrow 10 AM]:
  - Notification scheduled for Today 10 AM (24h before)
  - Notification scheduled for Tomorrow 9 AM (1h before)
```

---

### 5. 👁️ View Task Details Flow

```
User taps on any task card
    ↓
Navigate to Task Details Page
    ↓
Display full task information:
├─→ Title
├─→ Description
├─→ Priority (with color badge)
├─→ Due Date (formatted)
├─→ Category
├─→ Status
├─→ Created At
└─→ Updated At
```

**Task Details Page:**
```
┌─────────────────────────────────────┐
│  ← Back    Task Details    [Edit]   │
├─────────────────────────────────────┤
│                                     │
│  Complete Assignment                │
│  🔴 HIGH PRIORITY                   │
│                                     │
│  Description:                       │
│  Finish all exercises from          │
│  chapter 5 of the textbook          │
│                                     │
│  📅 Due: Dec 25, 2024, 10:00 AM     │
│  📁 Category: Work                  │
│  ⏱️ Status: Pending                 │
│                                     │
│  Created: Dec 20, 2024              │
│  Updated: Dec 20, 2024              │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ✅ Mark as Complete         │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 🗑️ Delete Task              │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

**Actions Available:**
1. **Edit Button** (Top right): Navigate to Edit Task Form
2. **Mark as Complete**: Toggle task completion status
3. **Delete Task**: Show confirmation dialog → Delete

**Mark Complete Flow:**
```
Tap "Mark as Complete"
    ↓
Task status changes to "Completed"
    ↓
Green checkmark appears
    ↓
Cancel scheduled reminders
    ↓
Update task in backend
    ↓
Success message: "Task marked as complete!"
    ↓
Navigate back to Home
    ↓
Task moves to completed section or gets filtered
```

**Delete Task Flow:**
```
Tap "Delete Task"
    ↓
Show confirmation dialog:
"Are you sure you want to delete this task?"
    ├─→ [Cancel] → Close dialog
    └─→ [Delete] → Delete from backend
                      ↓
                  Cancel reminders
                      ↓
                  Remove from list
                      ↓
                  Navigate to Home
                      ↓
                  Show message: "Task deleted"
```

---

### 6. ✏️ Edit Task Flow

```
From Task Details → Tap "Edit" button
    OR
From Task Card → Long press → Edit
    ↓
Navigate to Task Form (Edit Mode)
    ↓
Form pre-filled with existing data
    ↓
User modifies fields
    ↓
Tap "Update Task"
    ↓
Validate changes
    ↓
Send update to backend
    ↓
Update notifications if due date changed
    ↓
Success message: "Task updated!"
    ↓
Navigate back to Home
    ↓
Task card shows updated information
```

**Edit Form (Pre-filled):**
```
┌─────────────────────────────────────┐
│  ← Back          Edit Task          │
├─────────────────────────────────────┤
│ Title *                             │
│ [Complete Assignment..............] │ ← Pre-filled
│                                     │
│ Description                         │
│ [Finish chapter 5 exercises.......] │ ← Pre-filled
│                                     │
│ Priority *                          │
│ (•) High  ( ) Medium  ( ) Low       │ ← Pre-selected
│                                     │
│ Due Date                            │
│ [📅 Dec 25, 2024  ▼]               │ ← Pre-filled
│                                     │
│         [Update Task]               │
│         [Delete Task]               │
└─────────────────────────────────────┘
```

**Update Scenarios:**
```
1. Change Due Date:
   Old: Dec 25 → New: Dec 30
       ↓
   Cancel old reminders
       ↓
   Schedule new reminders for Dec 29 & Dec 30

2. Change Priority:
   Medium → High
       ↓
   Update task card color
       ↓
   If filtered by priority, may move position

3. Mark as Complete & Edit:
   Status: Completed → Pending
       ↓
   Re-schedule reminders if due date exists
```

---

### 7. 🔍 Search & Filter Flow

#### **Search Flow:**
```
User taps search bar
    ↓
Keyboard appears
    ↓
User types: "assignment"
    ↓
Real-time filtering (every keystroke)
    ↓
Tasks displayed that match:
├─→ Title contains "assignment"
└─→ Description contains "assignment"
    ↓
Show count: "2 results for 'assignment'"
    ↓
User clears search
    ↓
Show all tasks again
```

**Search Examples:**
```
Search: "buy"
Results:
  ✓ Buy groceries
  ✓ Buy birthday gift

Search: "urgent"
Results:
  ✓ Urgent: Fix bug
  ✓ Urgent meeting notes

Search: "xyz123"
Results:
  "No tasks found matching 'xyz123'"
```

#### **Filter Flow:**
```
User taps filter icon
    ↓
Filter bottom sheet slides up
    ↓
User selects filters:
├─→ Priority: [High, Medium]
├─→ Status: [Pending]
├─→ Sort: Due Date
└─→ Date: This Week
    ↓
Tap "Apply Filters"
    ↓
Bottom sheet closes
    ↓
Tasks re-filtered
    ↓
Filter badge shows: "3 filters active"
    ↓
Only matching tasks displayed
```

**Filter Combinations:**
```
Example 1: High Priority + Pending
→ Shows all incomplete high-priority tasks

Example 2: This Week + Sort by Due Date
→ Shows tasks due this week, earliest first

Example 3: Overdue + High Priority
→ Shows critical overdue tasks
```

**Clear Filters:**
```
Tap "Clear All" button
    ↓
All filters reset
    ↓
Badge disappears
    ↓
Show all tasks
```

---

### 8. 🔔 Notification Flow

#### **Local Notification Flow:**
```
User creates task with due date
    ↓
NotificationService schedules:
├─→ Reminder 24h before due time
└─→ Reminder 1h before due time
    ↓
[At scheduled time]
    ↓
System Shows Notification:
┌─────────────────────────────┐
│ 🔔 Task Reminder            │
│ Complete Assignment is due  │
│ tomorrow at 10:00 AM        │
└─────────────────────────────┘
    ↓
User Actions:
├─→ Tap Notification → Open app → Navigate to task details
├─→ Swipe to Dismiss → Notification cleared
└─→ Ignore → Stays in notification tray
```

**Notification Scenarios:**
```
Task: "Complete Assignment"
Due: Dec 25, 2024, 10:00 AM

Scheduled Notifications:
1. Dec 24, 10:00 AM:
   "📅 Reminder: Complete Assignment is due in 24 hours"

2. Dec 25, 9:00 AM:
   "⏰ Urgent: Complete Assignment is due in 1 hour!"

If task completed before due date:
   → Both notifications automatically cancelled
```

#### **Test Notification Flow:**
```
User taps 🔔 (orange button)
    ↓
Instant notification sent
    ↓
┌─────────────────────────────┐
│ 🎉 Test Notification        │
│ Your notification system is │
│ working perfectly!          │
└─────────────────────────────┘
    ↓
Green SnackBar: "✅ Test notification sent!"
```

---

### 9. 👤 Profile Page Flow

```
From Home → Tap profile icon (👤)
    ↓
Navigate to Profile Page
    ↓
Display user information:
├─→ Profile Picture (or default avatar)
├─→ First Name & Last Name
├─→ Email Address
└─→ Account Actions
```

**Profile Page:**
```
┌─────────────────────────────────────┐
│  ← Back          Profile            │
├─────────────────────────────────────┤
│           ┌─────────┐               │
│           │  👤    │               │
│           │ [Edit]  │               │
│           └─────────┘               │
│                                     │
│          John Doe                   │
│     john.doe@example.com            │
│                                     │
├─────────────────────────────────────┤
│  Profile Information    [Edit]      │
│                                     │
│  First Name: John                   │
│  Last Name:  Doe                    │
│  Email:      john.doe@example.com   │
│                                     │
├─────────────────────────────────────┤
│  Actions                            │
│                                     │
│  🔒 Change Password                 │
│  🚪 Logout                          │
│                                     │
└─────────────────────────────────────┘
```

**Profile Actions:**

1. **Edit Profile:**
```
Tap "Edit" button
    ↓
Fields become editable
    ↓
User modifies:
├─→ First Name
├─→ Last Name
└─→ Email
    ↓
Tap "Save"
    ↓
Update backend
    ↓
Success: "Profile updated!"
```

2. **Change Password:**
```
Tap "Change Password"
    ↓
Show dialog:
┌─────────────────────────────┐
│  Change Password            │
│                             │
│  Current Password:          │
│  [••••••••]                 │
│                             │
│  New Password:              │
│  [••••••••]                 │
│                             │
│  Confirm New Password:      │
│  [••••••••]                 │
│                             │
│  [Cancel]  [Change]         │
└─────────────────────────────┘
    ↓
Validate:
├─→ Current password correct?
├─→ New password min 6 chars?
└─→ Passwords match?
    ↓
[Valid] → Update password
    ↓
Success: "Password changed successfully!"
```

3. **Logout:**
```
Tap "Logout"
    ↓
Show confirmation:
"Are you sure you want to logout?"
    ├─→ [Cancel]
    └─→ [Logout] → Clear JWT token
                      ↓
                  Clear local data
                      ↓
                  Unregister FCM token
                      ↓
                  Navigate to Login Page
```

---

### 10. 🔄 Pull to Refresh Flow

```
User on Home Page with task list
    ↓
Pull down from top
    ↓
Refresh indicator appears
    ↓
Fetch latest tasks from backend
    ↓
Update local task list
    ↓
Refresh indicator disappears
    ↓
Tasks list updated
    ↓
[If new tasks] → New tasks appear
[If tasks deleted on another device] → Tasks removed
[If tasks updated] → Updates reflected
```

---

### 11. 🌐 Offline/Online Flow

```
[User's Internet Goes Offline]
    ↓
All actions queue locally
    ↓
Show warning: "No internet connection. Changes will sync when online."
    ↓
User can still:
├─→ View cached tasks
├─→ Create new tasks (saved locally)
├─→ Edit tasks (changes queued)
└─→ Delete tasks (marked for deletion)
    ↓
[Internet Restored]
    ↓
Auto-sync queued changes
    ↓
┌─────────────────────────┐
│ Syncing changes... 3/5  │
└─────────────────────────┘
    ↓
Success: "All changes synced!"
```

---

### 12. ❌ Error Handling Flows

#### **Backend Connection Error:**
```
User taps "Create Task"
    ↓
No internet / Backend down
    ↓
Show error SnackBar:
"❌ Connection failed. Please try again."
    ↓
Retry button available
```

#### **Session Expired:**
```
User uses app
    ↓
JWT token expires (after X days)
    ↓
Next API call fails: 401 Unauthorized
    ↓
Show message: "Session expired. Please login again."
    ↓
Clear stored token
    ↓
Navigate to Login Page
```

#### **Task Not Found:**
```
User tries to view deleted task
    ↓
Backend returns 404
    ↓
Show error: "Task not found. It may have been deleted."
    ↓
Navigate back to Home
    ↓
Refresh task list
```

---

### 13. 🎯 Complete User Journey Example

**Scenario: New User Creates First Task**

```
1. App Launch
   → No stored token
   → Navigate to Login Page

2. User taps "Don't have an account? Register"
   → Navigate to Register Page

3. User fills registration form:
   First Name: John
   Last Name: Doe
   Email: john.doe@example.com
   Password: password123
   Confirm: password123
   → Tap "Register"

4. Account created successfully
   → Auto-login
   → Store JWT token
   → Navigate to Home Page

5. Home shows empty state:
   "No tasks yet. Tap + to create your first task!"

6. User taps "+" button
   → Navigate to Create Task Form

7. User fills form:
   Title: Complete Assignment
   Description: Finish chapter 5 exercises
   Priority: High
   Due Date: Tomorrow, 10:00 AM
   Reminders: ✓ 24h before, ✓ 1h before
   → Tap "Create Task"

8. Task created!
   → Notifications scheduled
   → Navigate to Home
   → Task appears in list

9. Tomorrow at 10:00 AM (24h before):
   → Notification appears:
   "📅 Complete Assignment is due in 24 hours"

10. User taps notification
    → App opens
    → Navigate to task details

11. User reviews task
    → Taps "Mark as Complete"
    → Task marked complete
    → Notifications cancelled
    → Success message shown

12. User returns to Home
    → Task shows as completed
    → Can filter to hide completed tasks
```

---

## 🏗️ Architecture

This app follows **Clean Architecture** principles, separating the codebase into three distinct layers:

### Layer Structure

```
┌─────────────────────────────────────┐
│      Presentation Layer             │
│  (UI, BLoC, Pages, Widgets)         │
└───────────┬─────────────────────────┘
            │
┌───────────▼─────────────────────────┐
│      Domain Layer                   │
│  (Entities, Use Cases, Interfaces)  │
└───────────┬─────────────────────────┘
            │
┌───────────▼─────────────────────────┐
│      Data Layer                     │
│  (Repositories, Models, Services)   │
└─────────────────────────────────────┘
```

### Why Clean Architecture?

1. **Separation of Concerns** - Each layer has a specific responsibility
2. **Testability** - Easy to write unit and widget tests
3. **Maintainability** - Changes in one layer don't affect others
4. **Scalability** - Easy to add new features without breaking existing code
5. **Independence** - Business logic is independent of frameworks and UI

---

## 🛠️ Tech Stack

### Core Framework
- **Flutter SDK**: 3.24.0+
- **Dart**: 3.3.0+

### State Management
- **flutter_bloc**: ^8.1.6 - Implements BLoC (Business Logic Component) pattern
- **equatable**: ^2.0.5 - Simplifies value equality comparisons

### Networking & Storage
- **dio**: ^5.5.0 - HTTP client for API calls
- **flutter_secure_storage**: ^9.2.2 - Secure storage for sensitive data (tokens)

### Notifications
- **firebase_core**: ^3.8.1 - Firebase initialization
- **firebase_messaging**: ^15.1.5 - Firebase Cloud Messaging
- **flutter_local_notifications**: ^18.0.1 - Local notifications
- **timezone**: ^0.9.4 - Timezone support for scheduled notifications
- **permission_handler**: ^11.3.1 - Runtime permission handling

### UI & Utilities
- **sizer**: ^2.0.15 - Responsive design utilities
- **connectivity_plus**: ^6.0.5 - Network connectivity monitoring

---

## 📁 Project Structure

```
lib/
├── core/                           # Core utilities and shared code
│   ├── api/                        # API client configuration
│   │   └── api_client.dart         # Dio setup, interceptors
│   ├── config/                     # App configuration
│   │   └── app_config.dart         # Base URL, constants
│   ├── errors/                     # Error handling
│   │   └── failures.dart           # Custom error classes
│   ├── routing/                    # App navigation
│   │   └── app_router.dart         # Route definitions
│   ├── services/                   # Global services
│   │   └── notification_service.dart  # Notification management
│   └── theme/                      # App theming
│       └── app_colors.dart         # Color palette
│
├── features/                       # Feature modules
│   ├── auth/                       # Authentication feature
│   │   ├── data/                   # Data layer
│   │   │   ├── models/             # Data models
│   │   │   │   └── user_model.dart
│   │   │   └── services/           # API services
│   │   │       ├── auth_service.dart
│   │   │       └── user_service.dart
│   │   └── presentation/           # UI layer
│   │       ├── bloc/               # BLoC files
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       └── pages/              # Screen widgets
│   │           ├── login_page.dart
│   │           └── register_page.dart
│   │
│   └── home/                       # Task management feature
│       ├── data/                   # Data layer
│       │   ├── models/
│       │   │   └── task_model.dart
│       │   └── services/
│       │       └── task_service.dart
│       └── presentation/           # UI layer
│           ├── bloc/
│           │   ├── task_bloc.dart
│           │   ├── task_event.dart
│           │   └── task_state.dart
│           ├── pages/
│           │   ├── home_page.dart
│           │   ├── task_form_page.dart
│           │   └── task_details_page.dart
│           └── widgets/
│               ├── task_card.dart
│               └── filter_bottom_sheet.dart
│
├── firebase_options.dart           # Firebase configuration
└── main.dart                       # App entry point
```

---

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

1. **Flutter SDK** (3.24.0 or higher)
   - Download from [flutter.dev](https://flutter.dev/docs/get-started/install)
   - Verify installation: `flutter doctor`

2. **Dart SDK** (3.3.0 or higher)
   - Comes with Flutter SDK

3. **IDE** (Choose one)
   - [Android Studio](https://developer.android.com/studio) with Flutter plugin
   - [VS Code](https://code.visualstudio.com/) with Dart and Flutter extensions

4. **Device/Emulator**
   - Android: Android Studio AVD or physical device
   - iOS: Xcode simulator or physical device (macOS only)

---

## 📋 Step-by-Step Setup

### Step 1: Clone the Repository

```bash
git clone https://github.com/chirag640/todo-app.git
cd todo_app
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

This command downloads all the required packages listed in `pubspec.yaml`.

### Step 3: Configure Firebase (Required for Notifications)

#### 3.1 Create a Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" and follow the wizard
3. Enable **Cloud Messaging** in your Firebase project

#### 3.2 Add Android App
```bash
# In Firebase Console:
1. Click "Add app" → Android
2. Enter package name: com.example.todo_app
3. Download google-services.json
4. Place it in: android/app/google-services.json
```

#### 3.3 Add iOS App (if targeting iOS)
```bash
# In Firebase Console:
1. Click "Add app" → iOS
2. Enter bundle ID: com.example.todoApp
3. Download GoogleService-Info.plist
4. Place it in: ios/Runner/GoogleService-Info.plist
```

#### 3.4 Initialize FlutterFire
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

This generates `lib/firebase_options.dart` automatically.

### Step 4: Configure Backend URL

Open `lib/core/config/app_config.dart` and update the base URL:

```dart
class AppConfig {
  static const String baseUrl = 'https://your-backend-url.com/api';
  // or for local development:
  // static const String baseUrl = 'http://10.0.2.2:3000/api'; // Android Emulator
  // static const String baseUrl = 'http://localhost:3000/api'; // iOS Simulator
}
```

### Step 5: Set Up Android (for Notifications)

#### 5.1 Update `android/app/build.gradle.kts`

Ensure you have:

```kotlin
android {
    compileSdk = 34
    
    defaultConfig {
        minSdk = 21
        targetSdk = 34
    }
    
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
}
```

#### 5.2 Update `android/app/src/main/AndroidManifest.xml`

Add notification permissions:

```xml
<!-- Add inside <manifest> tag -->
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
```

### Step 6: Request Permissions (Android 13+)

The app automatically requests notification permissions on first launch.

---

## ▶️ Running the App

### Debug Mode (Development)

```bash
# Run on connected device/emulator
flutter run

# Run on specific device
flutter devices  # List all devices
flutter run -d <device-id>

# Hot reload: Press 'r' in terminal
# Hot restart: Press 'R' in terminal
```

### Release Mode (Production)

#### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

#### Android App Bundle (For Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

#### iOS (macOS only)
```bash
flutter build ios --release
# Then open in Xcode: ios/Runner.xcworkspace
```

---

## 🧩 State Management

This app uses the **BLoC (Business Logic Component)** pattern:

### Why BLoC?

✅ **Separation of Business Logic**: Logic is separate from UI  
✅ **Testable**: Easy to write unit tests for BLoCs  
✅ **Stream-based**: Reactive programming with Dart Streams  
✅ **Scalable**: Works well for complex, large-scale apps  
✅ **Predictable**: State transitions are explicit and traceable  

### BLoC Flow

```
User Interaction (UI)
       ↓
   Add Event to BLoC
       ↓
   BLoC processes Event
       ↓
   BLoC emits new State
       ↓
   UI rebuilds based on State
```

### Example: Creating a Task

```dart
// 1. User taps "Create Task"
context.read<TaskBloc>().add(CreateTaskEvent(newTask));

// 2. BLoC receives event
on<CreateTaskEvent>((event, emit) async {
  emit(TaskLoading());
  try {
    final task = await taskService.createTask(event.task);
    emit(TaskOperationSuccess('Task created', updatedTasks));
  } catch (e) {
    emit(TaskError('Failed to create task'));
  }
});

// 3. UI listens to state
BlocBuilder<TaskBloc, TaskState>(
  builder: (context, state) {
    if (state is TaskLoading) return CircularProgressIndicator();
    if (state is TaskError) return Text(state.message);
    // ... handle other states
  },
)
```

---

## 🔔 Notification System

### Architecture

```
┌─────────────────────────────────────────┐
│  Local Notifications                    │
│  (flutter_local_notifications)          │
│  - Scheduled reminders                  │
│  - Timezone-aware                       │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│  Notification Service (Singleton)       │
│  - Initialize                           │
│  - Schedule                             │
│  - Cancel                               │
│  - Handle Taps                          │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│  Firebase Cloud Messaging               │
│  (firebase_messaging)                   │
│  - Foreground messages                  │
│  - Background messages                  │
│  - Push from backend                    │
└─────────────────────────────────────────┘
```

### Notification Types

1. **Task Reminders (Local)**
   - Scheduled 24 hours before due date
   - Scheduled 1 hour before due date
   - Uses Android Notification Channels

2. **Push Notifications (FCM)**
   - Sent from backend for:
     - Task assignments
     - Overdue tasks
     - Task updates from collaborators

3. **Test Notifications**
   - Orange button on home screen
   - For debugging notification setup

---

## 🧪 Testing

### Run All Tests
```bash
flutter test
```

### Run Specific Test
```bash
flutter test test/features/home/data/models/task_model_test.dart
```

### Test Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 🐛 Troubleshooting

### Common Issues

#### 1. **"Floating SnackBar presented off screen"**
- **Cause**: SnackBar shown without proper context or when widget is unmounted
- **Fix**: Check `mounted` before showing SnackBar
```dart
if (mounted) {
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
```

#### 2. **Firebase initialization error**
- **Cause**: Missing `google-services.json` or `GoogleService-Info.plist`
- **Fix**: Run `flutterfire configure` and ensure files are in correct locations

#### 3. **Notifications not showing**
- **Android 13+**: Request POST_NOTIFICATIONS permission
- **iOS**: Enable notifications in Settings → App → Notifications
- **Debug**: Check if channel is created and permissions granted

#### 4. **API connection failed**
- **Android Emulator**: Use `10.0.2.2` instead of `localhost`
- **iOS Simulator**: Use `localhost`
- **Physical Device**: Use actual IP address
- **Check**: Backend is running and firewall allows connections

#### 5. **gradle build failed**
- Update Gradle version in `android/gradle/wrapper/gradle-wrapper.properties`
- Clean build: `flutter clean && flutter pub get`

### Debug Commands

```bash
# Check Flutter environment
flutter doctor -v

# Clear cache and rebuild
flutter clean
flutter pub get
flutter run

# View logs
flutter logs

# Check connected devices
flutter devices

# Analyze code issues
flutter analyze
```

---

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [BLoC Documentation](https://bloclibrary.dev/)
- [Firebase for Flutter](https://firebase.flutter.dev/)
- [Material Design Guidelines](https://material.io/design)

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 👨‍💻 Author

**Chirag**  
GitHub: [@chirag640](https://github.com/chirag640)

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- BLoC library for excellent state management
- Firebase for cloud infrastructure
- Material Design for UI inspiration

---

**Happy Coding! 🚀**
