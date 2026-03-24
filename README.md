# 🚌 ShuttleLink

**ShuttleLink** is a comprehensive, dual-portal Flutter application designed to streamline and modernize university and corporate shuttle services. Built with a sleek dark-theme UI and powered by Firebase Realtime Database, it connects passengers and drivers through a seamless, real-time booking and management ecosystem.

---

## ✨ Key Features

### 🧑‍🎓 Passenger Portal
* **Real-Time Seat Booking:** Browse available routes (e.g., Kandy, Galle, Gampaha), select shifts (Morning/Evening), and lock in specific seats using a live, interactive seat map.
* **Smart Ticket Management:** View active and past tickets with dynamic status badges (Booked, Confirmed, Cancelled) that update instantly based on driver actions.
* **Targeted Notifications:** Receive instant alerts for ride delays, cancellations, or lost items specific *only* to the buses and dates you have booked.
* **Lost & Found Network:** Report lost or found items. The smart matching system automatically filters reports so passengers only see items relevant to their specific ride history.
* **Driver Feedback & Ratings:** View community ratings for specific buses and submit personal 5-star reviews and feedback after a completed trip.
* **Sandbox Checkout:** A mock payment gateway to simulate secure ticket purchasing.

### 🚍 Driver Portal
* **Live Seat Management:** View a real-time manifest of booked seats, passenger names, and student/NIC IDs. 
* **Boarding Confirmation:** Tap to confirm when a passenger boards, instantly updating the passenger's app ticket to "Confirmed".
* **Mass Alert System:** Send immediate "Delay" or "Ride Cancelled" push notifications directly to the phones of passengers booked on a specific route and date.
* **Automated Income Tracking:** A built-in financial dashboard that automatically calculates Daily and Monthly income based on live seat bookings, excluding cancelled trips.

---

## 🛠️ Tech Stack

* **Frontend:** Flutter (Dart)
* **Backend:** Firebase Realtime Database
* **Authentication:** Firebase Authentication (Email/Password)
* **State Management:** Stateful Widgets & StreamBuilders for real-time UI updates
* **Date/Time Parsing:** `intl` package for robust, cross-format date matching

---



## 🚀 Installation & Setup

To run this project locally, you will need to have [Flutter](https://flutter.dev/docs/get-started/install) installed.

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/yourusername/ShuttleLink.git](https://github.com/yourusername/ShuttleLink.git)
   cd ShuttleLink
