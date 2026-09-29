# 🛍️ NovaStore — Flutter Machine Round Test Implementation

> A unified, production-grade Flutter E-Commerce application integrating **Custom Scroll Effects with Slivers (Task 1)**, **macOS Dock-Style Magnification UI (Task 2)**, and a **Full-Featured Mini E-Commerce App with Secure Storage & Hive Local Database (Task 3)**.

---

## 📱 Table of Contents
1. [Architecture & Project Structure](#-architecture--project-structure)
2. [State Management Justification](#-state-management-justification)
3. [Local Database & Security Choices](#-local-database--security-choices)
4. [Task Breakdown & Implementation](#-task-breakdown--implementation)
   - [Task 1: Custom Scroll Effects with Slivers](#task-1-custom-scroll-effects-with-slivers)
   - [Task 2: macOS Dock Style UI](#task-2-macos-dock-style-ui)
   - [Task 3: Mini E-Commerce App](#task-3-mini-e-commerce-app)
5. [End-to-End Integration Highlights](#-end-to-end-integration-highlights)
6. [Assumptions Made](#-assumptions-made)
7. [Screen Recording Guide (1-2 Min Single Take)](#-screen-recording-guide-1-2-min-single-take)
8. [Setup and Run Instructions](#-setup-and-run-instructions)

---

## 🏛 Architecture & Project Structure

The project strictly follows a **Layered Clean Architecture** adhering to SOLID principles and separation of concerns:

```
lib/
├── core/
│   ├── constants/
│   │   ├── api_constants.dart       # API endpoints and network timeout configurations
│   │   └── app_colors.dart          # Curated color tokens & glassmorphic dock values
│   ├── network/
│   │   └── api_client.dart          # Dio client with interceptors, timeouts, and error mapping
│   ├── storage/
│   │   ├── secure_storage.dart      # flutter_secure_storage wrapper for JWT tokens & sessions
│   │   └── local_database.dart      # Hive local database for user-scoped cart & offline cache
│   └── theme/
│       └── app_theme.dart           # Light & Dark Material 3 theme configurations
├── data/
│   ├── models/
│   │   ├── user_model.dart          # User entity with auth tokens & profile metadata
│   │   ├── product_model.dart       # Product model with discounted price & stock helpers
│   │   ├── cart_item_model.dart     # Cart item with live subtotal and savings calculations
│   │   └── category_model.dart      # Category model with icon mapping and title formatting
│   └── repositories/
│       ├── auth_repository.dart     # Authentication repository with session restoration
│       ├── product_repository.dart  # Products repository with pagination, search, & caching
│       └── cart_repository.dart     # User-scoped cart persistence repository
├── presentation/
│   ├── providers/
│   │   ├── core_providers.dart      # Dependency injection providers
│   │   ├── auth_provider.dart       # AuthNotifier managing session & login/logout state
│   │   ├── product_provider.dart    # ProductsNotifier with infinite scroll & filtering
│   │   ├── cart_provider.dart       # CartNotifier with user isolation & live calculations
│   │   ├── theme_provider.dart      # Light/Dark mode state management
│   │   └── dock_navigation_provider.dart # Dock active tab and tap bounce controllers
│   ├── screens/
│   ├── widgets/
│   └── main.dart
```

---

## ⚖️ State Management Justification

**Choice**: **Riverpod 3.x (`Notifier` / `NotifierProvider`)**

### Why Riverpod?
1. **Compile-Time Safety & No BuildContext Dependency**: Business logic and state changes exist independently of Flutter's widget tree. State can be read and mutated reliably across services, background workers, and screens without passing `BuildContext`.
2. **Unidirectional Data Flow**: State is strictly immutable (`copyWith` pattern), making state mutations predictable and easy to trace.
3. **Cross-Provider Reactivity**: When `authProvider` emits an authenticated user, `cartProvider` immediately detects the user ID and initializes the user-scoped local database cart reactively.
4. **Testability**: Providers can be overridden cleanly in unit/widget tests using `ProviderScope(overrides: [...])` without complex mocking frameworks.

---

## 🔒 Local Database & Security Choices

### 1. Token & Session Persistence: `flutter_secure_storage`
- **Why not SharedPreferences?** Standard `SharedPreferences` stores plaintext XML/plist files that can be extracted on rooted or jailbroken devices.
- **Implementation**: Utilizes Android KeyStore (`EncryptedSharedPreferences`) and iOS/macOS Keychain to store the access token and user credentials encrypted at rest.
- **Session Restoration**: When the app boots, `SplashScreen` restores the session and auto-authenticates if a valid token is present.

### 2. User-Isolated Cart Persistence: `Hive`
- **Why Hive?** Hive is an ultra-fast, lightweight, pure-Dart NoSQL database with zero native build overhead or SQLite file lock contention.
- **User-Scoped Isolation**: Carts are saved under keys formatted as `cart_user_${userId}`. When User A logs in, they only see User A's items. If User B logs in, their cart is completely isolated. Restarting the app preserves the exact items for each respective account.
- **Offline Product Cache**: The first page of products is cached in a dedicated Hive box (`cached_products_box`) for instant offline recovery if internet connectivity fails.

---

## 🚀 Task Breakdown & Implementation

### Task 1: Custom Scroll Effects with Slivers
Located at `lib/presentation/screens/home/home_screen.dart` and `lib/presentation/widgets/`:
- **Collapsing `SliverAppBar`**:
  - `pinned: true`, `floating: true`, `snap: true`.
  - Rich promotional banner with parallax background image (`CollapseMode.parallax`).
  - Integrated search action button that navigates directly to live search.
- **Dynamic Sticky `SliverPersistentHeader` (Category Filters)**:
  - Custom `SliverCategoryHeaderDelegate` using `shrinkOffset` to dynamically transition background opacity, blur, elevation shadow, and chip font sizing.
- **Bonus Feature: Second Sticky Section Header**:
  - `SliverSectionHeaderDelegate` ("Recommended Deals") dynamically pins right under the category header or pushes it as the user scrolls into the list section.
- **`SliverGrid` Section (2 Columns)**:
  - Displays featured products with custom `ProductCard` widgets.
  - Contains discount tags, star ratings, and quick add-to-cart buttons.
- **`SliverList` Section**:
  - Displays > 30 items with horizontal card layout (`ProductListTile`).
- **Pagination & Pull-To-Refresh**:
  - `CustomScrollView` listens to scroll offset and triggers `fetchMoreProducts()` near the bottom.
  - Wrapped in `RefreshIndicator` with `edgeOffset` for pull-to-refresh without sliver jank.
- **Dock Bottom Clearance**: Added bottom sliver padding (`SizedBox(height: 110)`) so the floating macOS dock never obstructs content.

---

### Task 2: macOS Dock Style UI
Located at `lib/presentation/widgets/macos_dock.dart`:
- **Floating Translucent Dock**:
  - Bottom-centered dock wrapped in `BackdropFilter` (Gaussian blur $\sigma = 18$) with translucent glass background and subtle gradient border.
- **20 Custom App Icons**:
  - 20 unique icons with distinctive gradients: Home, Search, Categories, Cart, Wishlist, Orders, Deals, Messages, Alerts, Profile, Wallet, Coupons, Reviews, History, Tracking, Scanner, Receipts, Theme, Settings, Logout.
- **Classic macOS Magnification Wave Effect**:
  - Mathematical cosine wave falloff:
    $$scale = 1.0 + (maxScale - 1.0) \times \cos^2\left(\frac{\pi \cdot distance}{2 \cdot effectRadius}\right)$$
  - Neighboring icons smoothly expand and contract based on proximity to pointer.
- **Dual Platform Support**:
  - **Desktop/Web**: Listens to mouse cursor hover (`MouseRegion.onHover`).
  - **Mobile**: Listens to finger touch and horizontal pan drag (`Listener.onPointerMove`).
- **Floating Tooltip**:
  - Dark macOS pill tooltip dynamically appears above the hovered/touched icon.
- **Tap Bounce Animation**:
  - Damped spring bounce animation triggered via `AnimationController` and `TweenSequence` on tap.
- **Responsive Small Screen Handling**:
  - Wrapped in a horizontal `SingleChildScrollView` with `BouncingScrollPhysics` ensuring zero overflow on narrow mobile screens while maintaining fluid magnification.
- **Active App Indicator Dot**:
  - Subtle dot underneath the selected active app icon, authentic to macOS.
- **Live Cart Badge**:
  - Cart icon (index 3) displays a live circular badge with real-time count synced directly from the local database.
- **Bonus Feature: macOS Menu Bar**:
  - Top system bar (`lib/presentation/widgets/macos_menu_bar.dart`) displaying the Apple logo, store menus, live ticking clock, theme toggle, and logged-in user profile.

---

### Task 3: Mini E-Commerce App
- **Authentication**:
  - Form validation with loading spinner and error message banner.
  - Authenticates against DummyJSON API (`https://dummyjson.com/auth/login`).
  - One-tap demo account fill chips: `emilys / emilyspass` and `michaelw / michaelwpass`.
  - Secure storage via `flutter_secure_storage`.
  - Session restoration on app boot via `SplashScreen`.
- **Product Catalog & Details**:
  - Infinite scroll pagination (`skip` & `limit`) and category filter chips.
  - Live search screen with debouncing and keyword lookup.
  - **Product Details Screen**:
    - Image carousel with page dot indicators.
    - Hero image transition from listing card to detail view.
    - Price savings, stock status, ratings, description, shipping, and warranty info.
    - Quantity stepper (`+` / `-`) and "Add to Cart" action with interactive feedback.
- **Cart Management**:
  - Add, increment, decrement, and remove items.
  - Order summary displaying Subtotal, Discounts Savings, Free Shipping, and Total.
  - Clear cart and checkout simulation with confirmation modal.
  - Real-time cart badge update on the macOS dock.
- **Theming**:
  - Complete Light and Dark theme support with persistent switching via the macOS dock or menu bar.

---

## 🎯 End-to-End Integration Highlights

The three tasks are seamlessly unified into one cohesive app:
1. **Launch & Auto-Login**: The app opens to `SplashScreen`, checks `flutter_secure_storage`, and loads `MainShellScreen`.
2. **Browse via Slivers**: The Home screen is built entirely with `CustomScrollView` featuring a collapsing parallax banner, sticky category filter, 2-column grid, and list section with over 30 items.
3. **Hero Animation**: Tapping a product smoothly expands the image into `ProductDetailScreen`.
4. **Add to Cart & Live Dock Badge**: Adding items increments the live red badge on the macOS Dock in real time.
5. **Navigate via Dock**: Swiping or tapping icons on the floating dock transitions between Home, Search, Categories, Cart, and Profile with a spring bounce animation.
6. **Data Persistence**: Quitting and restarting the app retains both the user session and their local Hive cart intact.
7. **Logout**: Logging out wipes the session securely and redirects to the login screen.

---

## 💡 Assumptions Made

1. **Authentication API**: Uses DummyJSON's official `/auth/login` endpoint. Test accounts (`emilys` / `emilyspass`) are provided as one-tap quick-fill chips on the login screen for testing convenience.
2. **Currency**: All product amounts are formatted in USD (`$`).
3. **Cart Persistence Key**: Cart records are keyed by `cart_user_${userId}` to ensure strict user privacy across multi-account sessions.
4. **Dock Secondary Items**: Secondary icons (Wishlist, Orders, Wallet, etc.) feature functional placeholder screens equipped with quick navigation back to Home.

---

## 🎬 Screen Recording Guide (1-2 Min Single Take)

Follow this sequence for the 1-2 minute demonstration video:
1. **Login Screen**:
   - Open app. Tap the quick-fill chip (`emilys / emilyspass`).
   - Tap **Sign In** and show the smooth transition to the Home screen.
2. **Task 1 (Slivers Screen)**:
   - Scroll down slowly to demonstrate:
     - The `SliverAppBar` banner smoothly collapsing into the pinned toolbar.
     - The sticky `SliverPersistentHeader` category filter transitioning its background color and blur via `shrinkOffset`.
     - The second sticky header ("Recommended Deals") pinning into place.
     - The 2-column `SliverGrid` followed by the `SliverList` (30+ items total).
     - Pull-to-refresh at the top and infinite scroll loading more items at the bottom.
3. **Task 2 (macOS Dock)**:
   - Hover mouse (on desktop/web) or drag finger horizontally across the dock (on mobile).
   - Show icons smoothly magnifying with neighboring icons scaling down in a wave.
   - Point out the floating tooltip label above the active icon.
   - Tap an icon to show the macOS spring bounce animation.
   - Show the active indicator dot underneath the selected icon.
4. **Task 3 (E-Commerce Flow & Persistence)**:
   - Tap a product card to show the **Hero animation** into `ProductDetailScreen`.
   - Select quantity and tap **Add to Cart**.
   - Notice the **Live Badge** on the Dock's Cart icon incrementing immediately.
   - Tap the Cart icon on the Dock to open `CartScreen`.
   - Modify quantities (`+` / `-`) to demonstrate real-time price and savings updates.
   - Toggle **Dark Mode** using the theme icon in the Dock or menu bar.
   - Restart the app (or trigger hot restart) to show that the user stays logged in and the cart is completely preserved from Hive.
   - Navigate to **Profile** and tap **Log Out** to complete the cycle.

---

## 🛠 Setup and Run Instructions

### Prerequisites
- Flutter SDK `^3.13.4` or higher (tested with Flutter 3.27+)
- Dart SDK `^3.13.4`

### Installation
```bash
# Clone the repository
git clone <YOUR_REPO_URL>
cd machine_round_test

# Install dependencies
flutter pub get

# Run static analysis (0 errors, 0 warnings)
flutter analyze

# Run unit and widget tests
flutter test

# Run the app on connected device (Android Emulator, macOS Desktop, or Chrome)
flutter run
```
