cmake_minimum_required(VERSION 3.18)

# -----------------------------------------------------------------------------
# Core "bag of usage requirements" the main target links to
# -----------------------------------------------------------------------------
add_library(ext_third_party INTERFACE)

# List of runtime files to bubble up to parent
set(_EXT_TP_RUNTIME_DLLS "")

# =============================================================================
# WINDOWS (MSVC/ClangCL)
# =============================================================================
if(WIN32)
# =============================================================================
# APPLE: split macOS vs iOS/tvOS
# =============================================================================
elseif(APPLE)
  # ----------------------
  # iOS (mobile)
  # ----------------------
  if(CMAKE_OSX_SYSROOT MATCHES "iphone")

    # GameKit is an Apple SYSTEM framework shipped inside the iOS SDK, so its
    # headers (#import <GameKit/GameKit.h>) resolve automatically with no -F
    # search path and no CocoaPods. We only need to link the framework so the
    # final app pulls in the GameKit symbols.
    #
    # Pass "-framework GameKit" as a SINGLE string. If "-framework" and
    # "GameKit" are given as two separate list items, CMake treats "GameKit"
    # as a plain library name and emits "-lGameKit", which the linker cannot
    # resolve (ld: framework '-lGameKit' not found).
    target_link_libraries(ext_third_party INTERFACE "-framework GameKit")

  # ----------------------
  # macOS (desktop)
  # ----------------------
  else()
    # The macOS desktop target is a standalone .dylib (not statically linked
    # into a GameMaker Xcode project like iOS), so it must pull in Foundation
    # and AppKit itself. AppKit provides NSApplication / NSWindow /
    # NSViewController, which the native implementation uses to present GameKit
    # dialogs via GKDialogController. Each framework is a SINGLE string for the
    # same reason as GameKit above.
    target_link_libraries(ext_third_party INTERFACE
      "-framework GameKit"
      "-framework Foundation"
      "-framework AppKit"
    )
  endif()

# =============================================================================
# ANDROID (not applicable for GameKit)
# =============================================================================
elseif(ANDROID)
# =============================================================================
# LINUX
# =============================================================================
elseif(UNIX)
endif()

# =============================================================================
# Bubble up runtime list to parent
# =============================================================================
set(EXT_TP_RUNTIME_DLLS "${_EXT_TP_RUNTIME_DLLS}" PARENT_SCOPE)
