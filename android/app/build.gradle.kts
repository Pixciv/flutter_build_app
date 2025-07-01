plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Flutter plugin en sonda kalmalı
}

android {
    // namespace ve applicationId workflow içinde sed ile güncelleniyor
    namespace = "com.kina.night"

    compileSdk = flutter.compileSdkVersion

    // Hata çözümleri için sabit ndkVersion ekleniyor
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.kina.night"

        // minSdk versiyonu 23 olarak yükseltildi
        minSdk = 23

        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        debug {
            // Debug build için minify ve shrinkResources kapalı, böylece hata olmaz
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("debug")
        }
        release {
            // Release için minify ve shrinkResources isteğe bağlı, örnek olarak açıldı
            signingConfig = signingConfigs.getByName("debug") // production için değiştir
            isMinifyEnabled = true
            isShrinkResources = true
        }
    }
}

flutter {
    source = "../.."
}
