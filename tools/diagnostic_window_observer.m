#import <AppKit/AppKit.h>
#import <CoreGraphics/CoreGraphics.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>

static volatile sig_atomic_t observerStopped = 0;
static void stopObserver(int signalNumber) { (void)signalNumber; observerStopped = 1; }

// Observe this task's diagnostic apps without hiding, activating or otherwise
// changing them. A separate observer prevents the quiet-launch probe from
// accidentally making its own visibility/activation assertions true.
int main(int argc, const char *argv[]) {
    if (argc != 3) return 2;
    signal(SIGTERM, stopObserver);
    signal(SIGINT, stopObserver);
    @autoreleasepool {
        NSString *root = [[[NSString stringWithUTF8String:argv[1]] stringByStandardizingPath] stringByAppendingString:@"/"];
        double seconds = strtod(argv[2], NULL);
        if (![root hasSuffix:@"/TCC130/"] || seconds <= 0 || seconds > 7200) return 2;
        NSDate *end = [NSDate dateWithTimeIntervalSinceNow:seconds];
        NSMutableSet<NSNumber *> *seen = [NSMutableSet set];
        NSUInteger checks = 0, active = 0, visible = 0, nonbackground = 0, maximumConcurrent = 0;
        while (!observerStopped && [end timeIntervalSinceNow] > 0) {
            @autoreleasepool {
                NSArray *windows = CFBridgingRelease(CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID));
                NSUInteger concurrent = 0;
                for (NSRunningApplication *app in NSWorkspace.sharedWorkspace.runningApplications) {
                    NSString *path = app.executableURL.path.stringByStandardizingPath;
                    if (![path hasPrefix:root] || ![path hasSuffix:@"/The_Colorful_Creature.app/Contents/MacOS/The_Colorful_Creature"]) continue;
                    if (![app.bundleIdentifier isEqualToString:@"com.infiland.tcc.qa"]
                        && ![app.bundleIdentifier isEqualToString:@"com.infiland.tcc.check"]) continue;
                    ++concurrent;
                    [seen addObject:@(app.processIdentifier)]; ++checks;
                    if (app.active) ++active;
                    if (app.activationPolicy != NSApplicationActivationPolicyProhibited) ++nonbackground;
                    for (NSDictionary *window in windows) {
                        if ([window[(id)kCGWindowOwnerPID] intValue] == app.processIdentifier
                            && [window[(id)kCGWindowAlpha] doubleValue] > 0) ++visible;
                    }
                }
                maximumConcurrent = MAX(maximumConcurrent, concurrent);
            }
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.02]];
        }
        printf("{\"ownedProcesses\":%lu,\"checks\":%lu,\"activeChecks\":%lu,\"visibleWindowChecks\":%lu,\"nonBackgroundChecks\":%lu,\"maximumConcurrentOwnedProcesses\":%lu,\"observerChangesAppState\":false}\n",
            (unsigned long)seen.count, (unsigned long)checks, (unsigned long)active,
            (unsigned long)visible, (unsigned long)nonbackground, (unsigned long)maximumConcurrent);
    }
    return 0;
}
