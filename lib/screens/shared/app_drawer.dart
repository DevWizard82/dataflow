import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/app_theme_colors.dart';
import '../../core/l10n/app_localizations.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/currency_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final l = AppLocalizations.of(context);
    final tx = context.watch<TransactionProvider>();
    final currency = context.watch<CurrencyProvider>();
    final now = DateTime.now();
    final balance = tx.balanceForMonth(now);

    return Drawer(
      backgroundColor: tc.bg,
      child: SafeArea(
        child: Column(
          children: [
            // ── Profile header ─────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7B6FF7), Color(0xFF9B8FF9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.person, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 14),
                  Text(l.appName,
                      style: GoogleFonts.dmSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(currency.format(balance),
                      style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.8))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ── Nav items ──────────────────────────────────────────────────
            _DrawerItem(
              icon: Icons.home_rounded,
              label: l.navHome,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _DrawerItem(
              icon: Icons.bar_chart_rounded,
              label: l.navAnalytics,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _DrawerItem(
              icon: Icons.account_balance_wallet_rounded,
              label: l.navBudgets,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _DrawerItem(
              icon: Icons.settings_rounded,
              label: l.navSettings,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Spacer(),
            Divider(color: tc.divider),
            _DrawerItem(
              icon: Icons.info_outline_rounded,
              label: 'DataFlow v1.0.0',
              onTap: () {},
              muted: true,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool muted;
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return ListTile(
      leading:
          Icon(icon, color: muted ? tc.textMuted : AppColors.primary, size: 22),
      title: Text(label,
          style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: muted ? tc.textMuted : tc.textPrimary)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }
}
