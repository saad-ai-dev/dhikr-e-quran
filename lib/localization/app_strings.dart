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

      // Search
      'search': 'Search surah...',
      'surahList': 'Surah Index',

      // Tasbeeh
      'tasbeeh': 'Tasbeeh',
      'tasbeehCounter': 'Dhikr Counter',
      'tap': 'Tap',
      'reset': 'Reset',
      'resetConfirm': 'Reset counter?',
      'yes': 'Yes',
      'no': 'No',

      // Reminder Screen
      'currentStatus': 'Current Settings',
      'intervalLabel': 'Reminder Interval',
      'quietHours': 'Quiet Hours',
      'quietStart': 'Start',
      'quietEnd': 'End',
      'reminderContent': 'Reminder Content',
      'allNames': 'All 99 Names (Sequential)',
      'specificName': 'Specific Name',
      'randomVerses': 'Random Quran Verses',
      'specificVerse': 'Specific Verse',
      'testReminder': 'Test Reminder',
      'notSet': 'Not Set',
      'selectName': 'Select Name',
      'selectVerse': 'Select Verse',
      'everyXMins': 'Every %s mins',
      'quietNotSet': 'Quiet hours not set',
      'quietFormat': '%s:00 - %s:00',
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

      // Tasbeeh
      // Search
      'search': 'سورہ تلاش کریں...',
      'surahList': 'سورہ فہرست',

      'tasbeeh': 'تسبیح',
      'tasbeehCounter': 'ذکر کاؤنٹر',
      'tap': 'ٹیپ کریں',
      'reset': 'ری سیٹ',
      'resetConfirm': 'کاؤنٹر ری سیٹ کریں؟',
      'yes': 'ہاں',
      'no': 'نہیں',

      // Reminder Screen
      'currentStatus': 'موجودہ ترتیبات',
      'intervalLabel': 'یاد دہانی کا وقفہ',
      'quietHours': 'خاموش اوقات',
      'quietStart': 'شروع',
      'quietEnd': 'اختتام',
      'reminderContent': 'یاد دہانی کا مواد',
      'allNames': 'تمام 99 نام (ترتیب وار)',
      'specificName': 'مخصوص نام',
      'randomVerses': 'قرآنی آیات بے ترتیب',
      'specificVerse': 'مخصوص آیت',
      'testReminder': 'یاد دہانی آزمائیں',
      'notSet': 'مقرر نہیں',
      'selectName': 'نام منتخب کریں',
      'selectVerse': 'آیت منتخب کریں',
      'everyXMins': 'ہر %s منٹ',
      'quietNotSet': 'خاموش اوقات مقرر نہیں',
      'quietFormat': '%s:00 - %s:00',
    },
  };
}
