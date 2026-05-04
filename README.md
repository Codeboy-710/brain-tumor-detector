
# 🧠 Brain Tumor Detection App

An AI-powered Flutter application that detects brain tumors from MRI scans using a TensorFlow Lite model.  
The app provides real-time predictions, confidence scores, and detailed diagnostic reports.

---

## 📲 Download App (Only for Android as of now)

[![Download APK](https://img.shields.io/badge/Download-APK-blue?style=for-the-badge&logo=android)](https://github.com/Codeboy-710/brain-tumor-detector/releases/download/v1.0/app-release.apk)

---

## 🚀 Features

- 🧠 Brain tumor classification:
  - Glioma
  - Meningioma
  - Pituitary
  - No Tumor
  
- 📊 Confidence score visualization
- 📄 AI-generated scan report including:
  - Risk level
  - Symptoms
  - Causes
  - Treatment suggestions
  - Specialist recommendation
- 📷 Upload MRI via Camera / Gallery
- ⚡ Fast on-device inference (works offline)
- 🌙 Dark mode support
- 🎯 Clean and responsive Flutter UI

---

## 📸 Screenshots

<p align="center">
  <img src="screenshots/starting2.jpg" width="250"/>
  <img src="screenshots/home.jpg" width="250"/>
  <img src="screenshots/analysing.jpg" width="250"/>
  <img src="screenshots/Result.jpg" width="250"/>
  <img src="screenshots/Report.jpg" width="250"/>
</p>

---

## 🧠 Tech Stack

- **Frontend:** Flutter (Dart)
- **ML Model:** TensorFlow Lite
- **Architecture:** 
     - Dense-Net based CNN
     - Efficient-Net
     - U-Net
     - Mobile-Net
- **Languages:** Dart, Python

---

## 🧠 ML Pipeline / 📁 Implementation Details

The complete machine learning pipeline, including model training, preprocessing, and experimentation with multiple architectures, is available in the [ML codes/](./ML%20codes/) folder.

⚠️ Note: Please go through the README.md inside the ([ML codes/](./ML%20codes/)) directory for complete details of the ML pipeline and implementation. This contains important information about training, datasets, and model export.

---

## ⚙️ Setup (For Developers)

### 1. Clone the repository
```bash
git clone https://github.com/YOUR_USERNAME/brain-tumor-detector.git
cd brain-tumor-detector

```
### 2. Install dependencies
```bash
flutter pub get

```
### 3. Android setup (only first time)  
-Make sure Android SDK is installed and configured.  
If not, follow official guide:
https://flutter.dev/docs/get-started/install  
Then run :
```bash
flutter doctor --android-licenses  
```
Accept all licenses  
⚠️Imp:- Make sure Android SDK is properly installed before running the app for the first time.

### 4. 📱Running on Physical Device
To run the app on a real Android device:

### A) **_Enable Developer Options_**
- Go to Settings → About Phone
- Tap "Build Number" 7 times

### B) **_Enable USB Debugging_**
- Go to Settings → Developer Options
- Enable "USB Debugging"

### C) **_Connect Device_**
- Connect your phone via USB cable
- Allow USB debugging permission when prompted
- Allow install via USB

### D) **_Verify connection_**
   ⚠️Note:- Ensure your device is in "File Transfer (MTP)" mode if the device is not detected.  

### 5. Run the App
```bash
flutter run
```



## 🛠️ Troubleshooting

### ❌ 1. "Flutter doctor shows Android SDK issues"
**Problem:** Android toolchain is not configured properly.  
**Fix:**
```bash
flutter doctor --android-licenses
```
### ❌ 2. "sdkmanager not found"
**Problem:**: Android SDK cmdline-tools not set correctly.

Fix:  
Ensure this path exists:
 Android/Sdk/cmdline-tools/latest/bin  
Then Run:
```bash
.\sdkmanager --version
```

### ❌ 3. "No connected devices found"

Problem: Device not detected by Flutter.

Fix:  
- Enable USB Debugging on phone    
- Use "File Transfer (MTP)" mode  
Run:
```bash
flutter devices
```

### ❌ 4. App builds but crashes on launch

Problem: Missing assets or model file.

Fix:  
- Check pubspec.yaml assets section  
- Ensure .tflite model is included correctly  

### ❌ 5. Gradle build fails

Problem: Dependency or SDK mismatch.  
Fix:
```bash
flutter clean
flutter pub get
flutter run
```
### ❌ 6. Emulator is slow / not starting

Fix:  
- Enable virtualization (BIOS)  
- Use physical device instead (recommended for ML apps)


