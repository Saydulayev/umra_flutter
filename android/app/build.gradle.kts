import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore properties
val keystoreProperties = Properties()
val keystorePropertiesFile = file("../key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

android {
    namespace = "saydulayev.wien_gmail.com.umra"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "saydulayev.wien_gmail.com.umra"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Release signing only when key.properties exists — avoids breaking debug builds
    // when switching branches (files are gitignored on main/feature branches).
    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
                val storeFileProp = keystoreProperties["storeFile"] as String?
                storeFile = storeFileProp?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String?

                val requiredProperties = mapOf(
                    "keyAlias" to keyAlias,
                    "keyPassword" to keyPassword,
                    "storeFile" to storeFile,
                    "storePassword" to storePassword
                )
                val missingProperties = requiredProperties.filter {
                    it.value == null || (it.key == "storeFile" && !file(storeFileProp ?: "").exists())
                }

                if (missingProperties.isNotEmpty()) {
                    throw GradleException(
                        """
                        ╔══════════════════════════════════════════════════════════════╗
                        ║  ERROR: Missing or invalid keystore properties!             ║
                        ║                                                              ║
                        ║  Missing properties: ${missingProperties.keys.joinToString(", ")}  ║
                        ║                                                              ║
                        ║  Please ensure all required properties are set in           ║
                        ║  android/key.properties:                                     ║
                        ║  - storePassword                                            ║
                        ║  - keyPassword                                              ║
                        ║  - keyAlias                                                 ║
                        ║  - storeFile (and that the keystore file exists)            ║
                        ╚══════════════════════════════════════════════════════════════╝
                        """.trimIndent()
                    )
                }
            }
        }
    }

    buildTypes {
        release {
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
