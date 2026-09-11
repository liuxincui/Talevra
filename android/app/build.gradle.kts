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
        applicationId = "com.talevra.talevra"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // 品牌维度 = 投放国家：每个 flavor 一个独立包名 + 默认语言 + en 兜底
    flavorDimensions += "brand"
    productFlavors {
        create("brand_us") {
            dimension = "brand"
            applicationIdSuffix = ".us"
            resValue("string", "app_name", "Talevra US")
            resourceConfigurations += listOf("en")
        }
        create("brand_br") {
            dimension = "brand"
            applicationIdSuffix = ".br"
            resValue("string", "app_name", "Talevra BR")
            resourceConfigurations += listOf("pt", "en")
        }
        create("brand_mx") {
            dimension = "brand"
            applicationIdSuffix = ".mx"
            resValue("string", "app_name", "Talevra MX")
            resourceConfigurations += listOf("es", "en")
        }
        create("brand_id") {
            dimension = "brand"
            applicationIdSuffix = ".id"
            resValue("string", "app_name", "Talevra ID")
            resourceConfigurations += listOf("id", "en")
        }
        create("brand_jp") {
            dimension = "brand"
            applicationIdSuffix = ".jp"
            resValue("string", "app_name", "Talevra JP")
            resourceConfigurations += listOf("ja", "en")
        }
        create("brand_kr") {
            dimension = "brand"
            applicationIdSuffix = ".kr"
            resValue("string", "app_name", "Talevra KR")
            resourceConfigurations += listOf("ko", "en")
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
