.PHONY: documentation test link

test:
	swift test

lint:
	swiftlint

documentation:
	jazzy
	rm -rf build/

