#!/bin/bash

# Clone Flutter if not already present
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable
fi

# Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Display Flutter version for debugging
flutter --version

# Install dependencies
flutter pub get

# Build the web app with environment variables
flutter build web --release --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
