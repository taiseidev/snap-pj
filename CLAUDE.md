# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ShotLog is a Flutter mobile app (iOS/Android) that analyzes EXIF data from DSLR/mirrorless camera photos to visualize shooting patterns and track photographer growth.

## Tech Stack

- Flutter 3.29 / Dart 3.7
- State management: Riverpod 2.x (StateNotifierProvider, StateProvider)
- Charts: fl_chart 0.69.x
- Architecture: Feature-first with Repository Pattern

## Build & Test Commands

- `flutter pub get` - Install dependencies
- `flutter run` - Run the app
- `flutter analyze` - Static analysis
- `flutter test` - Run all tests
- `flutter test --update-goldens test/screenshot_test.dart` - Regenerate screenshots

## Architecture

- `lib/core/` - Theme, constants, shared config
- `lib/features/{feature}/presentation/pages/` - Page widgets
- `lib/features/{feature}/presentation/widgets/` - Feature-specific widgets
- `lib/shared/models/` - Data models (PhotoData) and mock data
- `lib/shared/providers/` - Riverpod state management
- `lib/shared/widgets/` - Reusable UI components

## Conventions

- Japanese UI text, English code
- Dark theme with accent color #E94560
- NotoSansJP font (bundled in assets/fonts/)
- Screenshots generated via golden tests in `test/screenshot_test.dart`, output to `screenshots/`
