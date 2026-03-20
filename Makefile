APP_NAME := Claude Shine
BUNDLE_NAME := ClaudeShine.app
BUILD_DIR := build
INSTALL_DIR := /Applications

.PHONY: build install uninstall clean

build:
	xcodebuild \
		-project ClaudeShine.xcodeproj \
		-scheme ClaudeShine \
		-configuration Release \
		-derivedDataPath $(BUILD_DIR) \
		build
	@echo "\nBuild complete: $(BUILD_DIR)/Build/Products/Release/$(BUNDLE_NAME)"

install: build
	cp -R "$(BUILD_DIR)/Build/Products/Release/$(BUNDLE_NAME)" "$(INSTALL_DIR)/$(BUNDLE_NAME)"
	@echo "Installed to $(INSTALL_DIR)/$(BUNDLE_NAME)"
	@echo "Opening $(APP_NAME)…"
	open "$(INSTALL_DIR)/$(BUNDLE_NAME)"

uninstall:
	-osascript -e 'tell application "Claude Shine" to quit' 2>/dev/null
	rm -rf "$(INSTALL_DIR)/$(BUNDLE_NAME)"
	@echo "Uninstalled $(APP_NAME)"

clean:
	rm -rf $(BUILD_DIR)
	@echo "Cleaned build artifacts"
