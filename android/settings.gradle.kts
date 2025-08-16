import java.util.Properties
import java.io.FileInputStream

// Read local.properties (flutter.sdk), fallback to env FLUTTER_ROOT
val localProps = Properties()
val localPropsFile = File(rootDir, "local.properties")
if (localPropsFile.exists()) {
    FileInputStream(localPropsFile).use { localProps.load(it) }
}
val flutterSdkPath: String = (
    localProps.getProperty("flutter.sdk")
        ?: System.getenv("FLUTTER_ROOT")
        ?: throw GradleException("flutter.sdk not set in local.properties and FLUTTER_ROOT env is empty")
)

pluginManagement {
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // Ezek a verziók igazodnak a runneren lévő AGP-hez/Kotlinhoz
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "1.9.24" apply false
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "android"
include(":app")
