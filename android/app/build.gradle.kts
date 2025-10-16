// android/app/build.gradle.kts
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // ✅ AGREGAR ESTE PLUGIN
}

android {
    namespace = "koa.empresa.com"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // ⬇️ CAMBIOS AQUÍ: Usa Java 1.8 para la compatibilidad de desugaring ⬇️
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        // ⬇️ NUEVA LÍNEA: Habilitar el desugaring para bibliotecas modernas ⬇️
        isCoreLibraryDesugaringEnabled = true 
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8.toString() // ⬇️ AJUSTAR A 1.8 TAMBIÉN ⬇️
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "koa.empresa.com" // 🔥 IMPORTANTE: Este debe coincidir con Firebase
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // ✅ AGREGAR PARA FIREBASE (Ya está, pero es crucial)
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            
            // ✅ AGREGAR PARA PRODUCCIÓN
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        
        debug {
            signingConfig = signingConfigs.getByName("debug")
            // ✅ PARA DESARROLLO
            isMinifyEnabled = false
        }
    }
    
    // ✅ AGREGAR ESTA SECCIÓN PARA FIREBASE
    packagingOptions {
        resources {
            excludes += setOf(
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/license.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt",
                "META-INF/notice.txt",
                "META-INF/AL2.0",
                "META-INF/LGPL2.1"
            )
        }
    }
}

flutter {
    source = "../.."
}

// ✅ AGREGAR DEPENDENCIAS DE FIREBASE
dependencies {
    // ⬇️ NUEVA LÍNEA: DEPENDENCIA DE DESUGARING PARA flutter_local_notifications ⬇️
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    // ⬆️ FIN DE LA LÍNEA ⬆️

    implementation(platform("com.google.firebase:firebase-bom:32.7.0")) // ✅ BOM para versiones consistentes
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-storage")
    
    // Para evitar el error 64K method limit (Ya está)
    implementation("androidx.multidex:multidex:2.0.1")
    
    // Dependencias básicas de Android
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
}
