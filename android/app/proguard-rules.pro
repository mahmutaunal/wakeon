# ============================================================================
# Wakeon - R8 / ProGuard Rules
# ============================================================================

# ----------------------------------------------------------------------------
# Flutter embedding and plugin registration
# ----------------------------------------------------------------------------
# Keep Flutter embedding entry points and generated plugin registrant.
# These classes are accessed from Android framework / Flutter engine paths.

-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# ----------------------------------------------------------------------------
# Flutter plugins used by Wakeon
# ----------------------------------------------------------------------------
# Keep only plugin packages that are used through platform channels or Android
# reflection paths. Avoid keeping all Flutter plugin classes globally.

# file_picker
-keep class com.mr.flutter.plugin.filepicker.** { *; }

# network_info_plus
-keep class dev.fluttercommunity.plus.network_info.** { *; }

# shared_preferences_android
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# flutter_native_splash
-keep class net.jonhanson.flutter_native_splash.** { *; }

# flutter_launcher_icons does not need runtime keep rules.

# ----------------------------------------------------------------------------
# Kotlin / annotations metadata
# ----------------------------------------------------------------------------
# Preserve metadata and annotations required by Kotlin/Android tooling.

-keep class kotlin.Metadata { *; }
-keepattributes *Annotation*,InnerClasses,EnclosingMethod

# ----------------------------------------------------------------------------
# Debuggability and crash readability
# ----------------------------------------------------------------------------
# Keep line numbers/source info so release crashes are still readable.
# This does not prevent shrinking or obfuscation.

-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# ----------------------------------------------------------------------------
# Flutter deferred components / Play Core optional references
# ----------------------------------------------------------------------------
# Flutter embedding contains optional references to Play Core deferred component
# APIs. Wakeon does not use Play Feature Delivery or deferred components.
# These references are optional and can be ignored safely by R8.

-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# ----------------------------------------------------------------------------
# Dependency warning hygiene
# ----------------------------------------------------------------------------
# Keep release builds strict. Add narrow -dontwarn rules here only when a real
# release build fails because of optional dependency references.
# ----------------------------------------------------------------------------