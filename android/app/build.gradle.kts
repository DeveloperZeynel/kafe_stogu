import java.util.Properties
import java.io.FileInputStream

plugins {
id("com.android.application")
id("kotlin-android")

// Flutter Gradle Plugin
// Android ve Kotlin pluginlerinden sonra uygulanmalıdır.
id("dev.flutter.flutter-gradle-plugin")

}

// =========================================================
// KEYSTORE
//
// android/key.properties dosyasından
// release imza bilgilerini okur.
// =========================================================

val keystoreProperties = Properties()

val keystorePropertiesFile =
rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
keystoreProperties.load(
FileInputStream(
keystorePropertiesFile
)
)
}

android {

// =====================================================
// APPLICATION
// =====================================================

namespace = "com.example.kafe_stogu"

compileSdk = 37

ndkVersion = flutter.ndkVersion


// =====================================================
// JAVA
// =====================================================

compileOptions {

    sourceCompatibility =
        JavaVersion.VERSION_17

    targetCompatibility =
        JavaVersion.VERSION_17

}


// =====================================================
// KOTLIN
// =====================================================

kotlinOptions {

    jvmTarget =
        JavaVersion.VERSION_17.toString()

}


// =====================================================
// DEFAULT CONFIG
// =====================================================

defaultConfig {

    // Google Play için ileride benzersiz bir
    // applicationId kullanacağız.
    applicationId =
        "com.example.kafe_stogu"

    minSdk =
        flutter.minSdkVersion

    targetSdk =
        flutter.targetSdkVersion

    versionCode =
        flutter.versionCode

    versionName =
        flutter.versionName

}


// =====================================================
// SIGNING CONFIG
// =====================================================

signingConfigs {

    create("release") {

        keyAlias =
            keystoreProperties["keyAlias"]
                as String

        keyPassword =
            keystoreProperties["keyPassword"]
                as String

        storeFile =
            keystoreProperties["storeFile"]
                ?.let {
                    file(it)
                }

        storePassword =
            keystoreProperties["storePassword"]
                as String

    }

}


// =====================================================
// BUILD TYPES
// =====================================================

buildTypes {

    release {

        // Release APK ve AAB artık
        // kendi keystore'umuz ile imzalanacak.
        signingConfig =
            signingConfigs.getByName(
                "release"
            )

    }

}

}

// =========================================================
// FLUTTER
// =========================================================

flutter {

source = "../.."

}