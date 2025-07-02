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

        // targetSdk sabit 35 olarak ayarlandı (workflow'ta sed ile değiştirilmesin)
        targetSdk = 35

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
            // Release için minify ve shrinkResources açıldı
            isMinifyEnabled = true
            isShrinkResources = true
            // Proguard dosyaları eklenmeli:
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            // Burada release için kendi imzanı kullanmalısın:
            // signingConfig = signingConfigs.getByName("release")
            // Şu an debug imzası kullanılıyor, Google Play için release imzası ayarla!
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
