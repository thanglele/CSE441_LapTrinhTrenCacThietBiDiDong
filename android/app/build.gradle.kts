import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
}

fun localProperties(): Properties {
    val properties = Properties()
    val localPropertiesFile = rootProject.file("local.properties")
    if (localPropertiesFile.exists()) {
        properties.load(FileInputStream(localPropertiesFile))
    }
    return properties
}

android {
    namespace = "com.lele.readnfc"
    compileSdk = 34
    ndkVersion = "25.1.8937393"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
    }

    defaultConfig {
        applicationId = "com.lele.readnfc"
        minSdk = 24
        targetSdk = 34
        versionCode = localProperties().getProperty("flutter.versionCode")?.toInt() ?: 1
        versionName = localProperties().getProperty("flutter.versionName") ?: "1.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Thư viện đọc và giải mã dữ liệu thẻ chip (CCCD, Passport)
    implementation("org.jmrtd:jmrtd:0.7.28")
    // Thư viện hỗ trợ giao tiếp thẻ thông minh trên Android
    implementation("net.sf.scuba:scuba-sc-android:0.0.21")
    // Thư viện mã hóa, cần thiết cho jmrtd
    implementation("org.bouncycastle:bcprov-jdk15on:1.78.1")
    // Hỗ trợ coroutines cho các tác vụ bất đồng bộ
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.1")
}