// Project-level Gradle (Kotlin DSL)

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Google Services plugin (legacy apply-hoz)
        classpath("com.google.gms:google-services:4.4.1")
    }
}

plugins {
    // Flutter plugin kezeli az AGP/Kotlin verziókat, itt ne erőltessünk mást
    id("dev.flutter.flutter-gradle-plugin") apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
