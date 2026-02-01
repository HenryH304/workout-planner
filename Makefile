.PHONY: help deps clean test test-coverage build-android build-apk build-aab install-android run-android run-web run-ios run-macos simulator analyze format emulator android

# Default target
help:
	@echo "Workout Planner - Make Commands"
	@echo ""
	@echo "Development:"
	@echo "  make deps          - Install Flutter dependencies"
	@echo "  make clean         - Clean build artifacts"
	@echo "  make analyze       - Run Dart analyzer"
	@echo "  make format        - Format Dart code"
	@echo ""
	@echo "Testing:"
	@echo "  make test          - Run all tests"
	@echo "  make test-coverage - Run tests with coverage report"
	@echo "  make test-unit     - Run unit tests only"
	@echo "  make test-widget   - Run widget tests only"
	@echo ""
	@echo "Android:"
	@echo "  make android       - Start emulator (if needed) and run app"
	@echo "  make emulator      - Start Android emulator and wait for boot"
	@echo "  make build-apk     - Build debug APK"
	@echo "  make build-apk-release - Build release APK"
	@echo "  make build-aab     - Build release App Bundle (for Play Store)"
	@echo "  make install-android - Install APK on connected device"
	@echo "  make run-android   - Run app on connected Android device (must be running)"
	@echo ""
	@echo "iOS:"
	@echo "  make simulator     - Open iOS Simulator"
	@echo "  make run-ios       - Run app on iOS simulator (auto-detects)"
	@echo ""
	@echo "Other Platforms:"
	@echo "  make run-web       - Run app in web browser"
	@echo "  make run-macos     - Run app on macOS"

# ============================================
# Development
# ============================================

deps:
	flutter pub get

clean:
	flutter clean
	rm -rf coverage/

analyze:
	flutter analyze

format:
	dart format lib/ test/

# ============================================
# Testing
# ============================================

test:
	flutter test

test-coverage:
	flutter test --coverage
	@echo "Coverage report generated at coverage/lcov.info"
	@if command -v genhtml > /dev/null; then \
		genhtml coverage/lcov.info -o coverage/html; \
		echo "HTML report generated at coverage/html/index.html"; \
	fi

test-unit:
	flutter test test/unit/

test-widget:
	flutter test test/widget_test.dart

# ============================================
# Android Build & Deploy
# ============================================

build-apk:
	flutter build apk --debug

build-apk-release:
	flutter build apk --release

build-aab:
	flutter build appbundle --release
	@echo "App Bundle created at build/app/outputs/bundle/release/app-release.aab"

install-android:
	flutter build apk --debug
	adb install -r build/app/outputs/flutter-apk/app-debug.apk

run-android:
	@DEVICE_ID=$$(flutter devices | grep android | head -1 | cut -d'•' -f2 | tr -d ' '); \
	if [ -z "$$DEVICE_ID" ]; then \
		echo "No Android device found. Please start an emulator or connect a device."; \
		exit 1; \
	fi; \
	echo "Running on device: $$DEVICE_ID"; \
	flutter run -d "$$DEVICE_ID"

# Default emulator name (override with: make emulator EMU=Galaxy_S21_5G)
EMU ?= Medium_Phone_API_36.1
ANDROID_SDK ?= $(HOME)/Library/Android/sdk

emulator:
	@DEVICE_ID=$$(adb devices 2>/dev/null | grep -E 'emulator.*device$$' | cut -f1); \
	if [ -n "$$DEVICE_ID" ]; then \
		echo "Emulator already running: $$DEVICE_ID"; \
		exit 0; \
	fi; \
	echo "Starting emulator: $(EMU) (using software rendering for stability)..."; \
	$(ANDROID_SDK)/emulator/emulator -avd $(EMU) -no-snapshot -gpu swiftshader_indirect > /dev/null 2>&1 & \
	echo "Waiting for emulator to boot..."; \
	for i in $$(seq 1 90); do \
		STATE=$$(adb devices 2>/dev/null | grep emulator | awk '{print $$2}'); \
		BOOT=$$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r'); \
		if [ "$$STATE" = "device" ] && [ "$$BOOT" = "1" ]; then \
			echo "Emulator ready!"; \
			exit 0; \
		fi; \
		sleep 2; \
	done; \
	echo "Emulator boot timed out"; \
	exit 1

android: emulator run-android

# ============================================
# iOS
# ============================================

simulator:
	open -a Simulator

run-ios:
	@DEVICE_ID=$$(flutter devices | grep -i "ios.*simulator" | head -1 | cut -d'•' -f2 | tr -d ' '); \
	if [ -z "$$DEVICE_ID" ]; then \
		echo "No iOS simulator found. Opening Simulator..."; \
		open -a Simulator; \
		sleep 3; \
		DEVICE_ID=$$(flutter devices | grep -i "ios.*simulator" | head -1 | cut -d'•' -f2 | tr -d ' '); \
	fi; \
	if [ -z "$$DEVICE_ID" ]; then \
		echo "Still no iOS simulator found. Please open Simulator manually."; \
		exit 1; \
	fi; \
	echo "Running on iOS simulator: $$DEVICE_ID"; \
	flutter run -d "$$DEVICE_ID"

# ============================================
# Other Platforms
# ============================================

run-web:
	flutter run -d chrome

run-macos:
	flutter run -d macos
