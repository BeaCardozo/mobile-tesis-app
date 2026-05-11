# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**CaracasAhorra** — a Flutter mobile app for comparing grocery prices across supermarkets in Caracas. Users can browse products, compare prices at different stores, and manage a shopping cart optimized by store.

## Build & Development Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run on connected device/emulator
flutter analyze          # Run static analysis (linter)
flutter test             # Run all tests
flutter test test/widget_test.dart  # Run a single test file
flutter build apk --release   # Build Android APK
flutter build ios --release   # Build iOS
```

Flutter SDK constraint: `>=3.4.1 <4.0.0`

## Architecture

Informal layered architecture with three layers:

```
Screens & Widgets  (presentation)
       ↓
    Services        (business logic)
       ↓
    Models          (data)
```

- **State management**: StatefulWidget only (no Provider/Bloc/Riverpod). State is local to each screen.
- **Navigation**: Direct `Navigator.push()` / `pushReplacement()` calls. No named routes.
- **Backend**: **ca-api** (NestJS, prefijo global `api`). Cliente HTTP: `lib/services/api_client.dart` + `lib/services/api.dart` (`Api.instance`). URL base: `lib/config/api_config.dart` (`ApiConfig.baseUrl`, por defecto `http://localhost:4003/api`, alineado con `NEXT_PUBLIC_API_URL` del web). En **emulador Android** usar `http://10.0.2.2:4003/api`; en iOS simulador / web suele bastar `localhost`. Los IDs públicos de catálogo en JSON son **strings** (ver `lib/models/api_models.dart`).

## Key Directory Layout

- `lib/config/` — `AppColors`, `AppTheme`, `ApiConfig`
- `lib/models/` — `Product`, `PriceInfo`, `CartItem`, `Category`, `api_models.dart` (DTOs del backend)
- `lib/services/` — `Api`, `ApiClient`, `*_api_service.dart`, `cart_manager.dart`
- `lib/screens/` — 13 screens; `MainScreen` hosts a `BottomNavigationBar` with `IndexedStack`
- `lib/widgets/` — Reusable components: `BottomNavBar`, `ProductCard`, `CategoryCard`, `CartButton`

## Navigation Flow

```
SplashScreen → (auth check) → LoginScreen or MainScreen
LoginScreen ↔ RegisterScreen
MainScreen (bottom nav): Home | Products | Offers | Profile (notificaciones desde header en Home/Products)
HomeScreen → ProductDetailScreen, CategoriesScreen, FeaturedProductsScreen, CartScreen
```

## Styling Conventions

- All colors defined in `AppColors` (`lib/config/app_colors.dart`). Primary: `#77A14B` (green).
- Theme defined in `AppTheme.lightTheme` using Material 3.
- Border radius: 12–24px. Rounded buttons with 14–20px radius.
- App is locked to portrait orientation (`main.dart`).

## Language

UI text and code comments are in **Spanish**. Variable/class names are in English.
