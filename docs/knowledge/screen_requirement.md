# FlutterFlow AI Prompt: Badminton Court Booking App

**Context:** Badminton Court Booking Mobile Application.

## Design System & Global Rules
*   **Design Language:** Professional and Minimalist (clean typography, ample whitespace, uncluttered UI).
*   **Primary Color:** `#132D77` (Use for key buttons, active states, backgrounds, and brand elements).
*   **SafeArea:** Wrap all screen content in `SafeArea` to prevent OS UI overlap.
*   **Responsiveness:** Ensure responsive constraints for mobile devices.
*   **Global Header:** Reusable component on main screens. Includes:
    *   Account Avatar icon (routes to Profile).
    *   Language Toggle button (VI/EN text).
    *   Theme Toggle icon (Light/Dark mode).

## Screen & UI Flow Generation

### 1. Onboarding & Splash
*   **Splash Screen:** Centered app logo with `#132D77` background.
*   **Onboarding Screen:** A `PageView` with 3 swipeable cards (image, title, subtitle) and a "Get Started" button routing to Login.

### 2. Authentication
*   **Auth Screen:** Minimalist tabbed layout for Login and Sign Up. Include Email, Password fields, and OAuth2 buttons (Google/Apple). Add a "Forgot Password" text button.
*   **OTP Component:** A `BottomSheet` or `Dialog` containing a 6-digit PIN code input array, triggered after successful Sign Up.

### 3. Home Screen
*   **Top:** Global Header component.
*   **Hero Section:** A horizontal `PageView` for promotional banners (images with rounded corners).
*   **Search & Filter:** A `TextField` for search with a trailing filter icon button.
*   **Content List:** A vertical `ListView` of "Recommended Courts".
*   **Court Card:** A clean `Container` holding a cover image, Court Name, Address, Price per hour, Rating (Star icon + score), and an `ElevatedButton` "Book Now" styled with `#132D77`.

### 4. Court Details Screen
*   **Header:** Full-width hero image of the court with a back button overlay.
*   **Body:** Scrollable column containing Court Name, Location, Description text, and Price per hour. Keep text styling clean and hierarchical.
*   **Cross-sell Menu:** A horizontal `ListView` showing related products (water, rental rackets) with small images, names, and "+ Add" buttons.
*   **Reviews:** A section displaying user reviews (Avatar, Name, Star rating, Comment).
*   **Sticky Footer:** A fixed bottom `Container` (using `Stack` or bottom sheet area) with the total price and a prominent "Book Court" floating button (`#132D77`).

### 5. Time Slot Matrix Screen (Booking Grid)
*   **Layout:** A 2-dimensional scrollable schedule view based on the grid structure in image_7a0a2b.png.
*   **Time Header (X-Axis):** A horizontal `Row` of time slots in 30-minute intervals (e.g., 6:00, 6:30, 7:00 to 17:00).
*   **Court Names (Y-Axis):** A vertical `Column` on the left showing sub-court names (e.g., Florida, California, Arizona).
*   **Grid View:** An interactive grid of containers mapping to courts and times.
*   **Cell States:** Gray `Container` (unavailable/past), White `Container` (available), `#132D77` or Red `Container` (selected by user).
*   **Footer:** A "Confirm Selection" button (`#132D77`) at the bottom.

### 6. Review Order Screen
*   **Summary:** Minimalist card displaying selected court name, date, and the specific time slots.
*   **Add-ons:** List of selected items (water, rackets).
*   **Pricing:** Subtotal, Tax, and Final Total calculated rows.
*   **Action:** "Proceed to Payment" button.

### 7. Checkout & QR Payment Screen
*   **Title:** "Scan to Pay Deposit".
*   **Content:** A large, centered QR Code image. Below it, display the Bank Name, Account Number, and Total Amount text.
*   **Action:** A "Confirm Payment Completed" button.

### 8. Order Detail (Success) Screen
*   **Header:** Green checkmark icon with "Booking Confirmed" text.
*   **Details:** Clean card with Booking ID, Court Info, Time, and a small QR code for physical check-in at the venue.
*   **Action:** "Back to Home" outline button.

### 9. Profile & Account Management Screen
*   **Header:** User Avatar, Full Name, and Email.
*   **Menu:** A `ListView` of `ListTile` widgets for: Change Password, Edit Email, Edit Phone Number, and App Settings. Minimalist dividers.
*   **Footer:** A "Log Out" button (styled with red text or outline).

---

## Technical Implementation Note: Screen 5 (Matrix Grid)

**Root Cause:** AI UI generators typically fail at rendering complex 2D synchronized scrolling matrices out-of-the-box using standard grid layouts.
**Solution:** Instruct the AI to generate the base structure using standard containers, then manually refactor the generated code to use a custom widget package like `syncfusion_flutter_calendar` or `table_sticky_headers`.
**Reasoning:** FlutterFlow relies on standard `GridView` for grids, which does not support sticky headers for both X and Y axes natively without writing custom Dart code. Local modification is required for production-readiness.