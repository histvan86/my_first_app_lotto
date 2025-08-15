// Project-level Gradle (Kotlin DSL) — hagyjuk, hogy a Flutter plugin állítsa a verziókat

plugins {
    // Ne deklarálj itt AGP/Kotlin verziókat, a Flutter plugin kezeli
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
