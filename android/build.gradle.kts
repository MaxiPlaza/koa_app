// Archivo de configuración global de Gradle (Android)
plugins {
    // Definición de plugins global (como google-services)
    id("com.google.gms.google-services") version "4.3.15" apply false
}

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Versión del plugin de Android Gradle (compatible con el Java 8 que ya configuramos)
        classpath("com.android.tools.build:gradle:8.1.0")
        
        // CORRECCIÓN: Definimos la versión de Kotlin directamente (1.8.20)
        // Esto resuelve el error de 'Unresolved reference: ext' y moderniza la compilación.
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.8.20")
        
        // Plugin de Google Services
        classpath("com.google.gms:google-services:4.3.15")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ⬇️ CORRECCIÓN: Usamos 'file(...)' para asignar una ruta (tipo File)
rootProject.buildDir = file("../build") 

subprojects {
    // ⬇️ CORRECCIÓN: Usamos 'file(...)' en la interpolación de strings para la ruta
    project.buildDir = file("${rootProject.buildDir}/${project.name}")
}
subprojects {
    // ⬇️ CORRECCIÓN: Usamos comillas dobles para el String ":app"
    project.evaluationDependsOn(":app")
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}