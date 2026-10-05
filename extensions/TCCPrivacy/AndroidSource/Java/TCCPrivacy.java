package ${YYAndroidPackageName};
import com.google.android.ump.ConsentInformation;
import com.google.android.ump.UserMessagingPlatform;
public class TCCPrivacy {
    private volatile int privacyState = 0;
    public double tcc_consent_can_request_ads() {
        return UserMessagingPlatform.getConsentInformation(RunnerActivity.CurrentActivity).canRequestAds() ? 1 : 0;
    }
    // The shared native function table includes this iOS-only form bridge.
    // Android continues using the existing GMAdMob consent callbacks.
    public double tcc_consent_present_if_required() { return 0; }
    public double tcc_consent_form_state() { return 2; }
    public double tcc_privacy_options_required() {
        return UserMessagingPlatform.getConsentInformation(RunnerActivity.CurrentActivity).getPrivacyOptionsRequirementStatus()
            == ConsentInformation.PrivacyOptionsRequirementStatus.REQUIRED ? 1 : 0;
    }
    public double tcc_privacy_options_show() {
        if (privacyState == 1) return 0;
        privacyState = 1;
        RunnerActivity.ViewHandler.post(() -> UserMessagingPlatform.showPrivacyOptionsForm(RunnerActivity.CurrentActivity,
            error -> privacyState = error == null ? 2 : -1));
        return 1;
    }
    public double tcc_privacy_options_state() { return privacyState; }
    public double tcc_safe_inset(double edge) {
        android.view.View view = RunnerActivity.CurrentActivity.getWindow().getDecorView();
        android.view.WindowInsets insets = view.getRootWindowInsets();
        if (insets == null) return 0;
        android.graphics.Insets bounds;
        if (android.os.Build.VERSION.SDK_INT >= 30) {
            bounds = insets.getInsets(android.view.WindowInsets.Type.systemBars() | android.view.WindowInsets.Type.displayCutout());
            switch ((int)edge) {
                case 0: return (double)bounds.left / Math.max(1, view.getWidth());
                case 1: return (double)bounds.top / Math.max(1, view.getHeight());
                case 2: return (double)bounds.right / Math.max(1, view.getWidth());
                default: return (double)bounds.bottom / Math.max(1, view.getHeight());
            }
        }
        return 0;
    }
}
