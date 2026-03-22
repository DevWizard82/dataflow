import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/transaction_provider.dart';
import '../../providers/currency_provider.dart';
import '../../models/category_type.dart';
import '../../models/transaction.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_theme_colors.dart';
import '../../core/l10n/app_localizations.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedDay = DateTime.now().weekday - 1;

  DateTime get _startOfCurrentWeek {
    final now = DateTime.now();
    return now.subtract(Duration(days: now.weekday - 1));
  }

  String _dayLabel(int i) =>
      const ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'][i];
  String _dateLabel(int i) =>
      '${_startOfCurrentWeek.add(Duration(days: i)).day}';

  @override
  Widget build(BuildContext context) {
    final tx = context.watch<TransactionProvider>();
    final currency = context.watch<CurrencyProvider>();
    final tc = AppThemeColors.of(context);
    final l = AppLocalizations.of(context);
    final now = DateTime.now();

    final dailyTotals = tx.weeklyDailyTotals;
    final weekTotal = tx.weeklyTotal;
    final wow = tx.weekOverWeekChange;
    final catTotals = tx.categoryTotalsForMonth(now);
    final totalSpent = tx.totalExpensesForMonth(now);
    final highestTx = tx.highestExpenseForMonth(now);

    final maxVal =
        dailyTotals.isEmpty ? 1.0 : dailyTotals.reduce((a, b) => a > b ? a : b);
    final barRatios =
        dailyTotals.map((v) => maxVal == 0 ? 0.0 : v / maxVal).toList();

    final sorted = catTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: tc.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _TopBar(tc: tc),
              const SizedBox(height: 24),
              _DaySelector(
                selected: _selectedDay,
                dayLabel: _dayLabel,
                dateLabel: _dateLabel,
                onSelect: (i) => setState(() => _selectedDay = i),
                tc: tc,
              ),
              const SizedBox(height: 24),
              Text(l.weeklyOverview,
                  style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: tc.textMuted,
                      letterSpacing: 1.4)),
              const SizedBox(height: 6),
              Row(children: [
                Text(currency.format(weekTotal),
                    style: GoogleFonts.dmSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: tc.textPrimary)),
                if (wow != null) ...[
                  const SizedBox(width: 12),
                  Row(children: [
                    Icon(wow <= 0 ? Icons.trending_down : Icons.trending_up,
                        color: wow <= 0 ? AppColors.income : AppColors.expense,
                        size: 16),
                    const SizedBox(width: 4),
                    Text(
                        '${wow.abs().toStringAsFixed(0)}% ${l.get('fromLastWeek')}',
                        style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: wow <= 0
                                ? AppColors.income
                                : AppColors.expense)),
                  ]),
                ],
              ]),
              const SizedBox(height: 20),
              _BarChart(
                  ratios: barRatios,
                  dailyTotals: dailyTotals,
                  selected: _selectedDay,
                  dayLabel: _dayLabel,
                  currency: currency,
                  tc: tc),
              const SizedBox(height: 28),
              Text(l.categoryBreakdown,
                  style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: tc.textPrimary)),
              const SizedBox(height: 16),
              if (sorted.isEmpty)
                _EmptyState(message: l.get('noExpensesMonth'), tc: tc)
              else
                ...sorted.map((e) => _CategoryCard(
                    category: e.key,
                    amount: e.value,
                    totalSpent: totalSpent,
                    currency: currency,
                    tc: tc)),
              const SizedBox(height: 20),
              if (highestTx != null)
                _HighestExpenseCard(
                    tx: highestTx, currency: currency, tc: tc, l: l),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final AppThemeColors tc;
  const _TopBar({required this.tc});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(children: [
      Text(l.appName,
          style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: tc.textPrimary)),
      const Spacer(),
      Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
              color: Color(0xFFD4A574), shape: BoxShape.circle),
          child: const Icon(Icons.person, color: Colors.white, size: 20)),
    ]);
  }
}

class _DaySelector extends StatelessWidget {
  final int selected;
  final String Function(int) dayLabel;
  final String Function(int) dateLabel;
  final ValueChanged<int> onSelect;
  final AppThemeColors tc;
  const _DaySelector(
      {required this.selected,
      required this.dayLabel,
      required this.dateLabel,
      required this.onSelect,
      required this.tc});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (i) {
          final isSelected = i == selected;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 42,
              height: 58,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(dayLabel(i),
                        style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : tc.textMuted,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Text(dateLabel(i),
                        style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color:
                                isSelected ? Colors.white : tc.textSecondary)),
                  ]),
            ),
          );
        }),
      );
}

class _BarChart extends StatelessWidget {
  final List<double> ratios, dailyTotals;
  final int selected;
  final String Function(int) dayLabel;
  final CurrencyProvider currency;
  final AppThemeColors tc;
  const _BarChart(
      {required this.ratios,
      required this.dailyTotals,
      required this.selected,
      required this.dayLabel,
      required this.currency,
      required this.tc});

  @override
  Widget build(BuildContext context) => Column(children: [
        if (dailyTotals[selected] > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
                '${dayLabel(selected)}: ${currency.format(dailyTotals[selected])}',
                style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
          ),
        SizedBox(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final isSelected = i == selected;
              return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 32,
                      height: (ratios[i] * 90).clamp(6.0, 90.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isSelected
                              ? [AppColors.primary, AppColors.primaryLight]
                              : [tc.surface, tc.card],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(dayLabel(i)[0],
                        style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color:
                                isSelected ? AppColors.primary : tc.textMuted,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400)),
                  ]);
            }),
          ),
        ),
      ]);
}

class _CategoryCard extends StatelessWidget {
  final CategoryType category;
  final double amount, totalSpent;
  final CurrencyProvider currency;
  final AppThemeColors tc;

  static const _icons = <CategoryType, IconData>{
    CategoryType.food: Icons.restaurant_rounded,
    CategoryType.transport: Icons.directions_car_rounded,
    CategoryType.shopping: Icons.shopping_bag_rounded,
    CategoryType.bills: Icons.lightbulb_rounded,
    CategoryType.health: Icons.favorite_rounded,
    CategoryType.education: Icons.menu_book_rounded,
    CategoryType.income: Icons.attach_money_rounded,
    CategoryType.other: Icons.category_rounded,
  };

  const _CategoryCard(
      {required this.category,
      required this.amount,
      required this.totalSpent,
      required this.currency,
      required this.tc});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final color = AppColors.categories[category.colorIndex];
    final progress =
        totalSpent > 0 ? (amount / totalSpent).clamp(0.0, 1.0) : 0.0;
    final pct =
        totalSpent > 0 ? '${(amount / totalSpent * 100).round()}%' : '0%';
    final txCount = context
        .read<TransactionProvider>()
        .expensesForMonth(DateTime.now())
        .where((t) => t.category == category)
        .length;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: tc.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        Row(children: [
          Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: tc.card, borderRadius: BorderRadius.circular(12)),
              child: Icon(_icons[category] ?? Icons.category_rounded,
                  color: color, size: 22)),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(category.label,
                    style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: tc.textPrimary)),
                Text('$txCount ${l.get('transactions')}',
                    style: GoogleFonts.dmSans(
                        fontSize: 12, color: tc.textSecondary)),
              ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(currency.format(amount),
                style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: tc.textPrimary)),
            Text(pct,
                style: GoogleFonts.dmSans(
                    fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          ]),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: tc.card,
                valueColor: AlwaysStoppedAnimation<Color>(color))),
      ]),
    );
  }
}

class _HighestExpenseCard extends StatelessWidget {
  final Transaction tx;
  final CurrencyProvider currency;
  final AppThemeColors tc;
  final AppLocalizations l;

  static const _icons = <CategoryType, IconData>{
    CategoryType.food: Icons.restaurant_rounded,
    CategoryType.transport: Icons.directions_car_rounded,
    CategoryType.shopping: Icons.shopping_bag_rounded,
    CategoryType.bills: Icons.lightbulb_rounded,
    CategoryType.health: Icons.favorite_rounded,
    CategoryType.education: Icons.menu_book_rounded,
    CategoryType.income: Icons.attach_money_rounded,
    CategoryType.other: Icons.category_rounded,
  };

  static const _months = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  const _HighestExpenseCard(
      {required this.tx,
      required this.currency,
      required this.tc,
      required this.l});

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${tx.category.label} • ${_months[tx.date.month]} ${tx.date.day}, ${tx.date.year}';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(20),
        border:
            const Border(left: BorderSide(color: AppColors.expense, width: 3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: AppColors.expense.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6)),
            child: Text(l.highestExpense,
                style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.expense,
                    letterSpacing: 1.0)),
          ),
          const Spacer(),
          Text(currency.format(tx.amount),
              style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: tc.textPrimary)),
        ]),
        const SizedBox(height: 10),
        Text(tx.note.isNotEmpty ? tx.note : tx.category.label,
            style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: tc.textPrimary)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: tc.card, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: tc.surface, borderRadius: BorderRadius.circular(10)),
                child: Icon(_icons[tx.category] ?? Icons.category_rounded,
                    color: tc.textSecondary, size: 18)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(tx.note.isNotEmpty ? tx.note : tx.category.label,
                      style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: tc.textPrimary)),
                  Text(dateStr,
                      style: GoogleFonts.dmSans(
                          fontSize: 12, color: tc.textSecondary)),
                ])),
            Icon(Icons.chevron_right, color: tc.textSecondary),
          ]),
        ),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final AppThemeColors tc;
  const _EmptyState({required this.message, required this.tc});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
            child: Text(message,
                style: GoogleFonts.dmSans(color: tc.textMuted, fontSize: 13))),
      );
}
