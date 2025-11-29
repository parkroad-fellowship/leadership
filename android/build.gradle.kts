allprojects {
    repositories {
        google()
        mavenCentral()
    }

    // Force namespace on all plugins
    subprojects {
        afterEvaluate {
            if (hasProperty("android")) {
                extensions.findByType<com.android.build.gradle.BaseExtension>()?.apply {
                    if (namespace == null) {
                        namespace = project.group.toString()
                    }
                }
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()

rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

// Force compileSdkVersion and targetSdkVersion for all Android library/app projects
subprojects {
    // helper to configure Android DSL safely
    fun configureAndroid(p: Project) {
        if (p.plugins.hasPlugin("com.android.library") || p.plugins.hasPlugin("com.android.application")) {
            try {
                p.extensions.findByType<com.android.build.gradle.BaseExtension>()?.apply {
                    // Support both older and newer AGP DSLs by attempting both properties.
                    compileSdkVersion(36)

                    // also set targetSdk / targetSdkVersion where available
                    defaultConfig.targetSdk = 36
                }
            } catch (e: Exception) {
                // fail-safe: some subprojects may not expose android DSL in time — ignore
                logger.debug("Could not force compileSdk/targetSdk for project ${p.name}: ${e.message}")
            }
        }
    }

    // Check if project is already evaluated; if so, configure immediately
    // Otherwise, schedule for afterEvaluate
    if (state.executed) {
        configureAndroid(this)
    } else {
        afterEvaluate {
            configureAndroid(this)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
