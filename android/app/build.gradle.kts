plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.my_first_app_lotto"
    compileSdk = 33 // 🔧 Cseréld le a flutter.compileSdkVersion-t

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
        minSdk = 23
        targetSdk = 33 // 🔧 Cseréld le a flutter.targetSdkVersion-t
        versionCode = 7 // 🔧 Cseréld le a flutter.versionCode-t
        versionName = "1.0.7" // 🔧 Cseréld le a flutter.versionName-t
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:34.0.0"))
    implementation("com.google.firebase:firebase-analytics")
    // implementation("com.google.firebase:firebase-auth") // Ha kell Auth
}
