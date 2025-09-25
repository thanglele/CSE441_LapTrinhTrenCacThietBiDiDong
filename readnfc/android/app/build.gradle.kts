plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.lele.readnfc"
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
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.lele.readnfc"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    packaging {
        resources {
            excludes += setOf(
                "META-INF/versions/**",
                "META-INF/AL2.0",
                "META-INF/LGPL2.1"
            )
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

dependencies {
    implementation("org.jmrtd:jmrtd:0.8.2")                // mới nhất từ JMRTD :contentReference[oaicite:0]{index=0}
    implementation("net.sf.scuba:scuba-sc-android:0.0.26") // mới nhất từ SCUBA SC Android :contentReference[oaicite:1]{index=1}
    // implementation("org.bouncycastle:bcprov-jdk15on:1.70")  // nếu bạn vẫn muốn dùng bản “jdk15on” :contentReference[oaicite:2]{index=2}
    implementation("org.bouncycastle:bcprov-jdk18on:1.82")  // tốt hơn nếu có thể chuyển qua “jdk18on” mới hơn :contentReference[oaicite:3]{index=3}
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.10.2") // mới nhất từ Coroutines Android :contentReference[oaicite:4]{index=4}
}
