import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/transaction_provider.dart';
import '../../providers/currency_provider.dart';
import '../../models/transaction.dart';
import '../../models/category_type.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_theme_colors.dart';
import '../../core/l10n/app_localizations.dart';

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});
  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  // null = all, true = expenses only, false = income only
  bool? _filter;

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

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final l = AppLocalizations.of(context);
    final tx = context.watch<TransactionProvider>();
    final currency = context.watch<CurrencyProvider>();

    var list = tx.all;
    if (_filter == true) list = list.where((t) => t.isExpense).toList();
    if (_filter == false) list = list.where((t) => !t.isExpense).toList();

    // Group by month
    final grouped = <String, List<Transaction>>{};
    for (final t in list) {
      final key = '${_months[t.date.month]} ${t.date.year}';
      grouped.putIfAbsent(key, () => []).add(t);
    }

    return Scaffold(
      backgroundColor: tc.bg,
      appBar: AppBar(
        backgroundColor: tc.bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: tc.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l.recentTransactions,
            style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: tc.textPrimary)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Filter chips ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  active: _filter == null,
                  color: AppColors.primary,
                  tc: tc,
                  onTap: () => setState(() => _filter = null),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: l.expenses,
                  active: _filter == true,
                  color: AppColors.expense,
                  tc: tc,
                  onTap: () =>
                      setState(() => _filter = _filter == true ? null : true),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: l.income,
                  active: _filter == false,
                  color: AppColors.income,
                  tc: tc,
                  onTap: () =>
                      setState(() => _filter = _filter == false ? null : false),
                ),
                const Spacer(),
                Text('${list.length} total',
                    style:
                        GoogleFonts.dmSans(fontSize: 12, color: tc.textMuted)),
              ],
            ),
          ),
          // ── List ──────────────────────────────────────────────────────
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            color: tc.textMuted, size: 52),
                        const SizedBox(height: 12),
                        Text(l.noTransactions,
                            style: GoogleFonts.dmSans(
                                color: tc.textMuted, fontSize: 14)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: grouped.length,
                    itemBuilder: (_, sectionIndex) {
                      final month = grouped.keys.elementAt(sectionIndex);
                      final txns = grouped[month]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Month header
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 10),
                            child: Text(month,
                                style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: tc.textSecondary,
                                    letterSpacing: 0.5)),
                          ),
                          // Transactions for this month
                          ...txns.map((t) {
                            final amountColor = t.isExpense
                                ? AppColors.expense
                                : AppColors.income;
                            final amountStr = t.isExpense
                                ? '-${currency.formatTransaction(t.amount, t.currencyCode)}'
                                : '+${currency.formatTransaction(t.amount, t.currencyCode)}';
                            final dateStr =
                                '${_months[t.date.month]} ${t.date.day}';

                            return Dismissible(
                              key: Key(t.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                    color: AppColors.expense
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(14)),
                                child: const Icon(Icons.delete_outline_rounded,
                                    color: AppColors.expense),
                              ),
                              onDismissed: (_) => context
                                  .read<TransactionProvider>()
                                  .deleteTransaction(t.id),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                    color: tc.surface,
                                    borderRadius: BorderRadius.circular(14)),
                                child: Row(children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                        color: tc.card,
                                        borderRadius:
                                            BorderRadius.circular(11)),
                                    child: Icon(
                                        _icons[t.category] ??
                                            Icons.category_rounded,
                                        color: AppColors
                                            .categories[t.category.colorIndex],
                                        size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          t.note.isNotEmpty
                                              ? t.note
                                              : t.category.label,
                                          style: GoogleFonts.dmSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: tc.textPrimary),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '$dateStr • ${t.category.label}',
                                          style: GoogleFonts.dmSans(
                                              fontSize: 11,
                                              color: tc.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(amountStr,
                                          style: GoogleFonts.dmSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: amountColor)),
                                      Text(t.currencyCode,
                                          style: GoogleFonts.dmSans(
                                              fontSize: 10,
                                              color: tc.textMuted)),
                                    ],
                                  ),
                                ]),
                              ),
                            );
                          }),
                        ],
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
  final bool active;
  final Color color;
  final AppThemeColors tc;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.active,
    required this.color,
    required this.tc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: active ? color.withValues(alpha: 0.15) : tc.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: active ? color : Colors.transparent, width: 1.5),
          ),
          child: Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: active ? color : tc.textSecondary)),
        ),
      );
}
