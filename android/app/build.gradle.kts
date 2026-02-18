import java.util.Properties
plugins {
    id("com.android.application")
    // Firebase (for push notifications only)
    id("com.google.gms.google-services")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystoreFile = rootProject.file("key.properties")
val hasKeyProperties = keystoreFile.exists()
if (hasKeyProperties) {
    keystoreProperties.load(keystoreFile.inputStream())
}

android {
    namespace = "com.zenslam.app"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.zenslam.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
        ndk {
            abiFilters += listOf("arm64-v8a", "x86_64")
        }
    }

     signingConfigs {
        if (hasKeyProperties) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
             if (hasKeyProperties) {
             signingConfig = signingConfigs.getByName("release")
           } else {
             signingConfig = signingConfigs.getByName("debug")
        }
            
            // Enable R8 shrinking but use proguard rules to keep audio classes
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    configurations.all {
        resolutionStrategy {
            force("androidx.activity:activity-compose:1.9.3")
            force("androidx.activity:activity-ktx:1.9.3")
            force("androidx.activity:activity:1.9.3")
        }
    }

    dependencies {
        implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.24")
        implementation("com.google.android.material:material:1.12.0")
        coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    }
}

flutter {
    source = "../.."
}
