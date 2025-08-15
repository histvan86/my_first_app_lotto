plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.histvan86.my_first_app_lotto"       // <<< egyezzen a Firebase app package neveddel
    compileSdk = 34
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.histvan86.my_first_app_lotto" // <<< egyezzen a Firebase app package neveddel
        minSdk = 23
        targetSdk = 34
        versionCode = 9
        versionName = "1.0.9"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        release {
            // Első körben debug-keystore-ral írunk alá, App Distributionhöz elég
            signingConfig = signingConfigs.getByName("debug")
            // Ha Playre mész:
            // isMinifyEnabled = true
            // proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase BOM – nem kell egyesével verziózni a Firebase csomagokat
    implementation(platform("com.google.firebase:firebase-bom:34.0.0"))
    implementation("com.google.firebase:firebase-analytics-ktx")
    // Később ide veheted fel:
    // implementation("com.google.firebase:firebase-auth-ktx")
    // implementation("com.google.firebase:firebase-crashlytics-ktx")
}
