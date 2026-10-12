# ===== CycloScore — règles ProGuard/R8 =====

# ---- Capacitor (core + plugins) ----
-keep public class com.getcapacitor.** { *; }
-keep public class * extends com.getcapacitor.Plugin
-keep @com.getcapacitor.annotation.CapacitorPlugin public class * { *; }
-keepclassmembers class * extends com.getcapacitor.Plugin {
    @com.getcapacitor.PluginMethod public <methods>;
}
-keepclassmembers class * {
    @com.getcapacitor.annotation.PermissionCallback <methods>;
    @com.getcapacitor.annotation.ActivityCallback <methods>;
    @com.getcapacitor.annotation.Permission <methods>;
}

# ---- Cordova (plugins ponts) ----
-keep class org.apache.cordova.** { *; }
-dontwarn org.apache.cordova.**

# ---- Interface JavaScript WebView ----
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# ---- Google AdMob / Play Services ----
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.android.gms.common.** { *; }
-dontwarn com.google.android.gms.**

# ---- Attributs utiles (annotations, JS interface, generics) ----
-keepattributes *Annotation*
-keepattributes JavascriptInterface
-keepattributes Signature, Exceptions, InnerClasses, EnclosingMethod
