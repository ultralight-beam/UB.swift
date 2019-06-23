.PHONY: documentation test link xcode

test:
	swift test

lint:
	swiftlint

documentation:
	jazzy --github_url https://github.com/ultralight-beam/UB.swift
	rm -rf build/

xcode:
	swift package generate-xcodeproj
