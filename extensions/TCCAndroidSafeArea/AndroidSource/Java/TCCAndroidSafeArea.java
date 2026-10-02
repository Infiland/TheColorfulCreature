package ${YYAndroidPackageName};

// Steam APK window geometry is independent of the advertising SDK.
public class TCCAndroidSafeArea {
    public double tcc_android_safe_inset(double edge) {
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
