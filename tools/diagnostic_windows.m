#import <AppKit/AppKit.h>
#import <CoreGraphics/CoreGraphics.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

// Hide only this task's diagnostic applications. This is a window-management
// helper, not a headless renderer or a substitute for native gameplay events.
// It does not inject code, alter game state, or touch other applications.
static volatile sig_atomic_t stopped = 0;
static void stop(int signal_number) { stopped = 1; }

static NSUInteger visible_windows(pid_t pid) {
    NSArray *windows = CFBridgingRelease(CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID));
    NSUInteger count = 0;
    for (NSDictionary *window in windows) {
        if ([window[(id)kCGWindowOwnerPID] intValue] != pid) continue;
        if ([window[(id)kCGWindowAlpha] doubleValue] <= 0) continue;
        NSDictionary *bounds = window[(id)kCGWindowBounds];
        if ([bounds[@"Width"] doubleValue] > 1 && [bounds[@"Height"] doubleValue] > 1) ++count;
    }
    return count;
}

int main(int argc, const char *argv[]) {
    if (argc != 3) { fprintf(stderr, "usage: diagnostic-windows <owned-build-root> <seconds>\n"); return 2; }
    @autoreleasepool {
        NSString *root = [[[NSString stringWithUTF8String:argv[1]] stringByStandardizingPath] stringByAppendingString:@"/"];
        double duration = strtod(argv[2], NULL);
        if (duration <= 0 || duration > 172800 || ![root hasSuffix:@"/TCC130/"]) return 2;
        signal(SIGTERM, stop); signal(SIGINT, stop);
        NSDate *end = [NSDate dateWithTimeIntervalSinceNow:duration];
        NSMutableSet<NSNumber *> *seen = [NSMutableSet set];
        NSUInteger hidden = 0, checked = 0, remaining = 0;
        while (!stopped && [end timeIntervalSinceNow] > 0) {
            @autoreleasepool {
                for (NSRunningApplication *app in NSWorkspace.sharedWorkspace.runningApplications) {
                    NSString *path = app.executableURL.path.stringByStandardizingPath;
                    if (![path hasPrefix:root] || ![path hasSuffix:@"/The_Colorful_Creature.app/Contents/MacOS/The_Colorful_Creature"]) continue;
                    if (![app.bundleIdentifier isEqualToString:@"com.infiland.tcc.qa"]
                        && ![app.bundleIdentifier isEqualToString:@"com.infiland.tcc.check"]) continue;
                    NSNumber *pid = @(app.processIdentifier);
                    if (![seen containsObject:pid]) {
                        [seen addObject:pid];
                        fprintf(stdout, "diagnostic-window pid=%d observed\n", app.processIdentifier); fflush(stdout);
                    }
                    if (!app.hidden && [app hide]) ++hidden;
                    if (app.hidden) {
                        ++checked;
                        remaining += visible_windows(app.processIdentifier);
                    }
                }
            }
            // A run loop services AppKit's application-state notifications.
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
        fprintf(stdout, "{\"ownedProcesses\":%lu,\"hideRequests\":%lu,\"hiddenWindowChecks\":%lu,\"visibleAfterHide\":%lu,\"headless\":false}\n",
                (unsigned long)seen.count, (unsigned long)hidden, (unsigned long)checked, (unsigned long)remaining);
    }
    return 0;
}
