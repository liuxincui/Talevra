import java.util.Properties

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localProperties.load(localPropertiesFile.inputStream())
}

fun localString(name: String, defaultValue: String = ""): String =
    localProperties.getProperty(name, defaultValue)
        .replace("\\", "\\\\")
        .replace("\"", "\\\"")

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.talevra.talevra"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // The currently supplied VOD license is issued for this package.
        applicationId = "com.talevra.story"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        buildConfigField("String", "PSSDK_APP_ID", "\"${localString("pssdk.appId")}\"")
        buildConfigField("String", "PSSDK_VOD_APP_ID", "\"${localString("pssdk.vodAppId")}\"")
        buildConfigField("String", "PSSDK_SECURITY_KEY", "\"${localString("pssdk.securityKey")}\"")
        buildConfigField(
            "String",
            "PSSDK_LICENSE_ASSET_PATH",
            "\"${localString("pssdk.licenseAssetPath", "vod_player.lic")}\"",
        )
        buildConfigField("boolean", "PSSDK_DEBUG", localString("pssdk.debug", "false"))
    }

    buildFeatures {
        buildConfig = true
    }

    // 品牌维度 = 投放国家：每个 flavor 一个独立包名 + 默认语言 + en 兜底
    flavorDimensions += "brand"
    productFlavors {
        create("brand_us") {
            dimension = "brand"
            resValue("string", "app_name", "Talevra")
            resourceConfigurations += listOf("en")
        }
        create("brand_br") {
            dimension = "brand"
            applicationIdSuffix = ".br"
            resValue("string", "app_name", "Talevra")
            resourceConfigurations += listOf("pt", "en")
        }
        create("brand_mx") {
            dimension = "brand"
            applicationIdSuffix = ".mx"
            resValue("string", "app_name", "Talevra")
            resourceConfigurations += listOf("es", "en")
        }
        create("brand_id") {
            dimension = "brand"
            applicationIdSuffix = ".id"
            resValue("string", "app_name", "Talevra")
            resourceConfigurations += listOf("id", "en")
        }
        create("brand_jp") {
            dimension = "brand"
            applicationIdSuffix = ".jp"
            resValue("string", "app_name", "Talevra")
            resourceConfigurations += listOf("ja", "en")
        }
        create("brand_kr") {
            dimension = "brand"
            applicationIdSuffix = ".kr"
            resValue("string", "app_name", "Talevra")
            resourceConfigurations += listOf("ko", "en")
        }
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = (keystoreProperties["storeFile"] as String?)?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        debug {
            // 测试包保留可读的 Java/Kotlin 符号，便于调试和定位问题。
            isMinifyEnabled = false
            isShrinkResources = false
        }
        getByName("profile") {
            // Flutter profile 包用于性能测试，同样不做混淆，方便分析性能问题。
            isMinifyEnabled = false
            isShrinkResources = false
        }
        release {
            // 正式包显式开启 R8，避免依赖 Flutter/AGP 的默认值。
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )

            // Use the local upload key when key.properties is present. Keep the
            // debug fallback so a fresh checkout can still run a release build.
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }

}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("androidx.fragment:fragment:1.6.2")
    implementation("com.squareup.okhttp3:okhttp:4.2.1")
    implementation("androidx.viewpager2:viewpager2:1.0.0")
    implementation("com.github.bumptech.glide:glide:4.16.0")
    implementation("com.google.android.gms:play-services-ads-identifier:18.0.1")
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.3.61")
    implementation("com.bytedance.dramaverse:pssdk:2.0.0.0")
}
