plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.driver"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.driver"
        multiDexEnabled = true
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    implementation("com.google.android.gms:play-services-maps:18.1.0")
    implementation("com.google.android.gms:play-services-location:21.0.1")

    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}

/* ✅ FINAL MAPBOX FIX — NO MORE DUPLICATES */
configurations.all {


    configurations.all {
        exclude(group = "com.mapbox.common", module = "okhttp")
    }

    resolutionStrategy {

        // ✅ MAPS (NDK)
        force("com.mapbox.maps:android-ndk27:11.20.2")
        force("com.mapbox.maps:base-ndk27:11.20.2")

        // ✅ PLUGINS (NDK)
        force("com.mapbox.plugin:maps-annotation-ndk27:11.20.2")
        force("com.mapbox.plugin:maps-animation-ndk27:11.20.2")
        force("com.mapbox.plugin:maps-attribution-ndk27:11.20.2")
        force("com.mapbox.plugin:maps-compass-ndk27:11.20.2")
        force("com.mapbox.plugin:maps-gestures-ndk27:11.20.2")

        // 🚫 CLEAN TRANSITIVE DEPENDENCIES
        eachDependency {
            val version = requested.version?.toString()

            if (requested.group == "com.mapbox.maps" && version?.startsWith("10") == true) {
                useTarget("${requested.group}:${requested.name}-ndk27:11.20.2")
            }

            if (requested.group == "com.mapbox.plugin" && version?.startsWith("10") == true) {
                useTarget("${requested.group}:${requested.name}-ndk27:11.20.2")
            }

            if (requested.group == "com.mapbox.common" && requested.name == "common") {
                useTarget("com.mapbox.common:common-ndk27:24.20.2")
            }
        }
    }
}