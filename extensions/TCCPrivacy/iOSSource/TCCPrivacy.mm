#import "TCCPrivacy.h"
#import <UserMessagingPlatform/UserMessagingPlatform.h>
#import <UIKit/UIKit.h>
extern UIViewController *g_controller;
@implementation TCCPrivacy
static NSInteger privacyState = 0;
static NSInteger consentFormState = 0;
- (double)tcc_consent_can_request_ads { return UMPConsentInformation.sharedInstance.canRequestAds ? 1 : 0; }
- (double)tcc_consent_present_if_required {
    if (consentFormState == 1) return 1;
    consentFormState = 1;
    dispatch_async(dispatch_get_main_queue(), ^{
        // UMP owns the required GDPR/IDFA form sequence and completes
        // immediately when no form is needed. GML never caches consent.
        [UMPConsentForm loadAndPresentIfRequiredFromViewController:g_controller completionHandler:^(NSError *error) {
            consentFormState = error ? -1 : 2;
        }];
    });
    return 1;
}
- (double)tcc_consent_form_state { return consentFormState; }
- (double)tcc_privacy_options_required {
    return UMPConsentInformation.sharedInstance.privacyOptionsRequirementStatus == UMPPrivacyOptionsRequirementStatusRequired ? 1 : 0;
}
- (double)tcc_privacy_options_show {
    if (privacyState == 1) return 0;
    privacyState = 1;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UMPConsentForm presentPrivacyOptionsFormFromViewController:g_controller completionHandler:^(NSError *error) {
            privacyState = error ? -1 : 2;
        }];
    });
    return 1;
}
- (double)tcc_privacy_options_state { return privacyState; }
- (double)tcc_safe_inset:(double)edge {
    UIView *view = g_controller.view;
    UIEdgeInsets i = view.safeAreaInsets;
    switch ((int)edge) {
        case 0: return i.left / MAX(1, view.bounds.size.width);
        case 1: return i.top / MAX(1, view.bounds.size.height);
        case 2: return i.right / MAX(1, view.bounds.size.width);
        default: return i.bottom / MAX(1, view.bounds.size.height);
    }
}
@end
