#import <AppKit/AppKit.h>
#import <objc/runtime.h>
#include <stdio.h>
#include <stdlib.h>

// Host-window policy for this task's isolated diagnostic app only. No engine,
// input, render, audio, movement, timing or game-state method is replaced.
static void quiet_void(id object, SEL selector) {}
static void quiet_sender(id object, SEL selector, id sender) {}
static void quiet_activate(id object, SEL selector, BOOL ignored) {}
static IMP original_order = NULL;
static void quiet_order(id object, SEL selector, NSWindowOrderingMode mode, NSInteger relative) {
    // Ordering a window out is allowed; ordering one onto the desktop is not.
    if (mode == NSWindowOut)
        ((void (*)(id, SEL, NSWindowOrderingMode, NSInteger))original_order)(object, selector, mode, relative);
}
static IMP original_policy = NULL;
static BOOL quiet_policy(id object, SEL selector, NSApplicationActivationPolicy policy) {
    return ((BOOL (*)(id, SEL, NSApplicationActivationPolicy))original_policy)(object, selector, NSApplicationActivationPolicyAccessory);
}
static void replace(Class type, const char *name, IMP implementation) {
    SEL selector = sel_registerName(name);
    Method method = class_getInstanceMethod(type, selector);
    if (!method) return;
    if (!class_addMethod(type, selector, implementation, method_getTypeEncoding(method)))
        method_setImplementation(class_getInstanceMethod(type, selector), implementation);
}

__attribute__((constructor)) static void install_quiet_policy(void) {
    if (!getenv("TCC_QA_QUIET") || strcmp(getenv("TCC_QA_QUIET"), "1")) return;
    @autoreleasepool {
        NSString *path = NSProcessInfo.processInfo.arguments.firstObject;
        NSString *root = [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/TCC130/"];
        NSString *bundle = NSBundle.mainBundle.bundleIdentifier;
        if (![path hasPrefix:root] || ![path hasSuffix:@"/The_Colorful_Creature.app/Contents/MacOS/The_Colorful_Creature"]
            || (![bundle isEqualToString:@"com.infiland.tcc.qa"] && ![bundle isEqualToString:@"com.infiland.tcc.check"])) return;
        Class application = objc_getClass("YYApplication");
        if (!application) application = NSApplication.class;
        original_policy = method_getImplementation(class_getInstanceMethod(application, @selector(setActivationPolicy:)));
        original_order = method_getImplementation(class_getInstanceMethod(NSWindow.class, @selector(orderWindow:relativeTo:)));
        replace(application, "setActivationPolicy:", (IMP)quiet_policy);
        replace(application, "activateIgnoringOtherApps:", (IMP)quiet_activate);
        replace(application, "activate", (IMP)quiet_void);
        replace(NSWindow.class, "makeKeyAndOrderFront:", (IMP)quiet_sender);
        replace(NSWindow.class, "orderFront:", (IMP)quiet_sender);
        replace(NSWindow.class, "orderFrontRegardless", (IMP)quiet_void);
        replace(NSWindow.class, "makeKeyWindow", (IMP)quiet_void);
        replace(NSWindow.class, "makeMainWindow", (IMP)quiet_void);
        replace(NSWindow.class, "orderWindow:relativeTo:", (IMP)quiet_order);
        fprintf(stderr, "TCC_DIAGNOSTIC_QUIET_READY: host activation/window ordering only\n");
    }
}
