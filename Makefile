PROJECT_NAME := OpencodeUsage
SCHEME := OpencodeUsage
BUILD_DIR := build
APP_BUNDLE := $(BUILD_DIR)/Build/Products/Debug/$(PROJECT_NAME).app

.PHONY: setup build run clean logs

setup:
	xcodegen generate

build: setup
	xcodebuild -project $(PROJECT_NAME).xcodeproj -scheme $(SCHEME) -configuration Debug -derivedDataPath $(BUILD_DIR) build

run: build
	open $(APP_BUNDLE)

clean:
	rm -rf $(PROJECT_NAME).xcodeproj $(BUILD_DIR)

logs:
	log stream --predicate 'subsystem == "com.wiscaksono.opencode-usage"' --level info
