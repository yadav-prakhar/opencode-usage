PROJECT_NAME := OpencodeUsage
APP_NAME := OpenCode Usage
SCHEME := OpencodeUsage
BUILD_DIR := build
APP_BUNDLE := $(BUILD_DIR)/Build/Products/Debug/$(APP_NAME).app
RELEASE_APP_BUNDLE := $(BUILD_DIR)/Build/Products/Release/$(APP_NAME).app

.PHONY: setup build release run clean logs dmg

setup:
	xcodegen generate

build: setup
	xcodebuild -project $(PROJECT_NAME).xcodeproj -scheme $(SCHEME) -configuration Debug -derivedDataPath $(BUILD_DIR) build

release: setup
	xcodebuild -project $(PROJECT_NAME).xcodeproj -scheme $(SCHEME) -configuration Release -derivedDataPath $(BUILD_DIR) build

run: build
	killall "$(APP_NAME)" 2>/dev/null || true
	open "$(APP_BUNDLE)"

clean:
	rm -rf $(PROJECT_NAME).xcodeproj $(BUILD_DIR) "$(APP_NAME).dmg"

logs:
	log stream --predicate 'subsystem == "com.wiscaksono.opencode-usage"' --level info

dmg: release
	@rm -f "$(APP_NAME).dmg"
	@hdiutil create -volname "$(APP_NAME)" \
		-srcfolder "$(RELEASE_APP_BUNDLE)" \
		-ov -format UDZO \
		"$(APP_NAME).dmg"
	@echo "Created $(APP_NAME).dmg"
