class S {
  static String get(String key, String lang) =>
      _strings[lang]?[key] ?? _strings['en']![key] ?? key;

  static const Map<String, Map<String, String>> _strings = {
    'en': {
      // Navigation
      'appTitle': 'Quran & Dhikr',
      'home': 'Home',
      'quran': 'Quran',
      'names': 'Asma ul Husna',
      'settings': 'Settings',
      'reminders': 'Reminders',

      // Splash
      'splashSubtitle': 'Quran & Dhikr Urdu App',

      // Home screen
      'quranPak': 'Holy Quran',
      'surahFatiha': 'Surah Al-Fatiha',
      'asmaAlHusna': 'Asma ul Husna',
      'names99': '99 Names',
      'reminderEvery': 'Every',
      'minutes': 'mins',
      'yaadDehani': 'Reminders',

      // Quran screen
      'initializing': 'Initializing...',
      'reminderLabel': 'Reminder: Every',
      'test': 'Test',
      'ayahCopied': 'Ayah copied',

      // Names screen
      'nameCopied': 'copied',

      // Actions
      'copy': 'Copy',
      'share': 'Share',
      'dismiss': 'Dismiss',

      // Settings
      'settingsTitle': 'Reminder & Dhikr Settings',
      'namesOfAllah': '99 Names of Allah',
      'quranSequence': 'Complete Quran Sequence (6,236 Verses)',
      'repeatVerse': 'Repeat One Verse',
      'repeatVerseDesc': 'Locks and repeats the current verse',
      'repeatName': 'Repeat One Name',
      'repeatNameDesc': 'Locks and repeats one Name of Allah',
      'savePreferences': 'Save Preferences',
      'language': 'Language',
      'english': 'English',
      'urdu': 'اردو',

      // Share/Copy
      'audioNotAvailable': 'Audio files not available, text shared only',
      'ayah': 'Ayah',
    },
    'ur': {
      // Navigation
      'appTitle': 'قرآن و ذکر',
      'home': 'ہوم',
      'quran': 'قرآن',
      'names': 'اسماء',
      'settings': 'ترتیبات',
      'reminders': 'یاد دہانی',

      // Splash
      'splashSubtitle': 'قرآن و ذکر اردو ایپ',

      // Home screen
      'quranPak': 'قرآن پاک',
      'surahFatiha': 'سورۃ الفاتحہ',
      'asmaAlHusna': 'اسماء الحسنیٰ',
      'names99': '99 نام',
      'reminderEvery': 'ہر',
      'minutes': 'منٹ',
      'yaadDehani': 'یاد دہانی',

      // Quran screen
      'initializing': 'شروع ہو رہا ہے...',
      'reminderLabel': 'یاد دہانی: ہر',
      'test': 'ٹیسٹ',
      'ayahCopied': 'آیت کاپی ہو گئی',

      // Names screen
      'nameCopied': 'کاپی ہو گیا',

      // Actions
      'copy': 'نقل کریں',
      'share': 'شیئر کریں',
      'dismiss': 'بند کریں',

      // Settings
      'settingsTitle': 'یاد دہانی اور ذکر کی ترتیبات',
      'namesOfAllah': 'اللہ کے 99 نام',
      'quranSequence': 'مکمل قرآن ترتیب (6,236 آیات)',
      'repeatVerse': 'ایک آیت دہرائیں',
      'repeatVerseDesc': 'موجودہ آیت کو لاک اور دہرایا جائے گا',
      'repeatName': 'ایک نام دہرائیں',
      'repeatNameDesc': 'اللہ کا ایک نام لاک اور دہرایا جائے گا',
      'savePreferences': 'ترتیبات محفوظ کریں',
      'language': 'زبان',
      'english': 'English',
      'urdu': 'اردو',

      // Share/Copy
      'audioNotAvailable': 'آڈیو فائلز دستیاب نہیں، صرف متن شیئر کیا گیا',
      'ayah': 'آیت',
    },
  };
}
