# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Gson specific classes
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# just_audio
-keep class com.ryanheise.just_audio.** { *; }
-dontwarn com.ryanheise.just_audio.**

# audio_service
-keep class com.ryanheise.audioservice.** { *; }
-dontwarn com.ryanheise.audioservice.**

# flutter_local_notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# in_app_purchase
-keep class com.android.billingclient.** { *; }
-dontwarn com.android.billingclient.**
-keep class com.android.vending.billing.** { *; }
-dontwarn com.android.vending.billing.**

# shared_preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-dontwarn io.flutter.plugins.sharedpreferences.**

# path_provider
-keep class io.flutter.plugins.pathprovider.** { *; }
-dontwarn io.flutter.plugins.pathprovider.**

# url_launcher
-keep class io.flutter.plugins.urllauncher.** { *; }
-dontwarn io.flutter.plugins.urllauncher.**

# vibration
-keep class dev.fluttercommunity.plus.vibration.** { *; }
-dontwarn dev.fluttercommunity.plus.vibration.**

# sqflite
-keep class io.flutter.plugins.sqflite.** { *; }
-dontwarn io.flutter.plugins.sqflite.**

# pdf viewer
-keep class io.endigo.plugins.pdfviewflutter.** { *; }
-dontwarn io.endigo.plugins.pdfviewflutter.**

# Keep application class
-keep public class * extends android.app.Application

# Keep all model classes (if you have any)
-keep class * extends java.io.Serializable { *; }

# Preserve line numbers for debugging
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Google Play Core (for Flutter deferred components)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.splitcompat.** { *; }
-dontwarn com.google.android.play.core.splitcompat.**
-keep class com.google.android.play.core.splitinstall.** { *; }
-dontwarn com.google.android.play.core.splitinstall.**
-keep class com.google.android.play.core.tasks.** { *; }
-dontwarn com.google.android.play.core.tasks.**

