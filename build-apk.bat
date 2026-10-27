@echo off
setlocal enabledelayedexpansion

set "JAVA_HOME=C:\Users\DELL\.jdks\jbr-17.0.14"
set "ANDROID_HOME=C:\Users\DELL\AppData\Local\Android\Sdk"
set "PATH=%JAVA_HOME%\bin;%PATH%"

echo [1/3] Syncing Capacitor Android assets...
if not exist "android" (
    echo Adding Android platform...
    call npx cap add android
    if %errorlevel% neq 0 (
        echo Failed to add android platform!
        exit /b %errorlevel%
    )
)

call npx cap sync android
if %errorlevel% neq 0 (
    echo Sync failed!
    exit /b %errorlevel%
)

echo [2/3] Building Debug APK with Gradle...
cd android
call gradlew.bat assembleDebug
if %errorlevel% neq 0 (
    echo Gradle build failed!
    cd ..
    exit /b %errorlevel%
)
cd ..

echo [3/3] Copying APK to destination locations...
set "SRC_APK=android\app\build\outputs\apk\debug\app-debug.apk"
if exist "%SRC_APK%" (
    copy /Y "%SRC_APK%" "HauntedEscape.apk"
    if exist "E:\tuition_manager\extra apps" (
        copy /Y "%SRC_APK%" "E:\tuition_manager\extra apps\HauntedEscape.apk"
        echo Copied to E:\tuition_manager\extra apps\HauntedEscape.apk
    )
    echo Build and copy completed successfully!
) else (
    echo Error: Built APK not found at %SRC_APK%
    exit /b 1
)
