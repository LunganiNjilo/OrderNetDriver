pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()

        // ✅ MAPBOX (safe token usage)
        maven {
            url = uri("https://api.mapbox.com/downloads/v2/maven")
            credentials {
                username = "mapbox"
                password = providers.gradleProperty("MAPBOX_DOWNLOADS_TOKEN").orNull
            }
        }
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.3" apply false
    id("com.google.gms.google-services") version("4.3.15") apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

dependencyResolutionManagement {
    // ❌ REMOVE PREFER_SETTINGS (this was breaking everything)

    repositories {
        google()
        mavenCentral()

        // ✅ REQUIRED FOR FLUTTER ENGINE (THIS WAS MISSING)
        maven {
            url = uri("$rootDir/../flutter/bin/cache/artifacts/engine/android")
        }

        // ✅ MAPBOX REPO
        maven {
            url = uri("https://api.mapbox.com/downloads/v2/maven")
            credentials {
                username = "mapbox"
                password = providers.gradleProperty("MAPBOX_DOWNLOADS_TOKEN").orNull
            }
        }
    }
}

include(":app")