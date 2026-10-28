import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import '../localization/app_strings.dart';

class HadithScreen extends StatefulWidget {
  final SettingsService settingsService;

  const HadithScreen({super.key, required this.settingsService});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  List<Map<String, dynamic>> _collections = [];
  int _selectedCollection = 0;
  bool _isLoading = true;

  String get _lang => widget.settingsService.language;
  String _s(String key) => S.get(key, _lang);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final json = await rootBundle.loadString('assets/json/hadiths.json');
    final data = jsonDecode(json);
    setState(() {
      _collections = List<Map<String, dynamic>>.from(data['collections']);
      _isLoading = false;
    });
  }

  void _copyHadith(Map<String, dynamic> hadith) {
    final text =
        '${hadith['arabic']}\n\n${hadith['urdu']}\n\n${hadith['english']}\n\n(${hadith['reference']})';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_lang == 'ur' ? 'حدیث کاپی ہو گئی' : 'Hadith copied',
            style: const TextStyle(fontFamily: 'NotoNastaliqUrdu')),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_s('hadith'))),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Collection tabs
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: _collections.length,
                    itemBuilder: (_, i) {
                      final col = _collections[i];
                      final selected = i == _selectedCollection;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedCollection = i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppTheme.primaryColor
                                  : AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _lang == 'ur' ? col['name_ur'] : col['name_en'],
                              style: TextStyle(
                                fontSize: 12,
                                color: selected
                                    ? Colors.white
                                    : AppTheme.primaryColor,
                                fontFamily:
                                    _lang == 'ur' ? 'NotoNastaliqUrdu' : null,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Hadith list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount:
                        (_collections[_selectedCollection]['hadiths'] as List)
                            .length,
                    itemBuilder: (_, i) {
                      final hadith = (_collections[_selectedCollection]
                          ['hadiths'] as List)[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(hadith['arabic'],
                                  textAlign: TextAlign.right,
                                  style: AppTheme.arabicBody),
                              const SizedBox(height: 10),
                              Text(hadith['urdu'],
                                  textAlign: TextAlign.right,
                                  style: AppTheme.urduBody),
                              const SizedBox(height: 8),
                              Text(hadith['english'],
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                      color: AppTheme.textMuted)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.copy_rounded,
                                        size: 16,
                                        color: AppTheme.secondaryColor),
                                    onPressed: () => _copyHadith(hadith),
                                    constraints: const BoxConstraints(
                                        minWidth: 30, minHeight: 30),
                                    padding: EdgeInsets.zero,
                                  ),
                                  Text(hadith['reference'],
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textMuted)),
                                ],
                              ),
                            ],
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
}
