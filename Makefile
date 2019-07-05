.PHONY: documentation test link xcode linuxmain

test:
	swift test

lint:
	swiftlint

documentation:
	jazzy --author "Ultralight Beam" --author_url http://ultralightbeam.io  --github_url https://github.com/ultralight-beam/UB.swift
	rm -rf build/

xcode:
	swift package generate-xcodeproj

linuxmain:
	swift test --generate-linuxmain
