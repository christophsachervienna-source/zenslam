-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivity$g
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider
-dontwarn kotlinx.parcelize.Parceler$DefaultImpls
-dontwarn kotlinx.parcelize.Parceler
-dontwarn kotlinx.parcelize.Parcelize

# ===== AUDIO SERVICE RULES =====
# Keep audio_service plugin classes
-keep class com.ryanheise.audioservice.** { *; }

# Keep audio_session plugin classes  
-keep class com.ryanheise.audiosession.** { *; }

# Keep just_audio plugin classes
-keep class com.ryanheise.just_audio.** { *; }

# Keep audioplayers plugin classes
-keep class xyz.luan.audioplayers.** { *; }

# Keep Flutter plugin registrant
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }

# Keep Android MediaSession and related classes
-keep class android.support.v4.media.** { *; }
-keep class androidx.media.** { *; }
-keep class androidx.media2.** { *; }

# Prevent R8 from stripping interface information
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# Keep classes that are accessed via reflection
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod