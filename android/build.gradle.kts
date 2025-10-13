// android/build.gradle.kts
plugins {
    id("com.google.gms.google-services") version "4.4.0" apply false // ✅ AGREGAR ESTA LÍNEA EXACTA
}

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.1.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.7.10")
        classpath("com.google.gms:google-services:4.4.0") // ✅ MANTENER TAMBIÉN AQUÍ
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = '../build'
subprojects {
    project.buildDir = "${rootProject.buildDir}/${project.name}"
}
subprojects {
    project.evaluationDependsOn(':app')
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}