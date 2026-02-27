#!/bin/sh

# Fail this script if any subcommand fails.
set -e

# debug log
set -x

# The default execution directory of this script is the ci_scripts directory.
cd $CI_PRIMARY_REPOSITORY_PATH  # Change working directory to the root of your cloned repo.

# Install Flutter using git.
FLUTTER_VERSION="3.38.5"
git clone https://github.com/flutter/flutter.git --depth 1 -b $FLUTTER_VERSION $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# Step out of the Flutter folder.
cd $CI_PRIMARY_REPOSITORY_PATH

app_env="$APP_ENV"
if [ "$app_env" = "production" ]; then
  # Rename main_production.dart to main.dart
  mv lib/main_production.dart lib/main.dart
fi

if [ "$app_env" = "staging" ]; then
  # Rename main_staging.dart to main.dart
  mv lib/main_staging.dart lib/main.dart
fi

if [ "$app_env" = "development" ]; then
  # Rename main_development.dart to main.dart
  mv lib/main_development.dart lib/main.dart
fi

# Install Flutter artifacts for iOS (--ios), or macOS (--macos) platforms.
flutter precache --ios

# Install Flutter dependencies.
flutter pub get

# Configure Flutter project for release mode
if [ "$app_env" = "production" ]; then
  flutter build ios --config-only --release --flavor production -t lib/main.dart
elif [ "$app_env" = "staging" ]; then
  flutter build ios --config-only --release --flavor staging -t lib/main.dart
elif [ "$app_env" = "development" ]; then
  flutter build ios --config-only --release --flavor development -t lib/main.dart
else
  echo "Unknown APP_ENV: $app_env"
  exit 1
fi

# # Check for any formatting issues
# dart format --set-exit-if-changed lib test

# Run code gen
dart run build_runner build --delete-conflicting-outputs

# Activate FlutterFire CLI globally to ensure 'flutterfire' command is available
# This is crucial for build phases that use flutterfire, like Crashlytics symbol uploads.
dart pub global activate flutterfire_cli

# # Run static analysis
# flutter analyze lib

# Install CocoaPods using Homebrew.
HOMEBREW_NO_AUTO_UPDATE=1 brew install cocoapods

# Install CocoaPods dependencies.
cd ios && pod install --repo-update --verbose && cd ..

exit 0
