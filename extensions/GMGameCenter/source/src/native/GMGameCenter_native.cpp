#include "GMGameCenter_native.h"

using namespace gm::wire;
using namespace gm_structs;
using namespace gm_enums;

// Intentionally empty. The extension targets iOS and macOS only (copyToTargets = macOS | iOS).
// On macOS the CMake APPLE branch compiles both native/*.mm and native/*.cpp, so the real
// gamecenter_* implementations live in GMGameCenter_macos.mm; defining any of them here as well
// would be a duplicate symbol at link time. Desktop/Android targets are not built for this
// extension, so no platform stubs are required.
