import java.util.Properties

val envProperties = Properties()
val envFile = sequenceOf(
    project.rootProject.file("../.env"),
    project.rootProject.file(".env")
).firstOrNull { it.exists() }

if (envFile != null) {
    envFile.forEachLine { line ->
        if (line.isNotBlank() && !line.startsWith("#") && line.contains("=")) {
            val parts = line.split("=", limit = 2)
            envProperties.setProperty(parts[0].trim(), parts[1].trim())
        }
    }
}
val googleMapsApiKey = envProperties.getProperty("GOOGLE_MAPS_API_KEY")?.trim()?.takeIf { it.isNotEmpty() }
    ?: "AIzaSyA2_J7HSn0DmOrrTzBN5FJVJ23CeeUtmN4"

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "sg.com.zipbee.customer"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "sg.com.zipbee.customer"

        // REQUIRED by flutter_local_notifications
        minSdk = flutter.minSdkVersion

        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = googleMapsApiKey
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // 🔥 MUST be 2.1.4 or higher
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
