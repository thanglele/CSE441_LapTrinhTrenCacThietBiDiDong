pluginManagement {
    fun getProperty(file: java.io.File, key: String): String? {
        if (!file.exists()) {
            return null
        }
        val properties = java.util.Properties()
        java.io.FileInputStream(file).use { fis ->
            properties.load(fis)
        }
        return properties.getProperty(key)
    }

    val localPropertiesFile = java.io.File(settings.rootDir.parentFile, "local.properties")
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    if (flutterSdkPath == null || flutterSdkPath.isEmpty()) {
        throw org.gradle.api.GradleException(
            "Flutter SDK not found. Please create a local.properties file in the root of your project " +
                    "and add a line like 'flutter.sdk=C:\\path\\to\\your\\flutter\\sdk'"
        )
    }

    repositories {
        maven(url = "$flutterSdkPath/packages/flutter_tools/gradle")
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
//    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.4.1" apply false
    id("org.jetbrains.kotlin.android") version "1.9.23" apply false
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
