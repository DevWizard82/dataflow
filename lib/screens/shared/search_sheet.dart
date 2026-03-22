import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/app_theme_colors.dart';
import '../../core/l10n/app_localizations.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/currency_provider.dart';
import '../../models/transaction.dart';
import '../../models/category_type.dart';

void showSearchSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _SearchSheet(),
  );
}

class _SearchSheet extends StatefulWidget {
  const _SearchSheet();
  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  final _ctrl = TextEditingController();
  List<Transaction> _results = [];
  bool _searched = false;

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

  void _search(String query, List<Transaction> all) {
    final q = query.toLowerCase().trim();
    setState(() {
      _searched = true;
      if (q.isEmpty) {
        _results = [];
        return;
      }
      _results = all.where((t) {
        return t.note.toLowerCase().contains(q) ||
            t.category.label.toLowerCase().contains(q) ||
            t.amount.toString().contains(q);
      }).toList();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final tc = AppThemeColors.of(context);
    final all = context.read<TransactionProvider>().all;
    final currency = context.watch<CurrencyProvider>();

    return Container(
      height: mq.size.height * 0.85,
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: tc.textMuted, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(children: [
              Text('Search',
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
                      color: tc.card, borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.close, color: tc.textSecondary, size: 18),
                ),
              ),
            ]),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                  color: tc.card, borderRadius: BorderRadius.circular(14)),
              child: TextField(
                controller: _ctrl,
                autofocus: true,
                onChanged: (q) => _search(q, all),
                style: GoogleFonts.dmSans(color: tc.textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Search transactions...',
                  hintStyle: GoogleFonts.dmSans(color: tc.textMuted),
                  prefixIcon: Icon(Icons.search, color: tc.textMuted, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  fillColor: Colors.transparent,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Results
          Expanded(
            child: !_searched || _ctrl.text.isEmpty
                ? Center(
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search, color: tc.textMuted, size: 48),
                      const SizedBox(height: 12),
                      Text('Type to search',
                          style: GoogleFonts.dmSans(
                              color: tc.textMuted, fontSize: 14)),
                    ],
                  ))
                : _results.isEmpty
                    ? Center(
                        child: Text('No results found',
                            style: GoogleFonts.dmSans(
                                color: tc.textMuted, fontSize: 14)))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _results.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final t = _results[i];
                          final amountColor = t.isExpense
                              ? AppColors.expense
                              : AppColors.income;
                          final amountStr = t.isExpense
                              ? '-${currency.format(t.amount)}'
                              : '+${currency.format(t.amount)}';
                          final dateStr =
                              '${_months[t.date.month]} ${t.date.day}, ${t.date.year}';

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                                color: tc.card,
                                borderRadius: BorderRadius.circular(14)),
                            child: Row(children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: tc.surface,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Icon(
                                    _icons[t.category] ??
                                        Icons.category_rounded,
                                    color: tc.textSecondary,
                                    size: 18),
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
                                              color: tc.textPrimary)),
                                      Text('$dateStr • ${t.category.label}',
                                          style: GoogleFonts.dmSans(
                                              fontSize: 11,
                                              color: tc.textSecondary)),
                                    ]),
                              ),
                              Text(amountStr,
                                  style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: amountColor)),
                            ]),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
