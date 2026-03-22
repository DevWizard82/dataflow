import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/budget_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/currency_provider.dart';
import '../../models/budget.dart';
import '../../models/category_type.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_theme_colors.dart';
import '../../core/l10n/app_localizations.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budgetProv = context.watch<BudgetProvider>();
    final txProv = context.watch<TransactionProvider>();
    final currency = context.watch<CurrencyProvider>();
    final tc = AppThemeColors.of(context);
    final l = AppLocalizations.of(context);
    final now = DateTime.now();

    final budgets = budgetProv.forMonth(now);
    final catSpend = txProv.categoryTotalsForMonth(now);
    final status = budgetProv.monthStatus(now, catSpend);

    return Scaffold(
      backgroundColor: tc.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _TopBar(tc: tc, l: l),
              const SizedBox(height: 28),
              Text(l.monthlyBudgets,
                  style: GoogleFonts.dmSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: tc.textPrimary)),
              const SizedBox(height: 6),
              Row(children: [
                Text('${_monthName(now.month).toUpperCase()} ${now.year}',
                    style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: tc.textSecondary,
                        letterSpacing: 1.2)),
                if (status != MonthStatus.noBudgets) ...[
                  const SizedBox(width: 8),
                  Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                          color: _statusColor(status), shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(_statusLabel(status, l),
                      style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _statusColor(status),
                          letterSpacing: 1.2)),
                ],
              ]),
              const SizedBox(height: 24),
              if (budgets.isEmpty)
                _EmptyBudgets(tc: tc, l: l)
              else
                ...budgets.map((b) {
                  final spent = catSpend[b.category] ?? 0.0;
                  return _BudgetCard(
                      budget: b,
                      spent: spent,
                      currency: currency,
                      tc: tc,
                      l: l);
                }),
              const SizedBox(height: 20),
              if (budgets.isNotEmpty)
                _InsightsCard(
                    budgets: budgets,
                    catSpend: catSpend,
                    currency: currency,
                    tc: tc,
                    l: l),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetSheet(context, now, tc, l),
        backgroundColor: AppColors.primary,
        elevation: 8,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  void _showAddBudgetSheet(BuildContext context, DateTime month,
      AppThemeColors tc, AppLocalizations l) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddBudgetSheet(month: month),
    );
  }

  Color _statusColor(MonthStatus s) {
    switch (s) {
      case MonthStatus.onTrack:
        return AppColors.income;
      case MonthStatus.warning:
        return AppColors.warning;
      case MonthStatus.critical:
        return AppColors.expense;
      case MonthStatus.noBudgets:
        return AppColors.textMuted;
    }
  }

  String _statusLabel(MonthStatus s, AppLocalizations l) {
    switch (s) {
      case MonthStatus.onTrack:
        return l.onTrack;
      case MonthStatus.warning:
        return l.get('warning');
      case MonthStatus.critical:
        return l.get('overBudget');
      case MonthStatus.noBudgets:
        return '';
    }
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

class _TopBar extends StatelessWidget {
  final AppThemeColors tc;
  final AppLocalizations l;
  const _TopBar({required this.tc, required this.l});
  @override
  Widget build(BuildContext context) => Row(children: [
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

class _BudgetCard extends StatelessWidget {
  final Budget budget;
  final double spent;
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

  const _BudgetCard(
      {required this.budget,
      required this.spent,
      required this.currency,
      required this.tc,
      required this.l});

  @override
  Widget build(BuildContext context) {
    final status = budget.status(spent);
    final progress = budget.utilizationRatio(spent);
    final pct = budget.utilizationLabel(spent);
    final isCritical = status == BudgetStatus.critical;
    final accentColor = _accentColor(status);

    return Dismissible(
      key: Key(budget.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
            color: AppColors.expense.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.expense, size: 24),
      ),
      onDismissed: (_) =>
          context.read<BudgetProvider>().deleteBudget(budget.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: tc.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border(left: BorderSide(color: accentColor, width: 3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(children: [
            Row(children: [
              Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                      color: tc.card, borderRadius: BorderRadius.circular(14)),
                  child: Center(
                      child: Text(budget.category.emoji,
                          style: const TextStyle(fontSize: 24)))),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(budget.category.label,
                        style: GoogleFonts.dmSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: tc.textPrimary)),
                    const SizedBox(height: 2),
                    Text(l.get('monthlyBudgetLabel'),
                        style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: tc.textMuted,
                            letterSpacing: 0.8)),
                  ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                RichText(
                  textAlign: TextAlign.end,
                  text: TextSpan(children: [
                    TextSpan(
                        text: currency.formatCompact(spent),
                        style: GoogleFonts.dmSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: isCritical
                                ? AppColors.expense
                                : tc.textPrimary)),
                    TextSpan(
                        text:
                            ' /\n${currency.formatCompact(budget.monthlyLimit)}',
                        style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: tc.textSecondary)),
                  ]),
                ),
              ]),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              isCritical
                  ? Row(children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: AppColors.expense, size: 13),
                      const SizedBox(width: 4),
                      Text(l.criticalLimit,
                          style: GoogleFonts.dmSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.expense,
                              letterSpacing: 0.8)),
                    ])
                  : Text(l.utilization,
                      style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: tc.textMuted,
                          letterSpacing: 0.8)),
              const Spacer(),
              Text(pct,
                  style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: accentColor)),
            ]),
            const SizedBox(height: 8),
            ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: tc.card,
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor))),
          ]),
        ),
      ),
    );
  }

  Color _accentColor(BudgetStatus s) {
    switch (s) {
      case BudgetStatus.onTrack:
        return AppColors.income;
      case BudgetStatus.warning:
        return AppColors.warning;
      case BudgetStatus.critical:
        return AppColors.expense;
    }
  }
}

class _InsightsCard extends StatelessWidget {
  final List<Budget> budgets;
  final Map<CategoryType, double> catSpend;
  final CurrencyProvider currency;
  final AppThemeColors tc;
  final AppLocalizations l;
  const _InsightsCard(
      {required this.budgets,
      required this.catSpend,
      required this.currency,
      required this.tc,
      required this.l});

  @override
  Widget build(BuildContext context) {
    Budget? bestBudget;
    double maxRemaining = 0;
    for (final b in budgets) {
      final remaining = b.remaining(catSpend[b.category] ?? 0);
      if (remaining > maxRemaining) {
        maxRemaining = remaining;
        bestBudget = b;
      }
    }
    final message = bestBudget != null && maxRemaining > 0
        ? '${l.flowInsights}: ${currency.format(maxRemaining)} ${l.get('remaining')} in ${bestBudget.category.label}.'
        : "You're right on track with all budgets this month!";

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: tc.surface, borderRadius: BorderRadius.circular(18)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.auto_awesome,
                color: AppColors.primary, size: 18)),
        const SizedBox(width: 14),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.flowInsights,
              style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: tc.textPrimary)),
          const SizedBox(height: 6),
          Text(message,
              style: GoogleFonts.dmSans(
                  fontSize: 13, color: tc.textSecondary, height: 1.5)),
        ])),
      ]),
    );
  }
}

class _EmptyBudgets extends StatelessWidget {
  final AppThemeColors tc;
  final AppLocalizations l;
  const _EmptyBudgets({required this.tc, required this.l});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
            child: Column(children: [
          Icon(Icons.account_balance_wallet_outlined,
              color: tc.textMuted, size: 48),
          const SizedBox(height: 16),
          Text(l.noBudgets,
              style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: tc.textSecondary)),
          const SizedBox(height: 8),
          Text(l.tapToAddBudget,
              style: GoogleFonts.dmSans(fontSize: 13, color: tc.textMuted)),
        ])),
      );
}

class _AddBudgetSheet extends StatefulWidget {
  final DateTime month;
  const _AddBudgetSheet({required this.month});
  @override
  State<_AddBudgetSheet> createState() => _AddBudgetSheetState();
}

class _AddBudgetSheetState extends State<_AddBudgetSheet> {
  int _selectedCategory = 0;
  String _digits = '';

  String get _amountDisplay {
    if (_digits.isEmpty) return '0.00';
    final padded = _digits.padLeft(3, '0');
    final intPart = padded.substring(0, padded.length - 2);
    final decPart = padded.substring(padded.length - 2);
    final intFormatted = int.parse(intPart).toString();
    return '$intFormatted.$decPart';
  }

  double get _amountValue => double.tryParse(_amountDisplay) ?? 0.0;

  void _appendDigit(String d) => setState(() {
        if (_digits.length >= 8) return;
        _digits += d;
      });

  void _backspace() => setState(() {
        if (_digits.isNotEmpty)
          _digits = _digits.substring(0, _digits.length - 1);
      });

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    if (_amountValue == 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l.get('enterBudgetAmount'), style: GoogleFonts.dmSans()),
        backgroundColor: AppColors.expense,
      ));
      return;
    }
    await context.read<BudgetProvider>().setBudget(
          category: CategoryType.values[_selectedCategory],
          monthlyLimit: _amountValue,
          month: widget.month,
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final tc = AppThemeColors.of(context);
    final l = AppLocalizations.of(context);

    return Container(
      height: mq.size.height * 0.85,
      decoration: BoxDecoration(
          color: tc.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(children: [
        Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: tc.textMuted, borderRadius: BorderRadius.circular(2))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(children: [
            Text(l.setBudget,
                style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: tc.textPrimary)),
            const Spacer(),
            GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: tc.card,
                        borderRadius: BorderRadius.circular(10)),
                    child:
                        Icon(Icons.close, color: tc.textSecondary, size: 18))),
          ]),
        ),
        Text(l.monthlyLimit,
            style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: tc.textMuted,
                letterSpacing: 1.4)),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(context.read<CurrencyProvider>().symbol,
              style: GoogleFonts.dmSans(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary)),
          const SizedBox(width: 8),
          Text(_amountDisplay,
              style: GoogleFonts.dmSans(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: tc.textPrimary)),
        ]),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child:
              _NumPad(onDigit: _appendDigit, onBackspace: _backspace, tc: tc),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(l.category,
                  style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: tc.textMuted,
                      letterSpacing: 1.4))),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 58,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: CategoryType.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final cat = CategoryType.values[i];
              final selected = _selectedCategory == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : tc.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color:
                            selected ? AppColors.primary : Colors.transparent,
                        width: 1.5),
                  ),
                  child: Row(children: [
                    Text(cat.emoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(cat.label,
                        style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? AppColors.primary
                                : tc.textSecondary)),
                  ]),
                ),
              );
            },
          ),
        ),
        const Spacer(),
        Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, mq.padding.bottom + 16),
          child: ElevatedButton(
            onPressed: _save,
            child: Text(l.saveBudget,
                style: GoogleFonts.dmSans(
                    fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }
}

class _NumPad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final AppThemeColors tc;
  const _NumPad(
      {required this.onDigit, required this.onBackspace, required this.tc});

  @override
  Widget build(BuildContext context) {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫']
    ];
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: keys
            .map((row) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: row.asMap().entries.map((e) {
                        final k = e.value;
                        return Padding(
                          padding: EdgeInsets.only(left: e.key == 0 ? 0 : 12),
                          child: k.isEmpty
                              ? const SizedBox(width: 72, height: 48)
                              : GestureDetector(
                                  onTap: () =>
                                      k == '⌫' ? onBackspace() : onDigit(k),
                                  child: Container(
                                      width: 72,
                                      height: 48,
                                      decoration: BoxDecoration(
                                          color: tc.card,
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Center(
                                          child: k == '⌫'
                                              ? Icon(Icons.backspace_outlined,
                                                  color: tc.textSecondary,
                                                  size: 20)
                                              : Text(k,
                                                  style: GoogleFonts.dmSans(
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: tc.textPrimary)))),
                                ),
                        );
                      }).toList()),
                ))
            .toList());
  }
}
