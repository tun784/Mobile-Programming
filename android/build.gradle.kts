// Đầu file: thêm repositories
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Chuyển thư mục build ra ngoài nếu cần
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)

    project.evaluationDependsOn(":app")
}

// Task clean
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// buildscript phải được đặt ở đầu hoặc cuối, ví dụ ở cuối như bạn dùng:
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.3.1") // hoặc phiên bản bạn dùng
        classpath("com.google.gms:google-services:4.3.15") // Plugin Google Services
    }
}
