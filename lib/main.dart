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
  Map<int, String> localUrduAudioMap = {};
  bool isLoading = true;
  String statusMessage = "Initializing system assets...";

  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _nameAudioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  Timer? _reminderTimer;
  StreamSubscription? _playerCompleteSubscription;

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
    _playerCompleteSubscription?.cancel();
    _audioPlayer.dispose();
    _nameAudioPlayer.dispose();
    _stopTts();
    super.dispose();
  }

  // Runtime System Permission Engine
  Future<void> _requestAppPermissions() async {
    if (!Platform.isAndroid) return;
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

        // Download Urdu translation audio
        String urduAudioUrl = ayah['urdu_audio'];
        File urduFile = File('${appDocDir.path}/fatiha_001_${ayahNum}_ur.mp3');

        if (!await urduFile.exists()) {
          setState(() {
            statusMessage = "Downloading Ayah $ayahNum Urdu audio...";
          });
          await _downloadAudioFile(urduAudioUrl, urduFile);
        }

        if (await urduFile.exists()) {
          localUrduAudioMap[ayahNum] = urduFile.path;
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
  Future<void> _speakText(String text, {String language = "ur-PK", double rate = 0.45}) async {
    if (Platform.isLinux) {
      String espeakLang = language.startsWith("ar") ? "ar" : "ur";
      int speed = (150 * rate).round();
      await Process.run('espeak-ng', ['-v', espeakLang, '-s', '$speed', text]);
    } else {
      try {
        await _flutterTts.setLanguage(language);
        await _flutterTts.setSpeechRate(rate);
        await _flutterTts.speak(text);
      } catch (e) {
        print("TTS not available: $e");
      }
    }
  }

  Future<void> _stopTts() async {
    if (Platform.isLinux) {
      await Process.run('pkill', ['-f', 'espeak-ng']);
    } else {
      try {
        await _flutterTts.stop();
      } catch (e) {
        // TTS not available
      }
    }
  }

  StreamSubscription? _verseCompleteSubscription;

  Future<void> _executeAudioToTranslationPipeline(int ayahNumber, String urduText) async {
    await _audioPlayer.stop();
    await _nameAudioPlayer.stop();
    _verseCompleteSubscription?.cancel();
    _playerCompleteSubscription?.cancel();

    if (localAudioMap.containsKey(ayahNumber)) {
      await _audioPlayer.play(DeviceFileSource(localAudioMap[ayahNumber]!));

      _verseCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) async {
        _verseCompleteSubscription?.cancel();
        if (localUrduAudioMap.containsKey(ayahNumber)) {
          await _nameAudioPlayer.play(DeviceFileSource(localUrduAudioMap[ayahNumber]!));
        }
      });
    } else if (localUrduAudioMap.containsKey(ayahNumber)) {
      await _nameAudioPlayer.play(DeviceFileSource(localUrduAudioMap[ayahNumber]!));
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
        arabicText: nameData['arabic'],
        englishText: nameData['transliteration'],
        urduTranslation: nameData['urdu_meaning'],
      );

      // Play pre-recorded Arabic audio, then Urdu after it finishes
      await _nameAudioPlayer.stop();
      _playerCompleteSubscription?.cancel();
      await _nameAudioPlayer.play(AssetSource('audio/names/name_${nameIdx}_ar.mp3'));
      _playerCompleteSubscription = _nameAudioPlayer.onPlayerComplete.listen((event) async {
        _playerCompleteSubscription?.cancel();
        await _nameAudioPlayer.play(AssetSource('audio/names/name_${nameIdx}_ur.mp3'));
      });
    } else {
      int globalVerseIdx = await ReminderService.getNextVerseIndex(6236);
      int localIndex = ((globalVerseIdx - 1) % (surahData!['ayahs'].length as int));
      var verseData = surahData!['ayahs'][localIndex];

      _showPopUpModal(
        arabicText: verseData['arabic_text'],
        urduTranslation: verseData['urdu_text'],
      );

      _executeAudioToTranslationPipeline(
        verseData['ayah_number'],
        verseData['urdu_text'],
      );
    }
  }

  void _showPopUpModal({required String arabicText, String? englishText, required String urduTranslation}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.teal.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(arabicText, textAlign: TextAlign.center, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            if (englishText != null)
              Text(englishText, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, color: Colors.teal)),
            if (englishText != null)
              const SizedBox(height: 10),
            Text(urduTranslation, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, color: Colors.teal)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              _audioPlayer.stop();
              _nameAudioPlayer.stop();
              _playerCompleteSubscription?.cancel();
              _verseCompleteSubscription?.cancel();
              _stopTts();
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
