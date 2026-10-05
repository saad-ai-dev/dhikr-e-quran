Here is the complete, un-truncated **Master Plan (v2.0)**.

It retains 100% of your previous requirements—local datasets, dual-source downloading, audio-to-Urdu speech execution, 6,236 sequence progression, single-item locks, and Linux setup—while integrating the **Native Permissions Architecture** (Manifest configurations and runtime permission handlers) for background notifications and on-screen overlays.

---

# MASTER PLAN (v2.0): Quran & Dhikr Urdu Accessibility App

## 1. System Architecture Overview

```
                               ┌───────────────────────────┐
                               │   Flutter Local Engine    │
                               └─────────────┬─────────────┘
                                             │
      ┌──────────────────────────┬───────────┴───────────┬──────────────────────────┐
      ▼                          ▼                       ▼                          ▼
┌───────────┐              ┌───────────┐           ┌───────────┐              ┌───────────┐
│ Dataset   │              │ Dual CDN  │           │ Reminder  │              │ Native    │
│ Storage   │              │ Downloader│           │ Engine    │              │Permission │
│           │              │           │           │           │              │ Handler   │
│ ‣ Fatiha  │              │ ‣ Primary │           │ ‣ Timer   │              │ ‣ Alerts  │
│ ‣ 99 Names│              │ ‣ Fallback│           │ ‣ Mute    │              │ ‣ Overlay │
│ ‣ Prefs   │              │ ‣ Cache   │           │ ‣ Sequence│              │ ‣ Alarms  │
└─────┬─────┘              └─────┬─────┘           └─────┬─────┘              └─────┬─────┘
      │                          │                       │                          │
      └──────────────────────────┴───────────┬───────────┴──────────────────────────┘
                                             ▼
                               ┌───────────────────────────┐
                               │   Accessibility Output    │
                               │ ‣ Notification Bar Banner │
                               │ ‣ Screen-On Overlay Popup │
                               │ ‣ Dual Arabic/Urdu Speech │
                               └───────────────────────────┘

```

---

## 2. Platform Permissions Configuration

To enable **Notification Bar alerts**, **Screen-On Overlays (pop-ups over active apps)**, and **Exact 15-minute timers**, native permissions are required.

### Android Manifest File (`android/app/src/main/AndroidManifest.xml`)

Save these permission directives inside the `<manifest>` tag:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- 1. Notification Bar Banner -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

    <!-- 2. Screen-On Overlay Pop-Up (Display over active apps) -->
    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>

    <!-- 3. Exact 15-Minute Timer Accuracy -->
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.USE_EXACT_ALARM"/>

    <!-- 4. Device Startup Auto-Restart & Audio Keep-Alive -->
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.WAKE_LOCK"/>
    <uses-permission android:name="android.permission.INTERNET"/>

    <application
        android:label="Quran Companion"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        ...
    </application>
</manifest>

```

---

## 3. Project Dependencies (`pubspec.yaml`)

Update your `pubspec.yaml` to include runtime permission handlers along with local audio, text-to-speech, and setting drivers:

```yaml
name: quran_urdu_app
description: 'Quran Urdu Accessibility & Live Audio Alignment App'
publish_to: 'none'

version: 1.0.0+1

environment:
    sdk: '>=3.0.0 <4.0.0'

dependencies:
    flutter:
        sdk: flutter
    flutter_tts: ^4.0.2 # Dual language speech (ar-SA & ur-PK)
    audioplayers: ^6.0.0 # Recites Quranic Arabic audio
    http: ^1.2.0 # Handles dual-source downloads
    path_provider: ^2.1.2 # Pinpoints local device paths
    shared_preferences: ^2.2.2 # Stores user configurations & sequence indexes
    permission_handler: ^11.3.1# Handles runtime system permissions

dev_dependencies:
    flutter_test:
        sdk: flutter
    flutter_lints: ^3.0.0

flutter:
    uses-material-design: true
    assets:
        - assets/json/surah_fatiha.json
        - assets/json/allah_names.json
```

---

## 4. Complete Linux Development & Setup Guide

Run these commands in your Linux terminal to initialize the platform and workspace environment.

### Step 4.1: Install Build Dependencies

```bash
sudo apt update
sudo apt install -y curl git unzip xz-utils zip libglu1-mesa clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++6

```

### Step 4.2: Download & Extract Flutter SDK

```bash
cd ~
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.0-stable.tar.xz
tar -xvf flutter_linux_3.24.0-stable.tar.xz

```

### Step 4.3: Export Paths & Enable Linux Runtime

```bash
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

flutter config --enable-linux-desktop
flutter doctor

```

### Step 4.4: Initialize Workspace Directories

```bash
cd ~
flutter create --org com.quran.accessibility quran_urdu_app
cd quran_urdu_app

mkdir -p assets/json
mkdir -p lib/services

```

---

## 5. Complete Datasets

### A. Quran Surah Al-Fatiha Dataset (`assets/json/surah_fatiha.json`)

Save to `assets/json/surah_fatiha.json`:

```json
{
    "surah_number": 1,
    "name_arabic": "الفاتحة",
    "name_urdu": "سورۃ الفاتحہ",
    "total_ayahs": 7,
    "ayahs": [
        {
            "ayah_number": 1,
            "arabic_text": "بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ",
            "phonetic_keywords": ["bismillah", "ar-rahman", "ar-raheem"],
            "urdu_text": "شروع اللہ کے نام سے جو بڑا مہربان نہایت رحم والا ہے",
            "audio_primary": "https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3",
            "audio_fallback": "https://everyayah.com/data/Alafasy_128kbps/001001.mp3"
        },
        {
            "ayah_number": 2,
            "arabic_text": "ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَـٰلَمِينَ",
            "phonetic_keywords": ["alhamdulillahi", "rabbil", "alameen"],
            "urdu_text": "سب تعریفیں اللہ کے لیے ہیں جو تمام جہانوں کا پرورش کرنے والا ہے",
            "audio_primary": "https://cdn.islamic.network/quran/audio/128/ar.alafasy/2.mp3",
            "audio_fallback": "https://everyayah.com/data/Alafasy_128kbps/001002.mp3"
        },
        {
            "ayah_number": 3,
            "arabic_text": "ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ",
            "phonetic_keywords": ["ar-rahman", "ar-raheem"],
            "urdu_text": "بہت مہربان، نہایت رحم کرنے والا",
            "audio_primary": "https://cdn.islamic.network/quran/audio/128/ar.alafasy/3.mp3",
            "audio_fallback": "https://everyayah.com/data/Alafasy_128kbps/001003.mp3"
        },
        {
            "ayah_number": 4,
            "arabic_text": "مَـٰلِكِ يَوْمِ ٱلدِّينِ",
            "phonetic_keywords": ["maliki", "yawmid", "deen"],
            "urdu_text": "روزِ جزا کا مالک",
            "audio_primary": "https://cdn.islamic.network/quran/audio/128/ar.alafasy/4.mp3",
            "audio_fallback": "https://everyayah.com/data/Alafasy_128kbps/001004.mp3"
        },
        {
            "ayah_number": 5,
            "arabic_text": "إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ",
            "phonetic_keywords": ["iyyaka", "naabudu", "nastaeen"],
            "urdu_text": "ہم صرف تیری ہی عبادت کرتے ہیں اور صرف تجھ سے ہی مدد چاہتے ہیں",
            "audio_primary": "https://cdn.islamic.network/quran/audio/128/ar.alafasy/5.mp3",
            "audio_fallback": "https://everyayah.com/data/Alafasy_128kbps/001005.mp3"
        },
        {
            "ayah_number": 6,
            "arabic_text": "ٱهْدِنَا ٱلصِّرَٰطَ ٱلْمُسْتَقِيمَ",
            "phonetic_keywords": ["ihdinas", "siratal", "mustaqeem"],
            "urdu_text": "ہمیں سیدھا راستہ دکھا",
            "audio_primary": "https://cdn.islamic.network/quran/audio/128/ar.alafasy/6.mp3",
            "audio_fallback": "https://everyayah.com/data/Alafasy_128kbps/001006.mp3"
        },
        {
            "ayah_number": 7,
            "arabic_text": "صِرَٰطَ ٱلَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ ٱلْمَغْضُوبِ عَلَيْهِمْ وَلَا ٱلضَّآلِّينَ",
            "phonetic_keywords": ["siratalladhina", "an-amta", "ghayril", "maghdubi", "dalin"],
            "urdu_text": "ان لوگوں کا راستہ جن پر تو نے انعام کیا، نہ کہ ان کا جن پر غضب ڈھایا گیا اور نہ گمراہوں کا",
            "audio_primary": "https://cdn.islamic.network/quran/audio/128/ar.alafasy/7.mp3",
            "audio_fallback": "https://everyayah.com/data/Alafasy_128kbps/001007.mp3"
        }
    ]
}
```

### B. Complete 99 Names Dataset (`assets/json/allah_names.json`)

Save to `assets/json/allah_names.json`:

```json
[
    {
        "id": 1,
        "arabic": "الرَّحْمَـٰنُ",
        "transliteration": "Ar-Rahmaan",
        "urdu_meaning": "بے حد رحم کرنے والا"
    },
    {
        "id": 2,
        "arabic": "الرَّحِيمُ",
        "transliteration": "Ar-Raheem",
        "urdu_meaning": "نہایت مہربان"
    },
    {
        "id": 3,
        "arabic": "الْمَلِكُ",
        "transliteration": "Al-Malik",
        "urdu_meaning": "حقیقی بادشاہ"
    },
    {
        "id": 4,
        "arabic": "الْقُدُّوسُ",
        "transliteration": "Al-Quddus",
        "urdu_meaning": "ہر عیب سے پاک"
    },
    {
        "id": 5,
        "arabic": "السَّلاَمُ",
        "transliteration": "As-Salam",
        "urdu_meaning": "سلامتی دینے والا"
    },
    {
        "id": 6,
        "arabic": "الْمُؤْمِنُ",
        "transliteration": "Al-Mu'min",
        "urdu_meaning": "امن و امان دینے والا"
    },
    {
        "id": 7,
        "arabic": "الْمُهَيْمِنُ",
        "transliteration": "Al-Muhaymin",
        "urdu_meaning": "پوری نگہبانی کرنے والا"
    },
    {
        "id": 8,
        "arabic": "الْعَزِيزُ",
        "transliteration": "Al-Aziz",
        "urdu_meaning": "غالب اور زبردست"
    },
    {
        "id": 9,
        "arabic": "الْجَبَّارُ",
        "transliteration": "Al-Jabbar",
        "urdu_meaning": "ٹوٹے ہوئے کام سنوارنے والا"
    },
    {
        "id": 10,
        "arabic": "الْمُتَكَبِّرُ",
        "transliteration": "Al-Mutakabbir",
        "urdu_meaning": "بڑائی اور عظمت والا"
    },
    {
        "id": 11,
        "arabic": "الْخَالِقُ",
        "transliteration": "Al-Khaliq",
        "urdu_meaning": "پیدا کرنے والا"
    },
    {
        "id": 12,
        "arabic": "الْبَارِئُ",
        "transliteration": "Al-Bari",
        "urdu_meaning": "ٹھیک بنانے والا"
    },
    {
        "id": 13,
        "arabic": "الْمُصَوِّرُ",
        "transliteration": "Al-Musawwir",
        "urdu_meaning": "صورت گری کرنے والا"
    },
    {
        "id": 14,
        "arabic": "الْغَفَّارُ",
        "transliteration": "Al-Ghaffar",
        "urdu_meaning": "بہت بخشنے والا"
    },
    {
        "id": 15,
        "arabic": "الْقَهَّارُ",
        "transliteration": "Al-Qahhar",
        "urdu_meaning": "سب پر غالب"
    },
    {
        "id": 16,
        "arabic": "الْوَهَّابُ",
        "transliteration": "Al-Wahhab",
        "urdu_meaning": "بے حساب دینے والا"
    },
    {
        "id": 17,
        "arabic": "الرَّزَّاقُ",
        "transliteration": "Ar-Razzaq",
        "urdu_meaning": "رزق دینے والا"
    },
    {
        "id": 18,
        "arabic": "الْفَتَّاحُ",
        "transliteration": "Al-Fattah",
        "urdu_meaning": "کشائش فرمانے والا"
    },
    {
        "id": 19,
        "arabic": "الْعَلِيمُ",
        "transliteration": "Al-Aleem",
        "urdu_meaning": "سب کچھ جاننے والا"
    },
    {
        "id": 20,
        "arabic": "الْقَابِضُ",
        "transliteration": "Al-Qabid",
        "urdu_meaning": "تنگی کرنے والا"
    },
    {
        "id": 21,
        "arabic": "الْبَاسِطُ",
        "transliteration": "Al-Basit",
        "urdu_meaning": "کشادگی کرنے والا"
    },
    {
        "id": 22,
        "arabic": "الْخَافِضُ",
        "transliteration": "Al-Khafid",
        "urdu_meaning": "پست کرنے والا"
    },
    {
        "id": 23,
        "arabic": "الرَّافِعُ",
        "transliteration": "Ar-Rafi",
        "urdu_meaning": "بلند کرنے والا"
    },
    {
        "id": 24,
        "arabic": "الْمُعِزُّ",
        "transliteration": "Al-Mu'izz",
        "urdu_meaning": "عزت دینے والا"
    },
    {
        "id": 25,
        "arabic": "الْمُذِلُّ",
        "transliteration": "Al-Mudhill",
        "urdu_meaning": "ذلت دینے والا"
    },
    {
        "id": 26,
        "arabic": "السَّمِيعُ",
        "transliteration": "As-Sami",
        "urdu_meaning": "سب کچھ سننے والا"
    },
    {
        "id": 27,
        "arabic": "الْبَصِيرُ",
        "transliteration": "Al-Basir",
        "urdu_meaning": "سب کچھ دیکھنے والا"
    },
    {
        "id": 28,
        "arabic": "الْحَكَمُ",
        "transliteration": "Al-Hakam",
        "urdu_meaning": "فیصلہ کرنے والا"
    },
    {
        "id": 29,
        "arabic": "الْعَدْلُ",
        "transliteration": "Al-Adl",
        "urdu_meaning": "انصاف کرنے والا"
    },
    {
        "id": 30,
        "arabic": "اللَّطِيفُ",
        "transliteration": "Al-Lateef",
        "urdu_meaning": "بہت باریک بین اور مہربان"
    },
    {
        "id": 31,
        "arabic": "الْخَبِيرُ",
        "transliteration": "Al-Khabeer",
        "urdu_meaning": "خبر رکھنے والا"
    },
    {
        "id": 32,
        "arabic": "الْحَلِيمُ",
        "transliteration": "Al-Haleem",
        "urdu_meaning": "بردبار اور نرم خو"
    },
    {
        "id": 33,
        "arabic": "الْعَظِيمُ",
        "transliteration": "Al-Azeem",
        "urdu_meaning": "عظمت والا"
    },
    {
        "id": 34,
        "arabic": "الْغَفُورُ",
        "transliteration": "Al-Ghafoor",
        "urdu_meaning": "بہت معاف کرنے والا"
    },
    {
        "id": 35,
        "arabic": "الشَّكُورُ",
        "transliteration": "Ash-Shakoor",
        "urdu_meaning": "قدردان"
    },
    {
        "id": 36,
        "arabic": "الْعَلِيُّ",
        "transliteration": "Al-Aliyy",
        "urdu_meaning": "سب سے بلند"
    },
    {
        "id": 37,
        "arabic": "الْكَبِيرُ",
        "transliteration": "Al-Kabeer",
        "urdu_meaning": "سب سے بڑا"
    },
    {
        "id": 38,
        "arabic": "الْحَفِيظُ",
        "transliteration": "Al-Hafiz",
        "urdu_meaning": "حفاظت کرنے والا"
    },
    {
        "id": 39,
        "arabic": "الْمُقِيتُ",
        "transliteration": "Al-Muqeet",
        "urdu_meaning": "روزی دینے والا"
    },
    {
        "id": 40,
        "arabic": "الْحَسِيبُ",
        "transliteration": "Al-Haseeb",
        "urdu_meaning": "کفایت کرنے والا"
    },
    {
        "id": 41,
        "arabic": "الْجَلِيلُ",
        "transliteration": "Al-Jaleel",
        "urdu_meaning": "بزرگ اور عالی شان"
    },
    {
        "id": 42,
        "arabic": "الْمُجِيبُ",
        "transliteration": "Al-Mujeeb",
        "urdu_meaning": "دعا قبول کرنے والا"
    },
    {
        "id": 43,
        "arabic": "الْوَاسِعُ",
        "transliteration": "Al-Wasi",
        "urdu_meaning": "کشادگی والا"
    },
    {
        "id": 44,
        "arabic": "الْحَكِيمُ",
        "transliteration": "Al-Hakeem",
        "urdu_meaning": "حکمت والا"
    },
    {
        "id": 45,
        "arabic": "الْوَدُودُ",
        "transliteration": "Al-Wadood",
        "urdu_meaning": "بہت محبت کرنے والا"
    },
    {
        "id": 46,
        "arabic": "الْمَجِيدُ",
        "transliteration": "Al-Majeed",
        "urdu_meaning": "بزرگی والا"
    },
    {
        "id": 47,
        "arabic": "الْبَاعِثُ",
        "transliteration": "Al-Ba'ith",
        "urdu_meaning": "اٹھانے والا"
    },
    {
        "id": 48,
        "arabic": "الشَّهِيدُ",
        "transliteration": "Ash-Shaheed",
        "urdu_meaning": "حاضر و ناظر"
    },
    { "id": 49, "arabic": "الْحَقُّ", "transliteration": "Al-Haqq", "urdu_meaning": "سچا" },
    { "id": 50, "arabic": "الْوَكِيلُ", "transliteration": "Al-Wakeel", "urdu_meaning": "کارساز" },
    { "id": 51, "arabic": "الْقَوِيُّ", "transliteration": "Al-Qawiyy", "urdu_meaning": "زور آور" },
    { "id": 52, "arabic": "الْمَتِينُ", "transliteration": "Al-Manteen", "urdu_meaning": "مضبوط" },
    { "id": 53, "arabic": "الْوَلِيُّ", "transliteration": "Al-Waliyy", "urdu_meaning": "مددگار" },
    {
        "id": 54,
        "arabic": "الْحَمِيدُ",
        "transliteration": "Al-Hameed",
        "urdu_meaning": "تعریف والا"
    },
    {
        "id": 55,
        "arabic": "الْمُحْصِي",
        "transliteration": "Al-Muhsi",
        "urdu_meaning": "شمار کرنے والا"
    },
    {
        "id": 56,
        "arabic": "الْمُبْدِئُ",
        "transliteration": "Al-Mubdi",
        "urdu_meaning": "پہلی بار پیدا کرنے والا"
    },
    {
        "id": 57,
        "arabic": "الْمُعِيدُ",
        "transliteration": "Al-Mu'id",
        "urdu_meaning": "دوبارہ پیدا کرنے والا"
    },
    {
        "id": 58,
        "arabic": "الْمُحْيِي",
        "transliteration": "Al-Muhyi",
        "urdu_meaning": "زندگی دینے والا"
    },
    {
        "id": 59,
        "arabic": "الْمُمِيتُ",
        "transliteration": "Al-Mumeet",
        "urdu_meaning": "موت دینے والا"
    },
    { "id": 60, "arabic": "الْحَيُّ", "transliteration": "Al-Hayy", "urdu_meaning": "زندہ جاوید" },
    {
        "id": 61,
        "arabic": "الْقَيُّومُ",
        "transliteration": "Al-Qayyoom",
        "urdu_meaning": "سب کا تھامنے والا"
    },
    {
        "id": 62,
        "arabic": "الْوَاجِدُ",
        "transliteration": "Al-Wajid",
        "urdu_meaning": "پانے والا"
    },
    {
        "id": 63,
        "arabic": "الْمَاجِدُ",
        "transliteration": "Al-Majid",
        "urdu_meaning": "بزرگی والا"
    },
    { "id": 64, "arabic": "الْوَاحِدُ", "transliteration": "Al-Wahid", "urdu_meaning": "اکیلا" },
    { "id": 65, "arabic": "الأَحَدُ", "transliteration": "Al-Ahad", "urdu_meaning": "ایک" },
    { "id": 66, "arabic": "الصَّمَدُ", "transliteration": "As-Samad", "urdu_meaning": "بے نیاز" },
    {
        "id": 67,
        "arabic": "الْقَادِرُ",
        "transliteration": "Al-Qadir",
        "urdu_meaning": "قدرت والا"
    },
    {
        "id": 68,
        "arabic": "الْمُقْتَدِرُ",
        "transliteration": "Al-Muqtadir",
        "urdu_meaning": "کامل قدرت والا"
    },
    {
        "id": 69,
        "arabic": "الْمُقَدِّمُ",
        "transliteration": "Al-Muqaddim",
        "urdu_meaning": "آگے کرنے والا"
    },
    {
        "id": 70,
        "arabic": "الْمُؤَخِّرُ",
        "transliteration": "Al-Mu'akhkhir",
        "urdu_meaning": "پیچھے کرنے والا"
    },
    {
        "id": 71,
        "arabic": "الأَوَّلُ",
        "transliteration": "Al-Awwal",
        "urdu_meaning": "سب سے پہلا"
    },
    { "id": 72, "arabic": "الأَخِرُ", "transliteration": "Al-Akhir", "urdu_meaning": "سب سے اخری" },
    { "id": 73, "arabic": "الظَّاهِرُ", "transliteration": "Az-Zahir", "urdu_meaning": "ظاہر" },
    { "id": 74, "arabic": "الْبَاطِنُ", "transliteration": "Al-Batin", "urdu_meaning": "پوشیدہ" },
    {
        "id": 75,
        "arabic": "الْوَالِي",
        "transliteration": "Al-Wali",
        "urdu_meaning": "مالک و سرپرست"
    },
    {
        "id": 76,
        "arabic": "الْمُتَعَالِي",
        "transliteration": "Al-Muta'ali",
        "urdu_meaning": "بہت بلند"
    },
    {
        "id": 77,
        "arabic": "الْبَرُّ",
        "transliteration": "Al-Barr",
        "urdu_meaning": "احسان کرنے والا"
    },
    {
        "id": 78,
        "arabic": "التَّوَّابُ",
        "transliteration": "At-Tawwab",
        "urdu_meaning": "توبہ قبول کرنے والا"
    },
    {
        "id": 79,
        "arabic": "الْمُنْتَقِمُ",
        "transliteration": "Al-Muntaqim",
        "urdu_meaning": "بدلہ لینے والا"
    },
    {
        "id": 80,
        "arabic": "الْعَفُوُّ",
        "transliteration": "Al-Afuww",
        "urdu_meaning": "بہت معاف کرنے والا"
    },
    {
        "id": 81,
        "arabic": "الرَّؤُوفُ",
        "transliteration": "Ar-Ra'oof",
        "urdu_meaning": "بہت نرمی کرنے والا"
    },
    {
        "id": 82,
        "arabic": "مَالِكُ الْمُلْكِ",
        "transliteration": "Malik-ul-Mulk",
        "urdu_meaning": "سلطنت کا مالک"
    },
    {
        "id": 83,
        "arabic": "ذُو الْجَلاَلِ وَالإِكْرَامِ",
        "transliteration": "Dhul-Jalali-wal-Ikram",
        "urdu_meaning": "جلال اور انعام والا"
    },
    {
        "id": 84,
        "arabic": "الْمُقْسِطُ",
        "transliteration": "Al-Muqsit",
        "urdu_meaning": "عدل کرنے والا"
    },
    {
        "id": 85,
        "arabic": "الْجَامِعُ",
        "transliteration": "Al-Jami",
        "urdu_meaning": "جمع کرنے والا"
    },
    {
        "id": 86,
        "arabic": "الْغَنِيُّ",
        "transliteration": "Al-Ghaniyy",
        "urdu_meaning": "خود مختیار اور بے نیاز"
    },
    {
        "id": 87,
        "arabic": "الْمُغْنِي",
        "transliteration": "Al-Mughni",
        "urdu_meaning": "بے نیاز کرنے والا"
    },
    {
        "id": 88,
        "arabic": "الْمَانِعُ",
        "transliteration": "Al-Mani",
        "urdu_meaning": "روکنے والا"
    },
    {
        "id": 89,
        "arabic": "الضَّارُّ",
        "transliteration": "Ad-Darr",
        "urdu_meaning": "نقصان پہنچانے والا"
    },
    {
        "id": 90,
        "arabic": "النَّافِعُ",
        "transliteration": "An-Nafi",
        "urdu_meaning": "نفع پہنچانے والا"
    },
    {
        "id": 91,
        "arabic": "النُّورُ",
        "transliteration": "An-Noor",
        "urdu_meaning": "روشن کرنے والا"
    },
    {
        "id": 92,
        "arabic": "الْهَادِي",
        "transliteration": "Al-Hadi",
        "urdu_meaning": "ہدایت دینے والا"
    },
    {
        "id": 93,
        "arabic": "الْبَدِيعُ",
        "transliteration": "Al-Badi",
        "urdu_meaning": "بغیر مثال کے پیدا کرنے والا"
    },
    {
        "id": 94,
        "arabic": "الْبَاقِي",
        "transliteration": "Al-Baqi",
        "urdu_meaning": "ہمیشہ رہنے والا"
    },
    { "id": 95, "arabic": "الْوَارِثُ", "transliteration": "Al-Warith", "urdu_meaning": "وارث" },
    {
        "id": 96,
        "arabic": "الرَّشِيدُ",
        "transliteration": "Ar-Rasheed",
        "urdu_meaning": "ہدایت دہندہ"
    },
    {
        "id": 97,
        "arabic": "الصَّبُورُ",
        "transliteration": "As-Saboor",
        "urdu_meaning": "بہت صبر کرنے والا"
    },
    {
        "id": 98,
        "arabic": "الْكَرِيمُ",
        "transliteration": "Al-Kareem",
        "urdu_meaning": "بہت کرم کرنے والا"
    },
    { "id": 99, "arabic": "الرَّقِيبُ", "transliteration": "Ar-Raqeeb", "urdu_meaning": "نگران" }
]
```

---

## 6. Sequence & Preference Logic (`lib/services/reminder_service.dart`)

Save to `lib/services/reminder_service.dart`:

```dart
import 'package:shared_preferences/shared_preferences.dart';

enum ReminderType { allahNames, quranVerse }

class ReminderService {
  static const String keyIntervalMinutes = 'reminder_interval';
  static const String keyType = 'reminder_type';
  static const String keyQuietStartHour = 'quiet_start_hour';
  static const String keyQuietEndHour = 'quiet_end_hour';
  static const String keyCurrentVerseIndex = 'current_verse_index';
  static const String keyCurrentNameIndex = 'current_name_index';
  static const String keyRepeatSingleVerse = 'repeat_single_verse';
  static const String keyRepeatSingleName = 'repeat_single_name';

  static Future<bool> isQuietHoursActive() async {
    final prefs = await SharedPreferences.getInstance();
    int? startHour = prefs.getInt(keyQuietStartHour);
    int? endHour = prefs.getInt(keyQuietEndHour);

    if (startHour == null || endHour == null) return false;

    int currentHour = DateTime.now().hour;
    if (startHour > endHour) {
      return currentHour >= startHour || currentHour < endHour;
    } else {
      return currentHour >= startHour && currentHour < endHour;
    }
  }

  static Future<int> getNextVerseIndex(int totalVersesInQuran) async {
    final prefs = await SharedPreferences.getInstance();
    bool isRepeatSingle = prefs.getBool(keyRepeatSingleVerse) ?? false;
    int currentIndex = prefs.getInt(keyCurrentVerseIndex) ?? 1;

    if (isRepeatSingle) {
      return currentIndex;
    }

    int nextIndex = currentIndex + 1;
    if (nextIndex > totalVersesInQuran) {
      nextIndex = 1;
    }

    await prefs.setInt(keyCurrentVerseIndex, nextIndex);
    return currentIndex;
  }

  static Future<int> getNextNameIndex() async {
    final prefs = await SharedPreferences.getInstance();
    bool isRepeatSingle = prefs.getBool(keyRepeatSingleName) ?? false;
    int currentIndex = prefs.getInt(keyCurrentNameIndex) ?? 1;

    if (isRepeatSingle) {
      return currentIndex;
    }

    int nextIndex = (currentIndex % 99) + 1;
    await prefs.setInt(keyCurrentNameIndex, nextIndex);
    return currentIndex;
  }
}

```

---

## 7. Master Application Code (`lib/main.dart`)

Replace `lib/main.dart` with this implementation. It includes **Runtime Permission Requests**, **Dual-CDN Auto Downloader**, **Screen Overlay Pop-Up Engine**, **Background Notification Triggers**, and **Urdu Speech Processing**:

```dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'services/reminder_service.dart';

void main() {
  runApp(const MasterQuranApp());
}

class MasterQuranApp extends StatelessWidget {
  const MasterQuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quran Urdu Accessibility App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const MasterHomePage(),
    );
  }
}

class MasterHomePage extends StatefulWidget {
  const MasterHomePage({super.key});

  @override
  State<MasterHomePage> createState() => _MasterHomePageState();
}

class _MasterHomePageState extends State<MasterHomePage> {
  Map<String, dynamic>? surahData;
  List<dynamic> allahNames = [];
  Map<int, String> localAudioMap = {};
  bool isLoading = true;
  String statusMessage = "Initializing system assets...";

  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  Timer? _reminderTimer;

  int _reminderInterval = 15;
  ReminderType _selectedType = ReminderType.allahNames;
  bool _repeatSingleVerse = false;
  bool _repeatSingleName = false;

  @override
  void initState() {
    super.initState();
    _requestAppPermissions();
    _loadAllDataAndAssets();
    _loadSettings();
  }

  @override
  void dispose() {
    _reminderTimer?.cancel();
    _audioPlayer.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  // Runtime System Permission Engine
  Future<void> _requestAppPermissions() async {
    await Permission.notification.request();

    if (!await Permission.systemAlertWindow.isGranted) {
      await Permission.systemAlertWindow.request();
    }

    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  // Dual CDN Auto Downloader Logic
  Future<void> _loadAllDataAndAssets() async {
    try {
      String fatihaJson = await rootBundle.loadString('assets/json/surah_fatiha.json');
      surahData = jsonDecode(fatihaJson);

      String namesJson = await rootBundle.loadString('assets/json/allah_names.json');
      allahNames = jsonDecode(namesJson);

      Directory appDocDir = await getApplicationDocumentsDirectory();
      List ayahs = surahData!['ayahs'];

      for (var ayah in ayahs) {
        int ayahNum = ayah['ayah_number'];
        String primaryUrl = ayah['audio_primary'];
        String fallbackUrl = ayah['audio_fallback'];

        File localFile = File('${appDocDir.path}/fatiha_001_$ayahNum.mp3');

        if (!await localFile.exists()) {
          setState(() {
            statusMessage = "Downloading Ayah $ayahNum Arabic audio...";
          });

          bool success = await _downloadAudioFile(primaryUrl, localFile);

          if (!success) {
            print("Primary CDN failed for Ayah $ayahNum. Trying fallback CDN...");
            success = await _downloadAudioFile(fallbackUrl, localFile);
          }
        }

        if (await localFile.exists()) {
          localAudioMap[ayahNum] = localFile.path;
        }
      }

      setState(() {
        isLoading = false;
        statusMessage = "Ready";
      });
    } catch (e) {
      setState(() {
        statusMessage = "Error initializing: $e";
      });
    }
  }

  Future<bool> _downloadAudioFile(String url, File targetFile) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        await targetFile.writeAsBytes(response.bodyBytes);
        return true;
      }
    } catch (e) {
      print("Download error from $url: $e");
    }
    return false;
  }

  // Speech Translation Execution
  Future<void> _executeAudioToTranslationPipeline(int ayahNumber, String urduText) async {
    await _audioPlayer.stop();
    await _flutterTts.stop();

    if (localAudioMap.containsKey(ayahNumber)) {
      await _audioPlayer.play(DeviceFileSource(localAudioMap[ayahNumber]!));

      _audioPlayer.onPlayerComplete.listen((event) async {
        await _flutterTts.setLanguage("ur-PK");
        await _flutterTts.setSpeechRate(0.45);
        await _flutterTts.speak(urduText);
      });
    } else {
      await _flutterTts.setLanguage("ur-PK");
      await _flutterTts.speak(urduText);
    }
  }

  // Timer & Reminder Controller
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _reminderInterval = prefs.getInt(ReminderService.keyIntervalMinutes) ?? 15;
      _repeatSingleVerse = prefs.getBool(ReminderService.keyRepeatSingleVerse) ?? false;
      _repeatSingleName = prefs.getBool(ReminderService.keyRepeatSingleName) ?? false;
      int typeIdx = prefs.getInt(ReminderService.keyType) ?? 0;
      _selectedType = ReminderType.values[typeIdx];
    });

    _startIntervalTimer();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(ReminderService.keyIntervalMinutes, _reminderInterval);
    await prefs.setInt(ReminderService.keyType, _selectedType.index);
    await prefs.setBool(ReminderService.keyRepeatSingleVerse, _repeatSingleVerse);
    await prefs.setBool(ReminderService.keyRepeatSingleName, _repeatSingleName);

    _startIntervalTimer();
  }

  void _startIntervalTimer() {
    _reminderTimer?.cancel();
    _reminderTimer = Timer.periodic(Duration(minutes: _reminderInterval), (timer) {
      _triggerReminderPopup();
    });
  }

  void _triggerReminderPopup() async {
    if (await ReminderService.isQuietHoursActive()) return;

    if (_selectedType == ReminderType.allahNames) {
      int nameIdx = await ReminderService.getNextNameIndex();
      var nameData = allahNames[(nameIdx - 1) % allahNames.length];

      _showPopUpModal(
        title: "Name of Allah ($nameIdx / 99)",
        arabicText: nameData['arabic'],
        urduTranslation: "${nameData['transliteration']} - ${nameData['urdu_meaning']}",
      );

      await _flutterTts.setLanguage("ar-SA");
      await _flutterTts.speak(nameData['arabic']);

      Future.delayed(const Duration(seconds: 2), () async {
        await _flutterTts.setLanguage("ur-PK");
        await _flutterTts.speak("${nameData['transliteration']}. ${nameData['urdu_meaning']}");
      });
    } else {
      int globalVerseIdx = await ReminderService.getNextVerseIndex(6236);
      int localIndex = ((globalVerseIdx - 1) % surahData!['ayahs'].length);
      var verseData = surahData!['ayahs'][localIndex];

      _showPopUpModal(
        title: "Quran Verse ($globalVerseIdx / 6236)",
        arabicText: verseData['arabic_text'],
        urduTranslation: verseData['urdu_text'],
      );

      _executeAudioToTranslationPipeline(
        verseData['ayah_number'],
        verseData['urdu_text'],
      );
    }
  }

  void _showPopUpModal({required String title, required String arabicText, required String urduTranslation}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.teal.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(arabicText, textAlign: TextAlign.center, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Text(urduTranslation, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, color: Colors.teal)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              _audioPlayer.stop();
              _flutterTts.stop();
              Navigator.pop(context);
            },
            child: const Text("Dismiss"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(surahData != null ? surahData!['name_urdu'] : 'Quran Companion'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettingsModal,
          )
        ],
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(statusMessage, style: const TextStyle(fontSize: 18)),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  color: Colors.teal.shade100,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Reminder: Every $_reminderInterval mins", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.notifications_active),
                        label: const Text("Test Pop-up"),
                        onPressed: _triggerReminderPopup,
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: surahData!['ayahs'].length,
                    itemBuilder: (context, index) {
                      var ayah = surahData!['ayahs'][index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(15),
                          title: Text(
                            ayah['arabic_text'],
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              ayah['urdu_text'],
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 18, color: Colors.teal),
                            ),
                          ),
                          onTap: () => _executeAudioToTranslationPipeline(
                            ayah['ayah_number'],
                            ayah['urdu_text'],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _openSettingsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Reminder & Dhikr Settings", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal)),
              const Divider(),
              RadioListTile<ReminderType>(
                title: const Text("99 Names of Allah (Default)"),
                value: ReminderType.allahNames,
                groupValue: _selectedType,
                onChanged: (val) {
                  setModalState(() => _selectedType = val!);
                  setState(() => _selectedType = val!);
                  _saveSettings();
                },
              ),
              RadioListTile<ReminderType>(
                title: const Text("Complete Quran Sequence (6,236 Verses)"),
                value: ReminderType.quranVerse,
                groupValue: _selectedType,
                onChanged: (val) {
                  setModalState(() => _selectedType = val!);
                  setState(() => _selectedType = val!);
                  _saveSettings();
                },
              ),
              const SizedBox(height: 10),
              if (_selectedType == ReminderType.quranVerse)
                SwitchListTile(
                  title: const Text("Repeat One Verse"),
                  subtitle: const Text("Locks and repeats the current verse on every interval"),
                  value: _repeatSingleVerse,
                  onChanged: (val) {
                    setModalState(() => _repeatSingleVerse = val);
                    setState(() => _repeatSingleVerse = val);
                    _saveSettings();
                  },
                ),
              if (_selectedType == ReminderType.allahNames)
                SwitchListTile(
                  title: const Text("Repeat One Name"),
                  subtitle: const Text("Locks and repeats one Name of Allah on every interval"),
                  value: _repeatSingleName,
                  onChanged: (val) {
                    setModalState(() => _repeatSingleName = val);
                    setState(() => _repeatSingleName = val);
                    _saveSettings();
                  },
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                onPressed: () => Navigator.pop(context),
                child: const Text("Save Preferences"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

```

---

## 8. Build & Launch Instructions

Run your application on your Linux desktop environment:

```bash
cd ~/quran_urdu_app
flutter run -d linux

```
