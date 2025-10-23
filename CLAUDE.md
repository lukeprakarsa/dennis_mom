# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter application called "dennis_mom" - an inventory/catalog management app with cart functionality. The app demonstrates a vendor management system where items can be added, edited, and purchased through a shopping cart interface.

## Architecture

### Data Layer
- **Realm Database**: Uses MongoDB Realm for local data persistence (`lib/models/item.dart`)
- **Item Model**: Core data model with fields: id, name, description, price, imageUrl, stock
- **Generated Code**: `lib/models/item.realm.dart` is auto-generated from the `@RealmModel()` annotation

### State Management
- **Provider Pattern**: Uses `provider` package for state management
- **Cart**: ChangeNotifier-based cart system (`lib/models/cart.dart`) with item quantity tracking
- **VendorRepository**: Abstract repository pattern with in-memory implementation for item CRUD operations

### Screen Architecture
- **CatalogScreen**: Main product listing with cart integration
- **CartScreen**: Shopping cart view with checkout functionality
- **VendorScreen**: Admin interface for managing inventory
- **ItemDetailScreen**: Detailed product view
- **Add/Edit Item Tabs**: Admin forms for item management

### Key Patterns
- Repository pattern for data access abstraction
- Provider for dependency injection and state management
- Consumer widgets for reactive UI updates
- Stack-based overlays for out-of-stock item visualization

## Development Commands

### Core Flutter Commands
```bash
# Run the app (development)
flutter run

# Run tests
flutter test

# Build for production
flutter build windows    # For Windows
flutter build web        # For web
flutter build apk        # For Android (requires Android SDK)

# Code analysis
flutter analyze

# Clean build artifacts
flutter clean

# Install dependencies
flutter pub get

# Check Flutter environment
flutter doctor
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage

# Run tests with specific name pattern
flutter test --name="test_pattern"
```

### Code Generation
```bash
# Generate Realm model files when Item model changes
flutter packages pub run realm generate
```

## Key Dependencies

- **realm**: MongoDB Realm for local database persistence
- **provider**: State management and dependency injection
- **cupertino_icons**: iOS-style icons
- **collection**: Dart collection utilities
- **flutter_lints**: Dart/Flutter linting rules

## Important Notes

### Realm Integration
- The Item model uses `@RealmModel()` annotation requiring code generation
- Generated files (`*.realm.dart`) should not be manually edited
- Realm schema changes require regeneration and potentially database migration

### State Management Flow
1. `InMemoryVendorRepository` manages item CRUD operations
2. `Cart` manages shopping cart state with stock validation
3. Both extend `ChangeNotifier` to trigger UI rebuilds
4. UI screens use `Consumer` widgets to listen for state changes

### Current Limitations
- Android toolchain not configured (Android SDK missing)
- In-memory data storage (no persistence between app restarts)
- Basic error handling and validation

### Stock Management
- Items have stock tracking with visual indicators
- Cart prevents adding more items than available stock
- Out-of-stock items are visually disabled but remain interactive for details