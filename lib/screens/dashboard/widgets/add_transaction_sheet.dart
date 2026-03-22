import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../providers/transaction_provider.dart';
import '../../../providers/currency_provider.dart';
import '../../../models/category_type.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../../../core/l10n/app_localizations.dart';

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});
  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  bool _isExpense = true;
  int _selectedCategory = 0;
  DateTime _selectedDate = DateTime.now();
  final _noteController = TextEditingController();
  // Stores digits as typed, e.g. typing 1,2,0,0 → "1200" → displays as "12.00"
  String _digits = '';

  String get _amountDisplay {
    if (_digits.isEmpty) return '0.00';
    final padded = _digits.padLeft(3, '0'); // ensure at least 3 chars
    final intPart = padded.substring(0, padded.length - 2);
    final decPart = padded.substring(padded.length - 2);
    final intFormatted = int.parse(intPart).toString(); // removes leading zeros
    return '$intFormatted.$decPart';
  }

  double get _amountValue => double.tryParse(_amountDisplay) ?? 0.0;

  void _appendDigit(String d) => setState(() {
        if (_digits.length >= 8) return; // max 999999.99
        _digits += d;
      });

  void _backspace() => setState(() {
        if (_digits.isNotEmpty)
          _digits = _digits.substring(0, _digits.length - 1);
      });

  static const _categories = CategoryType.values;

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    if (_amountValue == 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l.enterAmount, style: GoogleFonts.dmSans()),
        backgroundColor: AppColors.expense,
      ));
      return;
    }
    await context.read<TransactionProvider>().addTransaction(
          amount: _amountValue,
          category: _categories[_selectedCategory],
          date: _selectedDate,
          isExpense: _isExpense,
          note: _noteController.text.trim(),
          currencyCode: context.read<CurrencyProvider>().selected.code,
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final l = AppLocalizations.of(context);
    final currency = context.watch<CurrencyProvider>();
    final tc = AppThemeColors.of(context);

    return Container(
      height: mq.size.height * 0.92,
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
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              children: [
                Text(l.addTransaction,
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
                    child: Icon(Icons.close, color: tc.textSecondary, size: 18),
                  ),
                ),
              ],
            ),
          ),
          // Scrollable body
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
              child: Column(
                children: [
                  // Toggle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                          color: tc.card,
                          borderRadius: BorderRadius.circular(25)),
                      child: Row(
                        children: [
                          _ToggleBtn(
                              label: l.expense,
                              active: _isExpense,
                              activeColor: AppColors.expense,
                              onTap: () => setState(() => _isExpense = true)),
                          _ToggleBtn(
                              label: l.income,
                              active: !_isExpense,
                              activeColor: AppColors.income,
                              onTap: () => setState(() => _isExpense = false)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Amount label
                  Text(l.amount,
                      style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: tc.textMuted,
                          letterSpacing: 1.4)),
                  const SizedBox(height: 12),
                  // Amount display — uses real currency symbol
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        currency.symbol,
                        style: GoogleFonts.dmSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: _isExpense
                                ? AppColors.expense
                                : AppColors.income),
                      ),
                      const SizedBox(width: 8),
                      Text(_amountDisplay,
                          style: GoogleFonts.dmSans(
                              fontSize: 52,
                              fontWeight: FontWeight.w800,
                              color: tc.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Numpad
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _NumPad(
                        onDigit: _appendDigit, onBackspace: _backspace, tc: tc),
                  ),
                  const SizedBox(height: 20),
                  // Category label
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(l.category,
                          style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: tc.textMuted,
                              letterSpacing: 1.4)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Category picker
                  SizedBox(
                    height: 58,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, i) {
                        final cat = _categories[i];
                        final selected = _selectedCategory == i;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary.withValues(alpha: 0.15)
                                  : tc.card,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(cat.emoji,
                                    style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 8),
                                Text(cat.label,
                                    style: GoogleFonts.dmSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: selected
                                            ? AppColors.primary
                                            : tc.textSecondary)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Date & Note
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: l.date,
                          value: _formatDate(_selectedDate, l),
                          tc: tc,
                          onTap: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (d != null) setState(() => _selectedDate = d);
                          },
                        ),
                        const SizedBox(height: 10),
                        _InfoRow(
                          icon: Icons.notes_rounded,
                          label: l.addNote,
                          value: l.optionalNote,
                          tc: tc,
                          controller: _noteController,
                          isNote: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // Save button — always pinned at bottom
          Padding(
            padding: EdgeInsets.fromLTRB(24, 8, 24, mq.padding.bottom + 16),
            child: ElevatedButton(
              onPressed: _save,
              child: Text(l.saveTransaction,
                  style: GoogleFonts.dmSans(
                      fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d, AppLocalizations l) {
    const months = [
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
    final isToday = d.year == DateTime.now().year &&
        d.month == DateTime.now().month &&
        d.day == DateTime.now().day;
    return isToday
        ? 'Today, ${months[d.month]} ${d.day}, ${d.year}'
        : '${months[d.month]} ${d.day}, ${d.year}';
  }
}

// ─── Toggle Button ────────────────────────────────────────────────────────────
class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;
  const _ToggleBtn({
    required this.label,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
              color: active ? activeColor : Colors.transparent,
              borderRadius: BorderRadius.circular(22)),
          child: Center(
            child: Text(label,
                style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.white : tc.textSecondary)),
          ),
        ),
      ),
    );
  }
}

// ─── Numpad ───────────────────────────────────────────────────────────────────
class _NumPad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final AppThemeColors tc;
  const _NumPad({
    required this.onDigit,
    required this.onBackspace,
    required this.tc,
  });

  @override
  Widget build(BuildContext context) {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: keys
          .map((row) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: row.asMap().entries.map((entry) {
                    final i = entry.key;
                    final k = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(left: i == 0 ? 0 : 12),
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
                                    borderRadius: BorderRadius.circular(12)),
                                child: Center(
                                  child: k == '⌫'
                                      ? Icon(Icons.backspace_outlined,
                                          color: tc.textSecondary, size: 20)
                                      : Text(k,
                                          style: GoogleFonts.dmSans(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w600,
                                              color: tc.textPrimary)),
                                ),
                              ),
                            ),
                    );
                  }).toList(),
                ),
              ))
          .toList(),
    );
  }
}

// ─── Info Row ─────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final AppThemeColors tc;
  final VoidCallback? onTap;
  final bool isNote;
  final TextEditingController? controller;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.tc,
    this.onTap,
    this.isNote = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
            color: tc.card, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: tc.surface, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: tc.textMuted,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 2),
                  isNote
                      ? TextField(
                          controller: controller,
                          style: GoogleFonts.dmSans(
                              fontSize: 14, color: tc.textPrimary),
                          decoration: InputDecoration(
                            hintText: value,
                            hintStyle: GoogleFonts.dmSans(
                                fontSize: 14, color: tc.textMuted),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            fillColor: Colors.transparent,
                          ),
                        )
                      : Text(value,
                          style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: tc.textPrimary)),
                ],
              ),
            ),
            if (!isNote)
              Icon(Icons.chevron_right, color: tc.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
