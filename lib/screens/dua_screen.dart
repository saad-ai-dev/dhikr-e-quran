import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/dua.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import '../localization/app_strings.dart';

class DuaScreen extends StatefulWidget {
  final SettingsService settingsService;

  const DuaScreen({super.key, required this.settingsService});

  @override
  State<DuaScreen> createState() => _DuaScreenState();
}

class _DuaScreenState extends State<DuaScreen> {
  List<Dua> _duas = [];
  String? _selectedCategory;
  bool _isLoading = true;

  String get _lang => widget.settingsService.language;
  String _s(String key) => S.get(key, _lang);

  @override
  void initState() {
    super.initState();
    _loadDuas();
  }

  Future<void> _loadDuas() async {
    final json = await rootBundle.loadString('assets/json/duas.json');
    final list = jsonDecode(json) as List;
    setState(() {
      _duas = list.map((d) => Dua.fromJson(d)).toList();
      _isLoading = false;
    });
  }

  List<String> get _categories => _duas.map((d) => d.category).toSet().toList();

  List<Dua> get _filteredDuas => _selectedCategory == null
      ? _duas
      : _duas.where((d) => d.category == _selectedCategory).toList();

  void _copyDua(Dua dua) {
    final text =
        '${dua.arabic}\n\n${dua.transliteration}\n\n${dua.urdu}\n\n(${dua.reference})';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_lang == 'ur' ? 'دعا کاپی ہو گئی' : 'Dua copied',
            style: const TextStyle(fontFamily: 'NotoNastaliqUrdu')),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_s('duas'))),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Category filter chips
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    children: [
                      _FilterChip(
                        label: _lang == 'ur' ? 'سب' : 'All',
                        selected: _selectedCategory == null,
                        onTap: () => setState(() => _selectedCategory = null),
                      ),
                      ..._categories.map((cat) {
                        final dua = _duas.firstWhere((d) => d.category == cat);
                        return _FilterChip(
                          label:
                              _lang == 'ur' ? dua.categoryUr : dua.categoryEn,
                          selected: _selectedCategory == cat,
                          onTap: () => setState(() => _selectedCategory = cat),
                        );
                      }),
                    ],
                  ),
                ),
                // Dua list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: _filteredDuas.length,
                    itemBuilder: (_, i) {
                      final dua = _filteredDuas[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Category badge
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondaryColor
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _lang == 'ur'
                                        ? dua.categoryUr
                                        : dua.categoryEn,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: AppTheme.secondaryColor),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Arabic
                              Text(dua.arabic,
                                  textAlign: TextAlign.right,
                                  style: AppTheme.arabicBody),
                              const SizedBox(height: 8),
                              // Transliteration
                              Text(dua.transliteration,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                      color: AppTheme.secondaryColor)),
                              const SizedBox(height: 8),
                              // Urdu
                              Text(dua.urdu,
                                  textAlign: TextAlign.right,
                                  style: AppTheme.urduBody),
                              const SizedBox(height: 8),
                              // Reference + copy
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.copy_rounded,
                                        size: 16,
                                        color: AppTheme.secondaryColor),
                                    onPressed: () => _copyDua(dua),
                                    constraints: const BoxConstraints(
                                        minWidth: 30, minHeight: 30),
                                    padding: EdgeInsets.zero,
                                  ),
                                  Text(dua.reference,
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.secondaryColor
                : AppTheme.secondaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: selected ? Colors.white : AppTheme.secondaryColor,
              fontFamily: 'NotoNastaliqUrdu',
            ),
          ),
        ),
      ),
    );
  }
}
