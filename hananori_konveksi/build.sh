#!/bin/bash
set -e

# Configure git to avoid safe directory ownership issues in CI
git config --global --add safe.directory "*"

echo "=== [1/4] Checking Flutter SDK ==="
if [ ! -d "flutter" ]; then
  echo "Downloading Flutter SDK (channel stable)..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 flutter
else
  echo "Flutter SDK directory already exists."
fi

export PATH="$PATH:$(pwd)/flutter/bin"

echo "=== [2/4] Flutter Environment Check ==="
flutter config --no-analytics
flutter precache --web

echo "=== [3/4] Resolving Dependencies ==="
flutter pub get

echo "=== [4/4] Building Flutter Web Release ==="
flutter build web --release

echo "=== Build Complete! Output is ready in build/web ==="
