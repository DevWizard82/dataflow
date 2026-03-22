import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/app_theme_colors.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/currency_provider.dart';
import '../../models/budget.dart';
import '../../models/category_type.dart';

void showNotificationsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _NotificationsSheet(),
  );
}

class _NotificationsSheet extends StatelessWidget {
  const _NotificationsSheet();

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final tc = AppThemeColors.of(context);
    final tx = context.watch<TransactionProvider>();
    final budgets = context.watch<BudgetProvider>();
    final currency = context.watch<CurrencyProvider>();
    final now = DateTime.now();

    final notifications = _buildNotifications(tx, budgets, currency, now, tc);

    return Container(
      height: mq.size.height * 0.75,
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: tc.textMuted, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(children: [
              Text('Notifications',
                  style: GoogleFonts.dmSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: tc.textPrimary)),
              const Spacer(),
              if (notifications.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.expense.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${notifications.length}',
                      style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.expense)),
                ),
              const SizedBox(width: 8),
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
          Expanded(
            child: notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.notifications_none_rounded,
                            color: tc.textMuted, size: 52),
                        const SizedBox(height: 12),
                        Text('All caught up!',
                            style: GoogleFonts.dmSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: tc.textSecondary)),
                        const SizedBox(height: 4),
                        Text('No alerts right now',
                            style: GoogleFonts.dmSans(
                                fontSize: 13, color: tc.textMuted)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) =>
                        _NotificationTile(data: notifications[i], tc: tc),
                  ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  List<_NotifData> _buildNotifications(
    TransactionProvider tx,
    BudgetProvider budgets,
    CurrencyProvider currency,
    DateTime now,
    AppThemeColors tc,
  ) {
    final List<_NotifData> notifs = [];
    final catSpend = tx.categoryTotalsForMonth(now);

    // Budget alerts
    for (final b in budgets.forMonth(now)) {
      final spent = catSpend[b.category] ?? 0;
      final status = b.status(spent);
      if (status == BudgetStatus.critical) {
        notifs.add(_NotifData(
          icon: Icons.warning_amber_rounded,
          color: AppColors.expense,
          title: '${b.category.label} budget exceeded!',
          subtitle:
              'Spent ${currency.format(spent)} of ${currency.format(b.monthlyLimit)} limit.',
          time: 'This month',
        ));
      } else if (status == BudgetStatus.warning) {
        notifs.add(_NotifData(
          icon: Icons.trending_up_rounded,
          color: AppColors.warning,
          title: '${b.category.label} budget at ${b.utilizationLabel(spent)}',
          subtitle:
              '${currency.format(b.remaining(spent))} remaining this month.',
          time: 'This month',
        ));
      }
    }

    // Recent large expense
    final highest = tx.highestExpenseForMonth(now);
    if (highest != null) {
      notifs.add(_NotifData(
        icon: Icons.receipt_long_rounded,
        color: AppColors.primary,
        title: 'Largest expense this month',
        subtitle:
            '${highest.note.isNotEmpty ? highest.note : highest.category.label} — ${currency.format(highest.amount)}',
        time: 'This month',
      ));
    }

    // Week-over-week
    final wow = tx.weekOverWeekChange;
    if (wow != null && wow > 20) {
      notifs.add(_NotifData(
        icon: Icons.bar_chart_rounded,
        color: AppColors.expense,
        title: 'Spending up ${wow.toStringAsFixed(0)}% this week',
        subtitle: 'You\'re spending more than last week.',
        time: 'This week',
      ));
    } else if (wow != null && wow < -20) {
      notifs.add(_NotifData(
        icon: Icons.savings_rounded,
        color: AppColors.income,
        title: 'Great job! Spending down ${wow.abs().toStringAsFixed(0)}%',
        subtitle: 'You\'re spending less than last week.',
        time: 'This week',
      ));
    }

    return notifs;
  }
}

class _NotifData {
  final IconData icon;
  final Color color;
  final String title, subtitle, time;
  const _NotifData({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}

class _NotificationTile extends StatelessWidget {
  final _NotifData data;
  final AppThemeColors tc;
  const _NotificationTile({required this.data, required this.tc});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: tc.card, borderRadius: BorderRadius.circular(14)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(data.icon, color: data.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.title,
                        style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: tc.textPrimary)),
                    const SizedBox(height: 3),
                    Text(data.subtitle,
                        style: GoogleFonts.dmSans(
                            fontSize: 12, color: tc.textSecondary)),
                  ]),
            ),
            const SizedBox(width: 8),
            Text(data.time,
                style: GoogleFonts.dmSans(fontSize: 10, color: tc.textMuted)),
          ],
        ),
      );
}
