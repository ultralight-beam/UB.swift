.PHONY: docs format test lint xcode linuxmain autocorrect clean test build

APP="UB"
CONSTRUCT=xcodebuild -workspace $(APP).xcworkspace -scheme $(APP)-Package clean

# Apple
ifeq ($(shell uname),Darwin)
	PLATFORM=apple
	XCPRETTY_STATUS=$(shell xcpretty -v &>/dev/null; echo $$?)
	ifeq ($(XCPRETTY_STATUS),0)
		XCPRETTY=xcpretty
	else
		XCPRETTY=cat
	endif
endif

install_deps:
	swift package resolve
ifneq ($(XCPRETTY_STATUS),0)
	@echo "xcpretty not found: Run \`gem install xcpretty\` for nicer xcodebuild output.\n"
endif

clean:
	rm -rf .build $(APP).xcodeproj $(APP).xcworkspace Package.pins Pods Podfile.lock

test: clean xcode install_deps
	$(CONSTRUCT) test | $(XCPRETTY)

build: clean xcode install_deps
	$(CONSTRUCT) build | $(XCPRETTY)

lint:
	swiftlint

autocorrect:
	swiftlint autocorrect

docs:
	jazzy --author "Ultralight Beam" --author_url http://ultralightbeam.io  --github_url https://github.com/ultralight-beam/UB.swift
	rm -rf build/

xcode:
	swift package generate-xcodeproj

linuxmain:
	swift test --generate-linuxmain

format:
	swiftformat .
