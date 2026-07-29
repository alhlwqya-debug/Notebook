import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الإعدادات')),
        body: ListView(
          children: [
            // Appearance section
            _SectionHeader(title: 'المظهر'),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('المظهر', style: TextStyle(fontFamily: 'Cairo')),
              subtitle: Text(_themeName(settings.themeMode), style: const TextStyle(fontFamily: 'Cairo')),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showThemePicker(context, settings.themeMode, notifier),
            ),
            const Divider(indent: 56),

            // Language section
            _SectionHeader(title: 'اللغة'),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('اللغة', style: TextStyle(fontFamily: 'Cairo')),
              subtitle: Text(
                settings.locale.languageCode == 'ar' ? 'العربية' : 'English',
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showLanguagePicker(context, settings.locale, notifier),
            ),
            const Divider(indent: 56),

            // Font section
            _SectionHeader(title: 'الخطوط'),
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('حجم الخط', style: TextStyle(fontFamily: 'Cairo')),
              subtitle: Text('${settings.fontSize.toInt()} نقطة', style: const TextStyle(fontFamily: 'Cairo')),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Slider(
                value: settings.fontSize,
                min: 12,
                max: 24,
                divisions: 6,
                label: settings.fontSize.toInt().toString(),
                onChanged: (v) => notifier.setFontSize(v),
              ),
            ),
            const Divider(indent: 56),

            // Auto save
            _SectionHeader(title: 'الحفظ'),
            SwitchListTile(
              secondary: const Icon(Icons.save),
              title: const Text('الحفظ التلقائي', style: TextStyle(fontFamily: 'Cairo')),
              subtitle: const Text('يحفظ التغييرات تلقائياً كل 5 ثوانٍ', style: TextStyle(fontFamily: 'Cairo')),
              value: settings.autoSave,
              onChanged: (v) => notifier.setAutoSave(v),
              activeColor: AppColors.primary,
            ),
            const Divider(indent: 56),

            // Storage section
            _SectionHeader(title: 'التخزين'),
            ListTile(
              leading: const Icon(Icons.storage),
              title: const Text('إدارة التخزين', style: TextStyle(fontFamily: 'Cairo')),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showStorageInfo(context),
            ),
            const Divider(indent: 56),

            // About section
            _SectionHeader(title: 'حول التطبيق'),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('حول التطبيق', style: TextStyle(fontFamily: 'Cairo')),
              subtitle: Text('الإصدار ${AppConstants.appVersion}', style: const TextStyle(fontFamily: 'Cairo')),
              onTap: () => _showAbout(context),
            ),
            const Divider(indent: 56),

            const SizedBox(height: 32),

            // Copyright
            Center(
              child: Text(
                AppConstants.appCopyright,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _themeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light: return 'فاتح';
      case ThemeMode.dark: return 'داكن';
      case ThemeMode.system: return 'تلقائي (النظام)';
    }
  }

  void _showThemePicker(BuildContext context, ThemeMode current, SettingsNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: SimpleDialog(
          title: const Text('اختر المظهر', style: TextStyle(fontFamily: 'Cairo')),
          children: [
            SimpleDialogOption(
              onPressed: () { notifier.setThemeMode(ThemeMode.light); Navigator.pop(ctx); },
              child: const Text('فاتح', style: TextStyle(fontFamily: 'Cairo')),
            ),
            SimpleDialogOption(
              onPressed: () { notifier.setThemeMode(ThemeMode.dark); Navigator.pop(ctx); },
              child: const Text('داكن', style: TextStyle(fontFamily: 'Cairo')),
            ),
            SimpleDialogOption(
              onPressed: () { notifier.setThemeMode(ThemeMode.system); Navigator.pop(ctx); },
              child: const Text('تلقائي (النظام)', style: TextStyle(fontFamily: 'Cairo')),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, Locale current, SettingsNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: SimpleDialog(
          title: const Text('اختر اللغة', style: TextStyle(fontFamily: 'Cairo')),
          children: [
            SimpleDialogOption(
              onPressed: () { notifier.setLocale(const Locale('ar', 'SA')); Navigator.pop(ctx); },
              child: const Text('العربية', style: TextStyle(fontFamily: 'Cairo')),
            ),
            SimpleDialogOption(
              onPressed: () { notifier.setLocale(const Locale('en', 'US')); Navigator.pop(ctx); },
              child: const Text('English', style: TextStyle(fontFamily: 'Cairo')),
            ),
          ],
        ),
      ),
    );
  }

  void _showStorageInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('إدارة التخزين', style: TextStyle(fontFamily: 'Cairo')),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('قاعدة البيانات: محلية (SQLite)', style: TextStyle(fontFamily: 'Cairo')),
              SizedBox(height: 8),
              Text('جميع البيانات محفوظة على الجهاز', style: TextStyle(fontFamily: 'Cairo')),
              SizedBox(height: 8),
              Text('لا يتطلب اتصالاً بالإنترنت', style: TextStyle(fontFamily: 'Cairo', color: Colors.green)),
            ],
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق'))],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationLegalese: AppConstants.appCopyright,
      children: const [
        SizedBox(height: 16),
        Text(
          'تطبيق احترافي لإدارة وإنشاء وتحرير جميع أنواع المستندات والدفاتر محلياً، مع دعم كامل للغة العربية.',
          style: TextStyle(fontFamily: 'Cairo'),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
