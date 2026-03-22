import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/app_theme_colors.dart';
import '../../core/l10n/app_localizations.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/currency_provider.dart';

void showProfileSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ProfileSheet(),
  );
}

class _ProfileSheet extends StatelessWidget {
  const _ProfileSheet();

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final l = AppLocalizations.of(context);
    final tx = context.watch<TransactionProvider>();
    final currency = context.watch<CurrencyProvider>();
    final now = DateTime.now();

    final totalIncome = tx.totalIncomeForMonth(now);
    final totalExpenses = tx.totalExpensesForMonth(now);
    final balance = tx.balanceForMonth(now);
    final txCount = tx.forMonth(now).length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: tc.textMuted, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 24),
          // Avatar
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7B6FF7), Color(0xFF9B8FF9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6)),
              ],
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 14),
          Text(l.appName,
              style: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: tc.textPrimary)),
          const SizedBox(height: 4),
          Text('${_monthName(now.month)} ${now.year}',
              style: GoogleFonts.dmSans(fontSize: 13, color: tc.textSecondary)),
          const SizedBox(height: 28),
          // Stats row
          Row(
            children: [
              _StatTile(
                  label: l.income,
                  value: currency.format(totalIncome),
                  color: AppColors.income,
                  tc: tc),
              _Divider(tc: tc),
              _StatTile(
                  label: l.expenses,
                  value: currency.format(totalExpenses),
                  color: AppColors.expense,
                  tc: tc),
              _Divider(tc: tc),
              _StatTile(
                  label: 'Transactions',
                  value: '$txCount',
                  color: AppColors.primary,
                  tc: tc),
            ],
          ),
          const SizedBox(height: 24),
          // Balance card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7B6FF7), Color(0xFFB3A8FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.monthlyBalance,
                    style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.75),
                        letterSpacing: 1.2)),
                const SizedBox(height: 6),
                Text(currency.format(balance),
                    style: GoogleFonts.dmSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _monthName(int m) => const [
        '',
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ][m];
}

class _StatTile extends StatelessWidget {
  final String label, value;
  final Color color;
  final AppThemeColors tc;
  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
    required this.tc,
  });
  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(children: [
          Text(value,
              style: GoogleFonts.dmSans(
                  fontSize: 15, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 4),
          Text(label,
              style: GoogleFonts.dmSans(fontSize: 11, color: tc.textSecondary),
              textAlign: TextAlign.center),
        ]),
      );
}

class _Divider extends StatelessWidget {
  final AppThemeColors tc;
  const _Divider({required this.tc});
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 40, color: tc.divider);
}
