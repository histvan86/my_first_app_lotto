plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.my_first_app_lotto"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.histvan86.my_first_app_lotto"
        minSdk = 23 // 🔧 Ezt írd át 21-ről 23-ra
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // 🔧 Firebase BoM – verziókezelés
    implementation(platform("com.google.firebase:firebase-bom:34.0.0"))

    // 🔥 Firebase Analytics (KTX API-k már ebben vannak)
    implementation("com.google.firebase:firebase-analytics")

    // Ha szeretnél Auth-ot:
    // implementation("com.google.firebase:firebase-auth")
}


