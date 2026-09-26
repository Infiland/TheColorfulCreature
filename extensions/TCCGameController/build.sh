#!/bin/sh
set -eu
cd "$(dirname "$0")"
xcrun clang++ -std=c++17 -fobjc-arc -mmacosx-version-min=12.0 -arch arm64 -arch x86_64 -dynamiclib TCCGameController.mm -framework GameController -framework AppKit -install_name @rpath/libTCCGameController.dylib -o libTCCGameController.dylib
if [ "${1:-}" = "--self-check" ]; then
    test_binary=$(mktemp -t tcc-controller-check)
    trap 'rm -f "$test_binary"' EXIT
    xcrun clang++ -std=c++17 -fobjc-arc -mmacosx-version-min=12.0 -DTCC_CONTROLLER_SELF_CHECK TCCGameController.mm -framework GameController -framework AppKit -o "$test_binary"
    "$test_binary"
fi
