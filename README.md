# Surah Yaseen – Offline Islamic App (Flutter)

Arabic (Uthmani) + Urdu + English, bookmarks, search, reading progress, audio player
(import/download your own licensed recording), Tasbeeh, daily reminder, dark/light mode,
Urdu/English interface. **Works fully offline.** No Firebase, no login, no API.

---
## APK GitHub se kaise banayen (computer par Flutter install kiye baghair)

1. https://github.com par login karein → **New repository** (naam: `surahyaseen`, Public ya Private).
2. Is zip ko extract karein. Folder ke **andar ka sara content** (jis mein `pubspec.yaml`, `lib`, `assets`, `.github` hain) repo mein upload karein:

   **Git se (recommended):**
   ```
   cd surahyaseen
   git init
   git add .
   git commit -m "Surah Yaseen app"
   git branch -M main
   git remote add origin https://github.com/<YOUR_USERNAME>/surahyaseen.git
   git push -u origin main
   ```
   **Ya website se:** repo → *Add file → Upload files* → extract ki hui files drag karein.
   Check karein ke repo mein `.github/workflows/build_apk.yml` maujood hai (hidden folder hota hai).
3. Repo ke **Actions** tab par jayen. "Build Android APK" khud chalna shuru ho jata hai
   (agar na chale: Actions → Build Android APK → **Run workflow**). Taqreeban 8-15 minute lagte hain.
4. Build green ✅ hone par APK do jagah milti hai:
   - Repo ke **Releases** section (right side) → latest "Surah Yaseen build N" → `SurahYaseen.apk`
     (phone ke browser se seedha download ho jati hai).
   - Ya Actions → us run par click → neeche **Artifacts → SurahYaseen-APK** (zip mein).
5. **Phone par install:** APK download karein → open → agar poocha jaye to
   *Settings → Install unknown apps → Chrome/Files → Allow* → Install.
   Play Protect warning aaye to "Install anyway" (app Play Store ki nahi, apni signed-debug-key se bani hai).

Agar Release step fail ho (permission error): repo *Settings → Actions → General → Workflow permissions →
Read and write permissions* select karke Save karein aur workflow dobara chalayen. Artifact tab phir bhi kaam karta hai.

Agar build red ❌ ho: us step ka error text copy karke mujhe bhej dein, main fix kar dunga.

---
## Local build (agar computer par Flutter hai)
```
flutter create . --platforms=android --org com.mohsin --project-name surahyaseen
python3 tools/patch_android.py
flutter pub get
dart run flutter_launcher_icons
flutter test
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

---
## Audio ke baare mein
Licensing ki wajah se koi recitation bundle nahi ki gayi. App ke **Audio** screen par:
- **Import audio file** – phone se Surah Yaseen ki MP3 chunen, ya
- **Download from link** – direct MP3 link paste karein (sirf woh jo aap use kar sakte hain).
Uske baad offline chalti hai, background mein bhi, notification controls ke saath.
Playback: play/pause, seek, speed, ±10s, repeat Surah, A–B repeat (kisi hissay ko dohrana).

## Quran content ke sources
Arabic: Quran Uthmani Hafs (King Fahd Complex text). Urdu: Fateh Muhammad Jalandhry.
English: Umm Muhammad (Saheeh International). Data GitHub `fawazahmed0/quran-api` (Tanzil.net text)
se bina kisi tabdeeli ke li gayi; AI ne kuch generate ya edit nahi kiya.
Details app ke Settings → Sources & licensing mein bhi hain. Release se pehle kisi mustanad Mushaf se
mila lena behtar hai.

## Folder structure
```
lib/
  main.dart, app.dart
  core/ (constants, theme, utils, services: audio_controller, notification_service)
  data/ (models, repositories, local/app_state.dart)
  features/ (splash, home, quran, translation, audio, bookmarks, search, tasbeeh, progress, info, reminders, settings)
  shared/widgets/
assets/ (data/surah_yaseen.json, fonts/, icons/, audio/)
tools/patch_android.py      # Android manifest/gradle patch (runs in CI)
.github/workflows/build_apk.yml
test/quran_data_test.dart   # verifies 83 ayat
```
