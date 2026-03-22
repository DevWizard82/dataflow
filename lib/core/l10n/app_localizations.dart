import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('fr'),
    Locale('ar'),
  ];

  // ── All strings ────────────────────────────────────────────────────────────
  static final Map<String, Map<String, String>> _strings = {
    // ── General ──────────────────────────────────────────────────────────────
    'appName': {'en': 'DataFlow', 'fr': 'DataFlow', 'ar': 'داتافلو'},
    'cancel': {'en': 'Cancel', 'fr': 'Annuler', 'ar': 'إلغاء'},
    'save': {'en': 'Save', 'fr': 'Sauvegarder', 'ar': 'حفظ'},
    'delete': {'en': 'Delete', 'fr': 'Supprimer', 'ar': 'حذف'},
    'viewAll': {'en': 'View All', 'fr': 'Voir tout', 'ar': 'عرض الكل'},

    // ── Bottom Nav ────────────────────────────────────────────────────────────
    'navHome': {'en': 'Home', 'fr': 'Accueil', 'ar': 'الرئيسية'},
    'navAnalytics': {'en': 'Analytics', 'fr': 'Analyses', 'ar': 'التحليل'},
    'navBudgets': {'en': 'Budgets', 'fr': 'Budgets', 'ar': 'الميزانية'},
    'navSettings': {'en': 'Settings', 'fr': 'Paramètres', 'ar': 'الإعدادات'},

    // ── Dashboard ─────────────────────────────────────────────────────────────
    'monthlyBalance': {
      'en': 'MONTHLY BALANCE',
      'fr': 'SOLDE MENSUEL',
      'ar': 'الرصيد الشهري'
    },
    'income': {'en': 'Income', 'fr': 'Revenus', 'ar': 'الدخل'},
    'expenses': {'en': 'Expenses', 'fr': 'Dépenses', 'ar': 'المصاريف'},
    'spendingCategories': {
      'en': 'Spending Categories',
      'fr': 'Catégories',
      'ar': 'تصنيفات الإنفاق'
    },
    'totalSpent': {
      'en': 'TOTAL SPENT',
      'fr': 'TOTAL DÉPENSÉ',
      'ar': 'إجمالي الإنفاق'
    },
    'weeklyLimit': {
      'en': 'Weekly Limit',
      'fr': 'Limite Hebdomadaire',
      'ar': 'الحد الأسبوعي'
    },
    'setNewBudget': {
      'en': 'Set New Budget',
      'fr': 'Nouveau Budget',
      'ar': 'تعيين ميزانية'
    },
    'recentTransactions': {
      'en': 'Recent Transactions',
      'fr': 'Transactions Récentes',
      'ar': 'آخر المعاملات'
    },
    'last7Days': {
      'en': 'LAST 7 DAYS',
      'fr': '7 DERNIERS JOURS',
      'ar': 'آخر 7 أيام'
    },
    'noTransactions': {
      'en': 'No transactions yet — add one!',
      'fr': 'Aucune transaction — ajoutez-en une!',
      'ar': 'لا توجد معاملات — أضف واحدة!'
    },
    'noExpenses': {
      'en': 'No expenses yet',
      'fr': 'Aucune dépense',
      'ar': 'لا توجد مصاريف بعد'
    },

    // ── Add Transaction ───────────────────────────────────────────────────────
    'addTransaction': {
      'en': 'Add Transaction',
      'fr': 'Ajouter Transaction',
      'ar': 'إضافة معاملة'
    },
    'expense': {'en': 'Expense', 'fr': 'Dépense', 'ar': 'مصروف'},
    'amount': {'en': 'AMOUNT', 'fr': 'MONTANT', 'ar': 'المبلغ'},
    'category': {'en': 'CATEGORY', 'fr': 'CATÉGORIE', 'ar': 'الفئة'},
    'date': {'en': 'DATE', 'fr': 'DATE', 'ar': 'التاريخ'},
    'addNote': {'en': 'ADD NOTE', 'fr': 'AJOUTER NOTE', 'ar': 'إضافة ملاحظة'},
    'optionalNote': {
      'en': 'Optional note...',
      'fr': 'Note facultative...',
      'ar': 'ملاحظة اختيارية...'
    },
    'saveTransaction': {
      'en': 'Save Transaction',
      'fr': 'Sauvegarder',
      'ar': 'حفظ المعاملة'
    },
    'enterAmount': {
      'en': 'Please enter an amount',
      'fr': 'Veuillez entrer un montant',
      'ar': 'الرجاء إدخال المبلغ'
    },

    // ── Categories ────────────────────────────────────────────────────────────
    'catFood': {'en': 'Food', 'fr': 'Alimentation', 'ar': 'طعام'},
    'catTransport': {'en': 'Transport', 'fr': 'Transport', 'ar': 'مواصلات'},
    'catShopping': {'en': 'Shopping', 'fr': 'Shopping', 'ar': 'تسوق'},
    'catBills': {'en': 'Bills', 'fr': 'Factures', 'ar': 'فواتير'},
    'catHealth': {'en': 'Health', 'fr': 'Santé', 'ar': 'صحة'},
    'catEducation': {'en': 'Education', 'fr': 'Éducation', 'ar': 'تعليم'},
    'catIncome': {'en': 'Income', 'fr': 'Revenus', 'ar': 'دخل'},
    'catOther': {'en': 'Other', 'fr': 'Autre', 'ar': 'أخرى'},

    // ── Analytics ─────────────────────────────────────────────────────────────
    'weeklyOverview': {
      'en': 'WEEKLY OVERVIEW',
      'fr': 'VUE HEBDOMADAIRE',
      'ar': 'نظرة أسبوعية'
    },
    'fromLastWeek': {
      'en': 'from last week',
      'fr': 'par rapport à la semaine dernière',
      'ar': 'عن الأسبوع الماضي'
    },
    'categoryBreakdown': {
      'en': 'Category Breakdown',
      'fr': 'Répartition',
      'ar': 'تفصيل الفئات'
    },
    'highestExpense': {
      'en': 'HIGHEST EXPENSE',
      'fr': 'DÉPENSE MAXIMALE',
      'ar': 'أعلى مصروف'
    },
    'transactions': {
      'en': 'Transactions',
      'fr': 'Transactions',
      'ar': 'معاملة'
    },
    'noExpensesMonth': {
      'en': 'No expenses this month yet',
      'fr': 'Aucune dépense ce mois',
      'ar': 'لا مصاريف هذا الشهر'
    },

    // ── Budgets ───────────────────────────────────────────────────────────────
    'monthlyBudgets': {
      'en': 'Monthly Budgets',
      'fr': 'Budgets Mensuels',
      'ar': 'الميزانيات الشهرية'
    },
    'onTrack': {'en': 'ON TRACK', 'fr': 'EN RÈGLE', 'ar': 'في المسار'},
    'warning': {'en': 'WARNING', 'fr': 'ATTENTION', 'ar': 'تحذير'},
    'overBudget': {
      'en': 'OVER BUDGET',
      'fr': 'DÉPASSÉ',
      'ar': 'تجاوز الميزانية'
    },
    'utilization': {
      'en': 'UTILIZATION',
      'fr': 'UTILISATION',
      'ar': 'الاستخدام'
    },
    'criticalLimit': {
      'en': 'CRITICAL LIMIT',
      'fr': 'LIMITE CRITIQUE',
      'ar': 'حد حرج'
    },
    'monthlyBudgetLabel': {
      'en': 'MONTHLY BUDGET',
      'fr': 'BUDGET MENSUEL',
      'ar': 'الميزانية الشهرية'
    },
    'noBudgets': {
      'en': 'No budgets set yet',
      'fr': 'Aucun budget défini',
      'ar': 'لم يتم تعيين ميزانيات'
    },
    'tapToAddBudget': {
      'en': 'Tap + to add your first budget',
      'fr': 'Appuyez sur + pour ajouter',
      'ar': 'اضغط + لإضافة ميزانية'
    },
    'flowInsights': {
      'en': 'Flow Insights',
      'fr': 'Conseils Finances',
      'ar': 'رؤى مالية'
    },
    'setBudget': {
      'en': 'Set Budget',
      'fr': 'Définir Budget',
      'ar': 'تعيين الميزانية'
    },
    'monthlyLimit': {
      'en': 'MONTHLY LIMIT',
      'fr': 'LIMITE MENSUELLE',
      'ar': 'الحد الشهري'
    },
    'saveBudget': {
      'en': 'Save Budget',
      'fr': 'Sauvegarder Budget',
      'ar': 'حفظ الميزانية'
    },
    'enterBudgetAmount': {
      'en': 'Enter a budget amount',
      'fr': 'Entrez un montant',
      'ar': 'أدخل مبلغ الميزانية'
    },
    'swipeToDelete': {
      'en': 'Swipe left to delete',
      'fr': 'Glissez pour supprimer',
      'ar': 'اسحب لحذف'
    },

    // ── Settings ──────────────────────────────────────────────────────────────
    'settings': {'en': 'Settings', 'fr': 'Paramètres', 'ar': 'الإعدادات'},
    'preferences': {
      'en': 'PREFERENCES',
      'fr': 'PRÉFÉRENCES',
      'ar': 'التفضيلات'
    },
    'currency': {'en': 'Currency', 'fr': 'Devise', 'ar': 'العملة'},
    'currencySubtitle': {
      'en': 'Default transaction currency',
      'fr': 'Devise par défaut',
      'ar': 'عملة المعاملات الافتراضية'
    },
    'darkTheme': {
      'en': 'Dark Theme',
      'fr': 'Thème Sombre',
      'ar': 'الوضع الداكن'
    },
    'darkThemeSubtitle': {
      'en': 'Active display mode',
      'fr': 'Mode affichage',
      'ar': 'وضع العرض النشط'
    },
    'language': {'en': 'Language', 'fr': 'Langue', 'ar': 'اللغة'},
    'languageSubtitle': {
      'en': 'App display language',
      'fr': 'Langue de l\'app',
      'ar': 'لغة التطبيق'
    },
    'selectLanguage': {
      'en': 'Select Language',
      'fr': 'Choisir la langue',
      'ar': 'اختر اللغة'
    },
    'selectCurrency': {
      'en': 'Select Currency',
      'fr': 'Choisir la devise',
      'ar': 'اختر العملة'
    },
    'data': {'en': 'DATA', 'fr': 'DONNÉES', 'ar': 'البيانات'},
    'exportCsv': {'en': 'Export CSV', 'fr': 'Exporter CSV', 'ar': 'تصدير CSV'},
    'exportSubtitle': {
      'en': 'Download all financial records',
      'fr': 'Télécharger les données',
      'ar': 'تحميل جميع السجلات المالية'
    },
    'clearData': {
      'en': 'Clear All Data',
      'fr': 'Effacer les données',
      'ar': 'مسح جميع البيانات'
    },
    'clearSubtitle': {
      'en': 'This action cannot be undone',
      'fr': 'Action irréversible',
      'ar': 'لا يمكن التراجع عن هذا الإجراء'
    },
    'clearConfirmTitle': {
      'en': 'Clear All Data?',
      'fr': 'Effacer tout?',
      'ar': 'مسح جميع البيانات؟'
    },
    'clearConfirmBody': {
      'en': 'This will permanently delete all your transactions and budgets.',
      'fr':
          'Cela supprimera définitivement toutes vos transactions et budgets.',
      'ar': 'سيؤدي هذا إلى حذف جميع معاملاتك وميزانياتك نهائياً.'
    },
    'deleteEverything': {
      'en': 'Delete Everything',
      'fr': 'Tout supprimer',
      'ar': 'حذف كل شيء'
    },
    'noTransactionsExport': {
      'en': 'No transactions to export',
      'fr': 'Aucune transaction à exporter',
      'ar': 'لا توجد معاملات للتصدير'
    },
    'version': {
      'en': 'VERSION V1.0.0',
      'fr': 'VERSION V1.0.0',
      'ar': 'الإصدار V1.0.0'
    },
  };

  String get(String key) {
    final lang = locale.languageCode;
    return _strings[key]?[lang] ?? _strings[key]?['en'] ?? key;
  }

  // ── Shorthand getters ─────────────────────────────────────────────────────
  String get appName => get('appName');
  String get cancel => get('cancel');
  String get save => get('save');
  String get viewAll => get('viewAll');
  String get navHome => get('navHome');
  String get navAnalytics => get('navAnalytics');
  String get navBudgets => get('navBudgets');
  String get navSettings => get('navSettings');
  String get monthlyBalance => get('monthlyBalance');
  String get income => get('income');
  String get expenses => get('expenses');
  String get spendingCategories => get('spendingCategories');
  String get totalSpent => get('totalSpent');
  String get recentTransactions => get('recentTransactions');
  String get last7Days => get('last7Days');
  String get noTransactions => get('noTransactions');
  String get noExpenses => get('noExpenses');
  String get addTransaction => get('addTransaction');
  String get expense => get('expense');
  String get amount => get('amount');
  String get category => get('category');
  String get date => get('date');
  String get addNote => get('addNote');
  String get optionalNote => get('optionalNote');
  String get saveTransaction => get('saveTransaction');
  String get enterAmount => get('enterAmount');
  String get weeklyOverview => get('weeklyOverview');
  String get categoryBreakdown => get('categoryBreakdown');
  String get highestExpense => get('highestExpense');
  String get monthlyBudgets => get('monthlyBudgets');
  String get onTrack => get('onTrack');
  String get utilization => get('utilization');
  String get criticalLimit => get('criticalLimit');
  String get noBudgets => get('noBudgets');
  String get tapToAddBudget => get('tapToAddBudget');
  String get flowInsights => get('flowInsights');
  String get setBudget => get('setBudget');
  String get monthlyLimit => get('monthlyLimit');
  String get saveBudget => get('saveBudget');
  String get settings => get('settings');
  String get preferences => get('preferences');
  String get currency => get('currency');
  String get darkTheme => get('darkTheme');
  String get language => get('language');
  String get selectLanguage => get('selectLanguage');
  String get selectCurrency => get('selectCurrency');
  String get data => get('data');
  String get exportCsv => get('exportCsv');
  String get clearData => get('clearData');
  String get clearConfirmTitle => get('clearConfirmTitle');
  String get clearConfirmBody => get('clearConfirmBody');
  String get deleteEverything => get('deleteEverything');
  String get version => get('version');

  String categoryName(String key) =>
      get('cat${key[0].toUpperCase()}${key.substring(1)}');
}

// ── Delegate ──────────────────────────────────────────────────────────────────
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'fr', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_) => false;
}
