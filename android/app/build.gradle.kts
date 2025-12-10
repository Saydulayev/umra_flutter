import java.util.Properties

plugins {
    id("com.android.application")
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

    signingConfigs {
        create("release") {
            // Validate keystore properties for release builds
            if (!keystorePropertiesFile.exists()) {
                throw GradleException(
                    """
                    ╔══════════════════════════════════════════════════════════════╗
                    ║  ERROR: key.properties file is missing!                     ║
                    ║                                                              ║
                    ║  This file is required for signing release builds.          ║
                    ║  Expected location: android/key.properties                  ║
                    ║                                                              ║
                    ║  Please create the file with the following content:         ║
                    ║  storePassword=YOUR_STORE_PASSWORD                          ║
                    ║  keyPassword=YOUR_KEY_PASSWORD                              ║
                    ║  keyAlias=YOUR_KEY_ALIAS                                    ║
                    ║  storeFile=YOUR_KEYSTORE_FILE_PATH                          ║
                    ╚══════════════════════════════════════════════════════════════╝
                    """.trimIndent()
                )
            }
            
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            val storeFileProp = keystoreProperties["storeFile"] as String?
            storeFile = storeFileProp?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
            
            // Validate that all required properties are present
            val requiredProperties = mapOf(
                "keyAlias" to keyAlias,
                "keyPassword" to keyPassword,
                "storeFile" to storeFile,
                "storePassword" to storePassword
            )
            val missingProperties = requiredProperties.filter { it.value == null || (it.key == "storeFile" && !file(storeFileProp ?: "").exists()) }
            
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

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
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
    implementation("androidx.activity:activity-ktx:1.9.2")
    implementation("androidx.core:core-ktx:1.13.1")
}
