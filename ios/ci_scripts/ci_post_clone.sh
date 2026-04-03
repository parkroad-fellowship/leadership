#!/bin/sh

# Fail this script if any subcommand fails.
set -e

# debug log
set -x

# The default execution directory of this script is the ci_scripts directory.
cd $CI_PRIMARY_REPOSITORY_PATH  # Change working directory to the root of your cloned repo.

# Install Flutter using git.
FLUTTER_VERSION="3.41.4"
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
  : "${PROD_APP_ID:?Missing APP_ID for production build}"
  : "${PROD_APP_SECRET:?Missing APP_SECRET for production build}"
  : "${PROD_BASE_DOMAIN:?Missing BASE_DOMAIN for production build}"
  : "${PROD_SOCKET_DOMAIN:?Missing SOCKET_DOMAIN for production build}"
  : "${PROD_SOCKET_KEY:?Missing SOCKET_KEY for production build}"
  : "${PROD_AZURE_CONN_STRING:?Missing AZURE_CONN_STRING for production build}"
  : "${PROD_HIVE_ENCRYPTION_KEY:?Missing HIVE_ENCRYPTION_KEY for production build}"

  flutter build ios --config-only --release --flavor production -t lib/main.dart \
    --dart-define=APP_ID="$PROD_APP_ID" \
    --dart-define=APP_SECRET="$PROD_APP_SECRET" \
    --dart-define=BASE_DOMAIN="$PROD_BASE_DOMAIN" \
    --dart-define=SOCKET_DOMAIN="$PROD_SOCKET_DOMAIN" \
    --dart-define=SOCKET_KEY="$PROD_SOCKET_KEY" \
    --dart-define=AZURE_CONN_STRING="$PROD_AZURE_CONN_STRING" \
    --dart-define=HIVE_ENCRYPTION_KEY="$PROD_HIVE_ENCRYPTION_KEY"
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
dart run build_runner build

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
