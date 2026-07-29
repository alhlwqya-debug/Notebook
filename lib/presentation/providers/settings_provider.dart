import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/constants/db_constants.dart';
import '../../data/datasources/local_database.dart';

class AppSettings {
  final ThemeMode themeMode;
  final Locale locale;
  final double fontSize;
  final bool autoSave;
  final String viewMode;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('ar', 'SA'),
    this.fontSize = 16.0,
    this.autoSave = true,
    this.viewMode = 'list',
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    double? fontSize,
    bool? autoSave,
    String? viewMode,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      fontSize: fontSize ?? this.fontSize,
      autoSave: autoSave ?? this.autoSave,
      viewMode: viewMode ?? this.viewMode,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final db = await LocalDatabase.instance.database;
      final maps = await db.query(DbConstants.settingsTable);
      final map = {for (final m in maps) m[DbConstants.colKey] as String: m[DbConstants.colValue] as String};

      ThemeMode themeMode;
      switch (map['theme']) {
        case 'light': themeMode = ThemeMode.light; break;
        case 'dark': themeMode = ThemeMode.dark; break;
        default: themeMode = ThemeMode.system;
      }

      Locale locale;
      switch (map['language']) {
        case 'en': locale = const Locale('en', 'US'); break;
        default: locale = const Locale('ar', 'SA');
      }

      state = AppSettings(
        themeMode: themeMode,
        locale: locale,
        fontSize: double.tryParse(map['font_size'] ?? '16') ?? 16.0,
        autoSave: (map['auto_save'] ?? 'true') == 'true',
        viewMode: map['view_mode'] ?? 'list',
      );
    } catch (_) {}
  }

  Future<void> _saveSetting(String key, String value) async {
    final db = await LocalDatabase.instance.database;
    await db.insert(
      DbConstants.settingsTable,
      {DbConstants.colKey: key, DbConstants.colValue: value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final val = mode == ThemeMode.light ? 'light' : mode == ThemeMode.dark ? 'dark' : 'system';
    await _saveSetting('theme', val);
  }

  Future<void> setLocale(Locale locale) async {
    state = state.copyWith(locale: locale);
    final lang = locale.languageCode;
    await _saveSetting('language', lang);
  }

  Future<void> setFontSize(double size) async {
    state = state.copyWith(fontSize: size);
    await _saveSetting('font_size', size.toString());
  }

  Future<void> setAutoSave(bool value) async {
    state = state.copyWith(autoSave: value);
    await _saveSetting('auto_save', value.toString());
  }

  Future<void> setViewMode(String mode) async {
    state = state.copyWith(viewMode: mode);
    await _saveSetting('view_mode', mode);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});
