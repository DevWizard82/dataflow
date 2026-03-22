import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../../providers/transaction_provider.dart';
import '../../providers/currency_provider.dart';
import '../../models/category_type.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_theme_colors.dart';
import '../../core/l10n/app_localizations.dart';
import '../shared/profile_sheet.dart';
import '../shared/search_sheet.dart';
import '../shared/notifications_sheet.dart';
import 'all_transactions_screen.dart';
import 'widgets/add_transaction_sheet.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return Scaffold(
      backgroundColor: tc.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const _TopBar(),
              const SizedBox(height: 24),
              const _BalanceCard(),
              const SizedBox(height: 28),
              const _SpendingCategories(),
              const SizedBox(height: 28),
              const _RecentTransactions(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: const _FAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final l = AppLocalizations.of(context);
    final now = DateTime.now();

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.grid_view_rounded,
              color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 10),
        Text(l.appName,
            style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 0.3)),
        const Spacer(),
        // Search
        GestureDetector(
          onTap: () => showSearchSheet(context),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: tc.surface, borderRadius: BorderRadius.circular(10)),
            child:
                Icon(Icons.search_rounded, color: tc.textSecondary, size: 20),
          ),
        ),
        const SizedBox(width: 8),
        // Notifications with badge
        GestureDetector(
          onTap: () => showNotificationsSheet(context),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: tc.surface, borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.notifications_outlined,
                    color: tc.textSecondary, size: 20),
              ),
              // Red dot badge — always show to indicate feature is active
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: AppColors.expense, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Profile / Account
        GestureDetector(
          onTap: () => showProfileSheet(context),
          child: Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
                color: Color(0xFFD4A574), shape: BoxShape.circle),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }
}

// ─── Balance Card ─────────────────────────────────────────────────────────────
class _BalanceCard extends StatelessWidget {
  const _BalanceCard();
  @override
  Widget build(BuildContext context) {
    final tx = context.watch<TransactionProvider>();
    final currency = context.watch<CurrencyProvider>();
    final l = AppLocalizations.of(context);
    final now = DateTime.now();
    final balance = tx.balanceForMonth(now);
    final income = tx.totalIncomeForMonth(now);
    final expenses = tx.totalExpensesForMonth(now);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7B6FF7), Color(0xFF9B8FF9), Color(0xFFB3A8FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 30,
              offset: const Offset(0, 12)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
              bottom: 0,
              right: 0,
              child: CustomPaint(
                  size: const Size(160, 70), painter: _WavePainter())),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.monthlyBalance,
                  style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.75),
                      letterSpacing: 1.4)),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(currency.format(balance),
                    style: GoogleFonts.dmSans(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5)),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _BalanceChip(
                      icon: Icons.arrow_upward_rounded,
                      label: '+${currency.formatCompact(income)}',
                      sublabel: l.income,
                      color: AppColors.income),
                  _BalanceChip(
                      icon: Icons.arrow_downward_rounded,
                      label: '-${currency.formatCompact(expenses)}',
                      sublabel: l.expenses,
                      color: AppColors.expense),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceChip extends StatelessWidget {
  final IconData icon;
  final String label, sublabel;
  final Color color;
  const _BalanceChip(
      {required this.icon,
      required this.label,
      required this.sublabel,
      required this.color});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sublabel,
                    style: GoogleFonts.dmSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.7),
                        letterSpacing: 0.5)),
                Text(label,
                    style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ],
            ),
          ],
        ),
      );
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(
        Path()
          ..moveTo(0, size.height * 0.6)
          ..cubicTo(size.width * 0.2, size.height * 0.2, size.width * 0.5,
              size.height * 0.8, size.width, size.height * 0.3),
        paint);
    canvas.drawPath(
        Path()
          ..moveTo(0, size.height * 0.9)
          ..cubicTo(size.width * 0.3, size.height * 0.5, size.width * 0.6,
              size.height, size.width, size.height * 0.6),
        paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Spending Categories ──────────────────────────────────────────────────────
class _SpendingCategories extends StatelessWidget {
  const _SpendingCategories();

  @override
  Widget build(BuildContext context) {
    final tx = context.watch<TransactionProvider>();
    final currency = context.watch<CurrencyProvider>();
    final tc = AppThemeColors.of(context);
    final l = AppLocalizations.of(context);
    final now = DateTime.now();
    final totals = tx.categoryTotalsForMonth(now);
    final totalSpent = tx.totalExpensesForMonth(now);

    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top4 = sorted.take(4).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: tc.surface, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            children: [
              Text(l.spendingCategories,
                  style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: tc.textPrimary)),
              const Spacer(),
              Icon(Icons.more_horiz, color: tc.textMuted),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: totalSpent == 0
                ? Center(
                    child: Text(l.noExpenses,
                        style: GoogleFonts.dmSans(
                            color: tc.textMuted, fontSize: 13)))
                : CustomPaint(
                    painter: _DonutPainter(
                      segments: top4
                          .map((e) => (
                                e.value / totalSpent,
                                AppColors.categories[e.key.colorIndex],
                              ))
                          .toList(),
                    ),
                    child: Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(currency.format(totalSpent),
                            style: GoogleFonts.dmSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: tc.textPrimary)),
                        Text(l.totalSpent,
                            style: GoogleFonts.dmSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: tc.textSecondary,
                                letterSpacing: 1.2)),
                      ]),
                    ),
                  ),
          ),
          if (top4.isNotEmpty) ...[
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 3.5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: top4.map((e) {
                final pct = totalSpent > 0
                    ? '${(e.value / totalSpent * 100).round()}%'
                    : '0%';
                return _CatLegend(
                    label: e.key.label.toUpperCase(),
                    pct: pct,
                    color: AppColors.categories[e.key.colorIndex],
                    tc: tc);
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _CatLegend extends StatelessWidget {
  final String label, pct;
  final Color color;
  final AppThemeColors tc;
  const _CatLegend(
      {required this.label,
      required this.pct,
      required this.color,
      required this.tc});
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label,
                  style: GoogleFonts.dmSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: tc.textSecondary,
                      letterSpacing: 0.8)),
              Text(pct,
                  style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: tc.textPrimary)),
            ],
          ),
        ],
      );
}

class _DonutPainter extends CustomPainter {
  final List<(double, Color)> segments;
  const _DonutPainter({required this.segments});
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = math.min(cx, cy) - 10;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;
    double startAngle = -math.pi / 2;
    const gap = 0.04;
    for (final seg in segments) {
      paint.color = seg.$2;
      canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: radius),
          startAngle, seg.$1 * math.pi * 2 - gap, false, paint);
      startAngle += seg.$1 * math.pi * 2;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.segments != segments;
}

// ─── Recent Transactions ──────────────────────────────────────────────────────
class _RecentTransactions extends StatelessWidget {
  const _RecentTransactions();

  static const _icons = <CategoryType, IconData>{
    CategoryType.food: Icons.restaurant_rounded,
    CategoryType.transport: Icons.directions_car_outlined,
    CategoryType.shopping: Icons.shopping_bag_outlined,
    CategoryType.bills: Icons.lightbulb_outline,
    CategoryType.health: Icons.favorite_outline,
    CategoryType.education: Icons.menu_book_outlined,
    CategoryType.income: Icons.attach_money_rounded,
    CategoryType.other: Icons.category_outlined,
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
    final txns = context.watch<TransactionProvider>().recent(limit: 5);
    final currency = context.watch<CurrencyProvider>();
    final tc = AppThemeColors.of(context);
    final l = AppLocalizations.of(context);

    return Column(
      children: [
        Row(
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.recentTransactions,
                  style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: tc.textPrimary)),
              Text(l.last7Days,
                  style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: tc.textMuted,
                      letterSpacing: 1.1)),
            ]),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AllTransactionsScreen())),
              child: Text(l.viewAll,
                  style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (txns.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
                child: Text(l.noTransactions,
                    style:
                        GoogleFonts.dmSans(color: tc.textMuted, fontSize: 13))),
          )
        else
          ...txns.map((t) {
            final amountColor =
                t.isExpense ? AppColors.expense : AppColors.income;
            final amountStr = t.isExpense
                ? '-${currency.formatTransaction(t.amount, t.currencyCode)}'
                : '+${currency.formatTransaction(t.amount, t.currencyCode)}';
            final dateStr =
                '${_months[t.date.month]} ${t.date.day}, ${t.date.year}';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: tc.surface, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: tc.card,
                        borderRadius: BorderRadius.circular(12)),
                    child: Icon(_icons[t.category] ?? Icons.category_outlined,
                        color: tc.textSecondary, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.note.isNotEmpty ? t.note : t.category.label,
                              style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: tc.textPrimary)),
                          const SizedBox(height: 3),
                          Text('$dateStr • ${t.category.label}',
                              style: GoogleFonts.dmSans(
                                  fontSize: 12, color: tc.textSecondary)),
                        ]),
                  ),
                  const SizedBox(width: 8),
                  Row(children: [
                    Text(amountStr,
                        style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: amountColor)),
                    const SizedBox(width: 8),
                    Container(
                        width: 3,
                        height: 36,
                        decoration: BoxDecoration(
                            color: amountColor,
                            borderRadius: BorderRadius.circular(4))),
                  ]),
                ],
              ),
            );
          }),
      ],
    );
  }
}

// ─── FAB ──────────────────────────────────────────────────────────────────────
class _FAB extends StatelessWidget {
  const _FAB();
  @override
  Widget build(BuildContext context) => FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const AddTransactionSheet(),
        ),
        backgroundColor: AppColors.primary,
        elevation: 8,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      );
}
