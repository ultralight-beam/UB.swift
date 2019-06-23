.PHONY: documentation test link xcode

test:
	swift test

lint:
	swiftlint

documentation:
	jazzy
	rm -rf build/

xcode:
	swift package generate-xcodeproj