import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'dart:io';

import '../../providers/theme_provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/budget_provider.dart';
import '../../models/category_type.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_theme_colors.dart';
import '../../core/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final currency = context.watch<CurrencyProvider>();
    final locale = context.watch<LocaleProvider>();
    final l = AppLocalizations.of(context);
    final tc = AppThemeColors.of(context);

    return Scaffold(
      backgroundColor: tc.bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _TopBar(tc: tc, l: l),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── PREFERENCES ──────────────────────────────────────────
                    _SectionLabel(l.preferences, tc: tc),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                          color: tc.surface,
                          borderRadius: BorderRadius.circular(18)),
                      child: Column(
                        children: [
                          // Language
                          _SettingsTile(
                            icon: Icons.language_rounded,
                            iconBg: const Color(0xFF1E2D4A),
                            iconColor: AppColors.primary,
                            title: l.language,
                            subtitle: LocaleProvider.languageNames[
                                    locale.locale.languageCode] ??
                                'English',
                            tc: tc,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  LocaleProvider.languageFlags[
                                          locale.locale.languageCode] ??
                                      '🌐',
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.chevron_right,
                                    color: tc.textSecondary, size: 20),
                              ],
                            ),
                            onTap: () =>
                                _showLanguagePicker(context, locale, l, tc),
                          ),
                          Divider(color: tc.divider, height: 1, indent: 66),
                          // Currency
                          _SettingsTile(
                            icon: Icons.currency_exchange,
                            iconBg: const Color(0xFF1E2D4A),
                            iconColor: AppColors.primary,
                            title: l.currency,
                            subtitle: l.get('currencySubtitle'),
                            tc: tc,
                            trailing: GestureDetector(
                              onTap: () =>
                                  _showCurrencyPicker(context, currency, l, tc),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                    color: tc.card,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(currency.flag,
                                        style: const TextStyle(fontSize: 14)),
                                    const SizedBox(width: 6),
                                    Text(currency.selected.code,
                                        style: GoogleFonts.dmSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: tc.textPrimary)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Divider(color: tc.divider, height: 1, indent: 66),
                          // Dark theme
                          _SettingsTile(
                            icon: Icons.dark_mode_outlined,
                            iconBg: const Color(0xFF1E2D4A),
                            iconColor: AppColors.primary,
                            title: l.darkTheme,
                            subtitle: l.get('darkThemeSubtitle'),
                            tc: tc,
                            trailing: Switch(
                              value: theme.isDark,
                              onChanged: (v) => theme.setDark(v),
                              activeColor: AppColors.primary,
                              activeTrackColor:
                                  AppColors.primary.withValues(alpha: 0.3),
                              inactiveThumbColor: tc.textMuted,
                              inactiveTrackColor: tc.card,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    // ── DATA ─────────────────────────────────────────────────
                    _SectionLabel(l.data, tc: tc),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                          color: tc.surface,
                          borderRadius: BorderRadius.circular(18)),
                      child: Column(
                        children: [
                          _SettingsTile(
                            icon: Icons.download_rounded,
                            iconBg: const Color(0xFF1A3A2A),
                            iconColor: AppColors.income,
                            title: l.exportCsv,
                            subtitle: l.get('exportSubtitle'),
                            tc: tc,
                            trailing: Icon(Icons.chevron_right,
                                color: tc.textSecondary, size: 20),
                            onTap: () => _exportCSV(context, l),
                          ),
                          Divider(color: tc.divider, height: 1, indent: 66),
                          _SettingsTile(
                            icon: Icons.delete_outline_rounded,
                            iconBg: const Color(0xFF3A1A1A),
                            iconColor: AppColors.expense,
                            title: l.clearData,
                            subtitle: l.get('clearSubtitle'),
                            tc: tc,
                            titleColor: AppColors.expense,
                            subtitleColor: AppColors.expense,
                            trailing: Icon(Icons.warning_amber_rounded,
                                color: AppColors.expense.withValues(alpha: 0.7),
                                size: 20),
                            onTap: () => _confirmClear(context, l),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Footer
                    Center(
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shield_outlined,
                                  color: tc.textMuted, size: 14),
                              const SizedBox(width: 6),
                              Text(l.appName,
                                  style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: tc.textMuted)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(l.version,
                              style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: tc.textMuted,
                                  letterSpacing: 1.2)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, LocaleProvider locale,
      AppLocalizations l, AppThemeColors tc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: tc.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.selectLanguage,
                style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: tc.textPrimary)),
            const SizedBox(height: 16),
            ...LocaleProvider.supported.map((loc) {
              final code = loc.languageCode;
              final selected = locale.locale.languageCode == code;
              return ListTile(
                leading: Text(LocaleProvider.languageFlags[code] ?? '🌐',
                    style: const TextStyle(fontSize: 22)),
                title: Text(LocaleProvider.languageNames[code] ?? code,
                    style: GoogleFonts.dmSans(
                        color: selected ? AppColors.primary : tc.textPrimary,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500)),
                trailing: selected
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  locale.setLocale(loc);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context, CurrencyProvider currency,
      AppLocalizations l, AppThemeColors tc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: tc.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.selectCurrency,
                style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: tc.textPrimary)),
            const SizedBox(height: 16),
            ...CurrencyProvider.all.map((c) => ListTile(
                  leading: Text(c.flag, style: const TextStyle(fontSize: 22)),
                  title: Text('${c.code}  ${c.symbol}',
                      style: GoogleFonts.dmSans(
                          color: currency.selected.code == c.code
                              ? AppColors.primary
                              : tc.textPrimary,
                          fontWeight: currency.selected.code == c.code
                              ? FontWeight.w700
                              : FontWeight.w500)),
                  trailing: currency.selected.code == c.code
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    currency.setCurrency(c);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _exportCSV(BuildContext context, AppLocalizations l) async {
    final txProv = context.read<TransactionProvider>();
    final txns = txProv.all;

    if (txns.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text(l.get('noTransactionsExport'), style: GoogleFonts.dmSans()),
        backgroundColor: AppColors.darkCard,
      ));
      return;
    }

    final rows = <List<dynamic>>[
      ['Date', 'Type', 'Category', 'Amount', 'Note'],
      ...txns.map((t) => [
            '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}-${t.date.day.toString().padLeft(2, '0')}',
            t.isExpense ? 'Expense' : 'Income',
            t.category.label,
            t.amount.toStringAsFixed(2),
            t.note,
          ]),
    ];

    final csvString = const ListToCsvConverter().convert(rows);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/dataflow_export.csv');
    await file.writeAsString(csvString);
    await Share.shareXFiles([XFile(file.path)], subject: 'DataFlow Export');
  }

  void _confirmClear(BuildContext context, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppThemeColors.of(context).surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l.clearConfirmTitle,
            style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w700,
                color: AppThemeColors.of(context).textPrimary)),
        content: Text(l.clearConfirmBody,
            style: GoogleFonts.dmSans(
                color: AppThemeColors.of(context).textSecondary, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.cancel,
                style: GoogleFonts.dmSans(
                    color: AppThemeColors.of(context).textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              await context.read<TransactionProvider>().clearAll();
              await context.read<BudgetProvider>().clearAll();
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(l.deleteEverything,
                style: GoogleFonts.dmSans(
                    color: AppColors.expense, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─── Widgets ──────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final AppThemeColors tc;
  final AppLocalizations l;
  const _TopBar({required this.tc, required this.l});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            const Expanded(child: SizedBox()),
            Text(l.settings,
                style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: tc.textPrimary)),
            const Expanded(child: SizedBox()),
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                  color: Color(0xFFD4A574), shape: BoxShape.circle),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ],
        ),
      );
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final AppThemeColors tc;
  const _SectionLabel(this.label, {required this.tc});
  @override
  Widget build(BuildContext context) => Text(label,
      style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: tc.textMuted,
          letterSpacing: 1.4));
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, subtitle;
  final Color? titleColor, subtitleColor;
  final Widget trailing;
  final AppThemeColors tc;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.tc,
    this.titleColor,
    this.subtitleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: iconBg, borderRadius: BorderRadius.circular(11)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: titleColor ?? tc.textPrimary)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: subtitleColor ?? tc.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              trailing,
            ],
          ),
        ),
      );
}
