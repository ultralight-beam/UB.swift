.PHONY: docs format test lint xcode linuxmain autocorrect wipe test build

APP="UB"
CONSTRUCT=xcodebuild -workspace $(APP).xcworkspace -scheme $(APP)-Package clean

install_deps:
	pod install

wipe:
	rm -rf .build $(APP).xcodeproj $(APP).xcworkspace Package.pins Pods Podfile.lock

test: wipe xcode install_deps
	$(CONSTRUCT) test | xcpretty

build: wipe xcode install_deps
	$(CONSTRUCT) build | xcpretty

lint:
	swiftlint

autocorrect:
	swiftlint autocorrect

docs:
	jazzy --author "Ultralight Beam" --author_url http://ultralightbeam.io  --github_url https://github.com/ultralight-beam/UB.swift
	rm -rf build/

xcode:
	swift package resolve
	swift package generate-xcodeproj

linuxmain:
	swift test --generate-linuxmain

format:
	swiftformat .
