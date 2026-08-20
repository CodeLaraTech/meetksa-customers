#!/bin/bash

# ==============================================================================
# MeetKSA Customer - iOS Release Build Script (for macOS)
# ==============================================================================

set -e

echo "🚀 Starting MeetKSA Customer iOS Release Build..."

# 1. Clean and get dependencies
echo "📦 Getting Flutter dependencies..."
flutter clean
flutter pub get

# 2. Update CocoaPods if inside ios directory
echo "🍎 Updating CocoaPods dependencies..."
cd ios
pod install --repo-update
cd ..

# 3. Build iOS IPA (Archive)
echo "🔨 Compiling iOS Release IPA..."
flutter build ipa --release

echo ""
echo "✅ iOS Build Completed Successfully!"
echo "📁 Your IPA and Archive files are located at:"
echo "   build/ios/archive/Runner.xcarchive"
echo "   build/ios/ipa/meetksa_customer.ipa"
echo ""
echo "To upload to App Store Connect:"
echo "   xcrun altool --upload-app -f build/ios/ipa/*.ipa -t ios -u <APPLE_ID> -p <APP_SPECIFIC_PASSWORD>"
echo "   OR use Xcode Organizer (Window -> Organizer -> Distribute App)"
