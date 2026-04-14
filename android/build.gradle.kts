allprojects {
    repositories {
        google()
        mavenCentral()

    }
}
//plugins {
//    // Android Gradle Plugin
//    id ("com.android.application" )
//
//    // ✅ Update Kotlin plugin version here
//    id( "org.jetbrains.kotlin.android")
//    // Google services (for Firebase)
//    id ("com.google.gms.google-services" )
//
//    // Flutter Gradle plugin
//    id ("dev.flutter.flutter-gradle-plugin" )
//}


val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
