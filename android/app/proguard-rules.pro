# Flutter Proguard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.firebase.** { *; }

# android_alarm_manager_plus rules
-keep class dev.fluttercommunity.plus.androidalarmmanager.** { *; }

# workmanager rules
-keep class be.tarsos.dsp.** { *; }

# Keep the entry point classes
-keep class com.serat.app.serat.MainActivity { *; }

# Handle obfuscation for Dart entry points
-keepattributes Signature,Exceptions,*Annotation*
-keep class * extends firebase_messaging.FirebaseMessagingService { *; }

# Fix Play Core missing classes for R8
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.gms.internal.play_billing.** { *; }

# Audio Libraries Proguard Rules - Comprehensive
-keep class com.ryanheise.just_audio.** { *; }
-keep class com.ryanheise.audioservice.** { *; }
-keep class com.ryanheise.audio_session.** { *; }
-keep class com.ryanheise.audio_service.** { *; }
-keep class com.ryanheise.path_provider_android.** { *; }
-keep class io.flutter.plugins.pathprovider.** { *; }
-dontwarn com.ryanheise.**
-dontwarn io.flutter.plugins.pathprovider.**

# Quran Library Specific Rules
-keep class com.quran.library.** { *; }
-dontwarn com.quran.library.**

# Common Flutter Plugins Keep Rules
-keep class io.flutter.plugins.** { *; }
-keep class com.sidlatau.flutter_screenutil.** { *; }
-keep class com.baseflow.geocoding.** { *; }
-keep class com.baseflow.geolocator.** { *; }
-keep class dev.fluttercommunity.plus.** { *; }
