#!/bin/bash
set -e

echo "=== Installing Flutter ==="

git clone --depth 1 --branch 3.47.2 https://github.com/flutter/flutter.git "$HOME/flutter"

export PATH="$HOME/flutter/bin:$PATH"

echo "=== Flutter version ==="
flutter --version

echo "=== Enabling Flutter web ==="
flutter config --enable-web

echo "=== Getting dependencies ==="
flutter pub get

echo "=== Building Flutter web ==="
flutter build web --release

echo "=== Build complete ==="
ls -la build/web
