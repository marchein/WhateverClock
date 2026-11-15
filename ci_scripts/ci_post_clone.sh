#!/bin/sh
# Xcode Cloud: generate the Xcode project from project.yml after cloning.
set -e
brew install xcodegen
cd "$CI_PRIMARY_REPOSITORY_PATH"
xcodegen generate
