plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Flutter plugin en sonda kalmalı
}

android {
    // namespace ve applicationId workflow içinde sed ile güncelleniyor
    namespace = "com.kina.night"

    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.kina.night"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Eğer release için debug imzası kullanıyorsan, ileride production için değiştir
            signingConfig = signingConfigs.getByName("debug")
            // Proguard/R8 için ayar burada (isteğe bağlı)
            isMinifyEnabled = false
        }
    }
}

flutter {
    source = "../.."
}
