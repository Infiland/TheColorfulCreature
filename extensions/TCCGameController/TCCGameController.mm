#import <AppKit/AppKit.h>
#import <GameController/GameController.h>
#include <array>
#include <cassert>
#include <cmath>
#include <cstdint>

// Four stable local-player slots. Poll once per Begin Step, never per button read.
static GCController *controllers[4];
static std::array<uint16_t, 4> buttons{}, previous{};
static float axes[4][4]{};

static int slot(double value) {
    return std::isfinite(value) && value >= 0 && value < 4 && value == std::floor(value) ? (int)value : -1;
}

static void commit_buttons(int index, uint16_t value) {
    previous[index] = buttons[index];
    buttons[index] = value;
}

extern "C" double tcc_gc_poll() {
    void (^poll)(void) = ^{
        NSArray<GCController *> *available = GCController.controllers;
        for (int i = 0; i < 4; ++i) {
            if (controllers[i] && ![available containsObject:controllers[i]]) controllers[i] = nil;
        }
        for (GCController *controller in available) {
            if (!controller.extendedGamepad) continue;
            bool assigned = false;
            for (int i = 0; i < 4; ++i) assigned |= controllers[i] == controller;
            if (assigned) continue;
            for (int i = 0; i < 4; ++i) {
                if (controllers[i]) continue;
                controllers[i] = controller;
                controller.playerIndex = (GCControllerPlayerIndex)i;
                buttons[i] = previous[i] = 0;
                break;
            }
        }
        for (int i = 0; i < 4; ++i) {
            GCExtendedGamepad *pad = [controllers[i].extendedGamepad capture];
            uint16_t mask = 0;
            if (pad && NSApp.isActive) {
                GCControllerButtonInput *inputs[] = {pad.buttonA, pad.buttonB, pad.buttonX, pad.buttonY,
                    pad.leftShoulder, pad.rightShoulder, pad.leftTrigger, pad.rightTrigger,
                    pad.buttonOptions, pad.buttonMenu, pad.leftThumbstickButton, pad.rightThumbstickButton,
                    pad.dpad.up, pad.dpad.down, pad.dpad.left, pad.dpad.right};
                for (int j = 0; j < 16; ++j) if (inputs[j].value > 0.5f) mask |= (1u << j);
                axes[i][0] = pad.leftThumbstick.xAxis.value;
                axes[i][1] = -pad.leftThumbstick.yAxis.value;
                axes[i][2] = pad.rightThumbstick.xAxis.value;
                axes[i][3] = -pad.rightThumbstick.yAxis.value;
            } else {
                for (float &axis : axes[i]) axis = 0;
            }
            commit_buttons(i, mask);
        }
    };
    if (NSThread.isMainThread) poll(); else dispatch_sync(dispatch_get_main_queue(), poll);
    return 0;
}

extern "C" double tcc_gc_connected(double device) {
    int i = slot(device);
    return i >= 0 && controllers[i] != nil;
}

extern "C" double tcc_gc_button(double device, double button, double edge) {
    int i = slot(device);
    if (i < 0 || !std::isfinite(button) || button < 0 || button >= 16 || button != std::floor(button)) return 0;
    uint16_t mask = (1u << (int)button);
    if (edge == 1) return (buttons[i] & mask) && !(previous[i] & mask);
    if (edge == 2) return !(buttons[i] & mask) && (previous[i] & mask);
    return (buttons[i] & mask) != 0;
}

extern "C" double tcc_gc_axis(double device, double axis) {
    int i = slot(device), a = slot(axis);
    return i >= 0 && a >= 0 ? axes[i][a] : 0;
}

#ifdef TCC_CONTROLLER_SELF_CHECK
int main() {
    assert(tcc_gc_button(-1, 0, 0) == 0 && tcc_gc_axis(4, 0) == 0);
    commit_buttons(0, 1);
    assert(tcc_gc_button(0, 0, 1) == 1 && tcc_gc_button(0, 0, 0) == 1);
    commit_buttons(0, 1);
    assert(tcc_gc_button(0, 0, 1) == 0 && tcc_gc_button(0, 0, 0) == 1);
    commit_buttons(0, 0);
    assert(tcc_gc_button(0, 0, 2) == 1);
    commit_buttons(0, 0);
    assert(tcc_gc_button(0, 0, 2) == 0);
    commit_buttons(3, 1u << 15);
    assert(tcc_gc_button(3, 15, 0) == 1 && tcc_gc_button(0, 15, 0) == 0);
    puts("TCC_CONTROLLER_SELF_CHECK_PASS");
}
#endif
