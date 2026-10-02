import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

const String workerUrl =
    'https://afghani-exchange-api.abdullah-alingari.workers.dev';

void main() {
  runApp(const AfghaniExchangeApp());
}

enum AppLanguage { pashto, dari, english }

class CurrencyInfo {
  final String code;
  final String flag;
  final String ps;
  final String fa;
  final String en;

  const CurrencyInfo({
    required this.code,
    required this.flag,
    required this.ps,
    required this.fa,
    required this.en,
  });

  String name(AppLanguage language) {
    switch (language) {
      case AppLanguage.pashto:
        return ps;
      case AppLanguage.dari:
        return fa;
      case AppLanguage.english:
        return en;
    }
  }
}

const List<CurrencyInfo> currencies = [
  CurrencyInfo(code: 'AFN', flag: '🇦🇫', ps: 'افغانۍ', fa: 'افغانی', en: 'Afghan Afghani'),
  CurrencyInfo(code: 'USD', flag: '🇺🇸', ps: 'امریکایي ډالر', fa: 'دالر آمریکا', en: 'US Dollar'),
  CurrencyInfo(code: 'EUR', flag: '🇪🇺', ps: 'یورو', fa: 'یورو', en: 'Euro'),
  CurrencyInfo(code: 'GBP', flag: '🇬🇧', ps: 'پونډ', fa: 'پوند', en: 'British Pound'),
  CurrencyInfo(code: 'PKR', flag: '🇵🇰', ps: 'پاکستانۍ روپۍ', fa: 'روپیه پاکستان', en: 'Pakistani Rupee'),
  CurrencyInfo(code: 'INR', flag: '🇮🇳', ps: 'هندي روپۍ', fa: 'روپیه هند', en: 'Indian Rupee'),
  CurrencyInfo(code: 'AED', flag: '🇦🇪', ps: 'اماراتي درهم', fa: 'درهم امارات', en: 'UAE Dirham'),
  CurrencyInfo(code: 'SAR', flag: '🇸🇦', ps: 'سعودي ریال', fa: 'ریال سعودی', en: 'Saudi Riyal'),
  CurrencyInfo(code: 'QAR', flag: '🇶🇦', ps: 'قطري ریال', fa: 'ریال قطر', en: 'Qatari Riyal'),
  CurrencyInfo(code: 'KWD', flag: '🇰🇼', ps: 'کویتي دینار', fa: 'دینار کویت', en: 'Kuwaiti Dinar'),
  CurrencyInfo(code: 'OMR', flag: '🇴🇲', ps: 'عماني ریال', fa: 'ریال عمان', en: 'Omani Rial'),
  CurrencyInfo(code: 'BHD', flag: '🇧🇭', ps: 'بحریني دینار', fa: 'دینار بحرین', en: 'Bahraini Dinar'),
  CurrencyInfo(code: 'TRY', flag: '🇹🇷', ps: 'ترکي لیره', fa: 'لیره ترکیه', en: 'Turkish Lira'),
  CurrencyInfo(code: 'CNY', flag: '🇨🇳', ps: 'چینایي یوان', fa: 'یوان چین', en: 'Chinese Yuan'),
  CurrencyInfo(code: 'JPY', flag: '🇯🇵', ps: 'جاپاني ین', fa: 'ین جاپان', en: 'Japanese Yen'),
  CurrencyInfo(code: 'KRW', flag: '🇰🇷', ps: 'کوریایي وان', fa: 'وون کوریه', en: 'South Korean Won'),
  CurrencyInfo(code: 'RUB', flag: '🇷🇺', ps: 'روسي روبل', fa: 'روبل روسیه', en: 'Russian Ruble'),
  CurrencyInfo(code: 'CAD', flag: '🇨🇦', ps: 'کاناډایي ډالر', fa: 'دالر کانادا', en: 'Canadian Dollar'),
  CurrencyInfo(code: 'AUD', flag: '🇦🇺', ps: 'اسټرالیایي ډالر', fa: 'دالر استرالیا', en: 'Australian Dollar'),
  CurrencyInfo(code: 'CHF', flag: '🇨🇭', ps: 'سویسي فرانک', fa: 'فرانک سویس', en: 'Swiss Franc'),
  CurrencyInfo(code: 'SEK', flag: '🇸🇪', ps: 'سویډني کرونا', fa: 'کرون سویدن', en: 'Swedish Krona'),
  CurrencyInfo(code: 'NOK', flag: '🇳🇴', ps: 'ناروېژي کرونا', fa: 'کرون ناروی', en: 'Norwegian Krone'),
  CurrencyInfo(code: 'DKK', flag: '🇩🇰', ps: 'ډنمارکي کرونا', fa: 'کرون دنمارک', en: 'Danish Krone'),
  CurrencyInfo(code: 'NZD', flag: '🇳🇿', ps: 'نیوزیلنډ ډالر', fa: 'دالر نیوزیلند', en: 'New Zealand Dollar'),
  CurrencyInfo(code: 'SGD', flag: '🇸🇬', ps: 'سنګاپوري ډالر', fa: 'دالر سنگاپور', en: 'Singapore Dollar'),
  CurrencyInfo(code: 'MYR', flag: '🇲🇾', ps: 'مالیزیایي رینګټ', fa: 'رینگت مالیزیا', en: 'Malaysian Ringgit'),
  CurrencyInfo(code: 'THB', flag: '🇹🇭', ps: 'تایلنډي بات', fa: 'بات تایلند', en: 'Thai Baht'),
  CurrencyInfo(code: 'IDR', flag: '🇮🇩', ps: 'اندونیزیایي روپیه', fa: 'روپیه اندونزی', en: 'Indonesian Rupiah'),
  CurrencyInfo(code: 'BDT', flag: '🇧🇩', ps: 'بنګله‌دېشي ټاکا', fa: 'تکه بنگلادش', en: 'Bangladeshi Taka'),
  CurrencyInfo(code: 'LKR', flag: '🇱🇰', ps: 'سریلانکایي روپۍ', fa: 'روپیه سریلانکا', en: 'Sri Lankan Rupee'),
  CurrencyInfo(code: 'NPR', flag: '🇳🇵', ps: 'نېپالي روپۍ', fa: 'روپیه نپال', en: 'Nepalese Rupee'),
  CurrencyInfo(code: 'IRR', flag: '🇮🇷', ps: 'ایراني ریال', fa: 'ریال ایران', en: 'Iranian Rial'),
  CurrencyInfo(code: 'IQD', flag: '🇮🇶', ps: 'عراقي دینار', fa: 'دینار عراق', en: 'Iraqi Dinar'),
  CurrencyInfo(code: 'EGP', flag: '🇪🇬', ps: 'مصري پونډ', fa: 'پوند مصر', en: 'Egyptian Pound'),
  CurrencyInfo(code: 'ZAR', flag: '🇿🇦', ps: 'سویلي افریقایي رنډ', fa: 'رند آفریقای جنوبی', en: 'South African Rand'),
  CurrencyInfo(code: 'BRL', flag: '🇧🇷', ps: 'برازیلي ریال', fa: 'رئال برزیل', en: 'Brazilian Real'),
  CurrencyInfo(code: 'MXN', flag: '🇲🇽', ps: 'مکسیکوي پیسو', fa: 'پزوی مکزیک', en: 'Mexican Peso'),
  CurrencyInfo(code: 'ARS', flag: '🇦🇷', ps: 'ارجنټایني پیسو', fa: 'پزوی آرژانتین', en: 'Argentine Peso'),
  CurrencyInfo(code: 'CLP', flag: '🇨🇱', ps: 'چیلي پیسو', fa: 'پزوی شیلی', en: 'Chilean Peso'),
  CurrencyInfo(code: 'COP', flag: '🇨🇴', ps: 'کولمبیایي پیسو', fa: 'پزوی کلمبیا', en: 'Colombian Peso'),
  CurrencyInfo(code: 'PHP', flag: '🇵🇭', ps: 'فلیپیني پیسو', fa: 'پزوی فیلیپین', en: 'Philippine Peso'),
  CurrencyInfo(code: 'VND', flag: '🇻🇳', ps: 'ویتنامي ډانګ', fa: 'دانگ ویتنام', en: 'Vietnamese Dong'),
  CurrencyInfo(code: 'PLN', flag: '🇵🇱', ps: 'پولنډي زلوټي', fa: 'زلوتی پولند', en: 'Polish Zloty'),
  CurrencyInfo(code: 'CZK', flag: '🇨🇿', ps: 'چېکي کرونا', fa: 'کرون جمهوری چک', en: 'Czech Koruna'),
  CurrencyInfo(code: 'HUF', flag: '🇭🇺', ps: 'هنګري فورینټ', fa: 'فورینت مجارستان', en: 'Hungarian Forint'),
  CurrencyInfo(code: 'RON', flag: '🇷🇴', ps: 'رومانیا لیو', fa: 'لئو رومانی', en: 'Romanian Leu'),
  CurrencyInfo(code: 'UAH', flag: '🇺🇦', ps: 'اوکرایني هریونیا', fa: 'هریونیا اوکراین', en: 'Ukrainian Hryvnia'),
  CurrencyInfo(code: 'ILS', flag: '🇮🇱', ps: 'اسراییلي شېکل', fa: 'شیکل اسرائیل', en: 'Israeli Shekel'),
  CurrencyInfo(code: 'JOD', flag: '🇯🇴', ps: 'اردني دینار', fa: 'دینار اردن', en: 'Jordanian Dinar'),
  CurrencyInfo(code: 'LBP', flag: '🇱🇧', ps: 'لبناني پونډ', fa: 'لیره لبنان', en: 'Lebanese Pound'),
  CurrencyInfo(code: 'MAD', flag: '🇲🇦', ps: 'مراکش درهم', fa: 'درهم مراکش', en: 'Moroccan Dirham'),
  CurrencyInfo(code: 'TND', flag: '🇹🇳', ps: 'تونسي دینار', fa: 'دینار تونس', en: 'Tunisian Dinar'),
  CurrencyInfo(code: 'KZT', flag: '🇰🇿', ps: 'قزاقستان ټېنګ', fa: 'تنگه قزاقستان', en: 'Kazakhstani Tenge'),
  CurrencyInfo(code: 'UZS', flag: '🇺🇿', ps: 'ازبک سوم', fa: 'سوم ازبکستان', en: 'Uzbekistani Som'),
  CurrencyInfo(code: 'TJS', flag: '🇹🇯', ps: 'تاجک سوموني', fa: 'سامانی تاجیکستان', en: 'Tajikistani Somoni'),
  CurrencyInfo(code: 'KGS', flag: '🇰🇬', ps: 'قرغز سوم', fa: 'سوم قرقیزستان', en: 'Kyrgyzstani Som'),
  CurrencyInfo(code: 'GEL', flag: '🇬🇪', ps: 'جورجیا لاري', fa: 'لاری گرجستان', en: 'Georgian Lari'),
];

CurrencyInfo infoFor(String code) {
  final known = currencies.where((c) => c.code == code).toList();
  if (known.isNotEmpty) return known.first;

  return CurrencyInfo(
    code: code,
    flag: '🌍',
    ps: code,
    fa: code,
    en: code,
  );
}

class HistoryItem {
  final double amount;
  final String from;
  final String to;
  final double result;
  final DateTime time;

  HistoryItem({
    required this.amount,
    required this.from,
    required this.to,
    required this.result,
    required this.time,
  });
}

class AfghaniExchangeApp extends StatefulWidget {
  const AfghaniExchangeApp({super.key});

  @override
  State<AfghaniExchangeApp> createState() => _AfghaniExchangeAppState();
}

class _AfghaniExchangeAppState extends State<AfghaniExchangeApp> {
  ThemeMode themeMode = ThemeMode.light;
  AppLanguage language = AppLanguage.pashto;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afghani Exchange',
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: 'Arial',
        colorSchemeSeed: const Color(0xFF087F5B),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Arial',
        colorSchemeSeed: const Color(0xFF00A878),
      ),
      home: ExchangeHome(
        language: language,
        themeMode: themeMode,
        onLanguageChanged: (value) => setState(() => language = value),
        onThemeChanged: (value) => setState(() => themeMode = value),
      ),
    );
  }
}

class ExchangeHome extends StatefulWidget {
  final AppLanguage language;
  final ThemeMode themeMode;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final ValueChanged<ThemeMode> onThemeChanged;

  const ExchangeHome({
    super.key,
    required this.language,
    required this.themeMode,
    required this.onLanguageChanged,
    required this.onThemeChanged,
  });

  @override
  State<ExchangeHome> createState() => _ExchangeHomeState();
}

class _ExchangeHomeState extends State<ExchangeHome>
    with SingleTickerProviderStateMixin {
  final TextEditingController amountController =
      TextEditingController(text: '1');

  Timer? refreshTimer;

  Map<String, double> rates = {};
  List<String> allCodes = ['AFN'];
  Set<String> favorites = {'USD', 'EUR', 'PKR', 'INR'};

  List<HistoryItem> history = [];

  String fromCode = 'USD';
  String toCode = 'AFN';

  bool loading = true;
  bool refreshing = false;
  String? errorMessage;
  DateTime? lastUpdated;

  late AnimationController animationController;

  String get ps {
    switch (widget.language) {
      case AppLanguage.pashto:
        return 'ps';
      case AppLanguage.dari:
        return 'fa';
      case AppLanguage.english:
        return 'en';
    }
  }

  String tr(String pashto, String dari, String english) {
    switch (widget.language) {
      case AppLanguage.pashto:
        return pashto;
      case AppLanguage.dari:
        return dari;
      case AppLanguage.english:
        return english;
    }
  }

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    loadRates();

    refreshTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => loadRates(silent: true),
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    amountController.dispose();
    animationController.dispose();
    super.dispose();
  }

  Future<void> loadRates({bool silent = false}) async {
    if (refreshing) return;

    if (!silent) {
      setState(() {
        loading = rates.isEmpty;
        errorMessage = null;
      });
    }

    refreshing = true;

    try {
      final client = HttpClient();

      final request = await client.getUrl(
        Uri.parse('$workerUrl?base=AFN'),
      );

      request.headers.set(
        HttpHeaders.acceptHeader,
        'application/json',
      );

      final response = await request.close();

      final body = await response.transform(utf8.decoder).join();

      client.close();

      if (response.statusCode != 200) {
        if (mounted) {
          setState(() {
            errorMessage = response.statusCode == 429
                ? tr(
                    'د API حد پوره شوی؛ مهرباني لږ انتظار وکړئ.',
                    'محدودیت API تکمیل شده؛ لطفاً کمی صبر کنید.',
                    'API rate limit reached. Please wait a little.',
                  )
                : tr(
                    'نرخونه اوس نشي راوړل کېدای.',
                    'نرخ‌ها فعلاً دریافت نمی‌شوند.',
                    'Rates could not be loaded right now.',
                  );
          });
        }
        return;
      }

      final decoded = jsonDecode(body);

      if (decoded is! Map) {
        throw Exception('Invalid server response');
      }

      final data = Map<String, dynamic>.from(decoded);

      if (data['success'] == false) {
        throw Exception(
          data['message']?.toString() ??
              data['error']?.toString() ??
              'API error',
        );
      }

      dynamic rawRates = data['rates'] ?? data['results'];

      if (rawRates is! Map) {
        throw Exception('No rates found');
      }

      final Map<String, double> newRates = {
        'AFN': 1.0,
      };

      rawRates.forEach((key, value) {
        final number = double.tryParse(value.toString());

        if (number != null && number > 0) {
          newRates[key.toString().toUpperCase()] = number;
        }
      });

      if (newRates.length < 2) {
        throw Exception('Not enough currencies');
      }

      final codes = newRates.keys.toList()..sort();

      if (!codes.contains('AFN')) {
        codes.insert(0, 'AFN');
      }

      if (mounted) {
        setState(() {
          rates = newRates;
          allCodes = codes;
          lastUpdated = DateTime.now();
          loading = false;
          refreshing = false;
          errorMessage = null;
        });

        animationController.forward(from: 0);
      }
    } catch (e) {
      refreshing = false;

      if (mounted) {
        setState(() {
          loading = false;

          if (rates.isEmpty) {
            errorMessage = tr(
              'نرخونه ترلاسه نه شول. انټرنېټ او Worker وګوره.',
              'نرخ‌ها دریافت نشد. اینترنت و Worker را بررسی کنید.',
              'Rates could not be loaded. Check internet and Worker.',
            );
          }
        });
      }
    }
  }

  double rateFor(String code) {
    return rates[code] ?? 0;
  }

  double convert() {
    final amount = double.tryParse(amountController.text) ?? 0;

    final fromRate = rateFor(fromCode);
    final toRate = rateFor(toCode);

    if (amount <= 0 || fromRate <= 0 || toRate <= 0) {
      return 0;
    }

    return (amount / fromRate) * toRate;
  }

  void swapCurrencies() {
    setState(() {
      final temp = fromCode;
      fromCode = toCode;
      toCode = temp;
    });
  }

  void addHistory() {
    final amount = double.tryParse(amountController.text) ?? 0;
    final result = convert();

    if (amount <= 0 || result <= 0) return;

    setState(() {
      history.insert(
        0,
        HistoryItem(
          amount: amount,
          from: fromCode,
          to: toCode,
          result: result,
          time: DateTime.now(),
        ),
      );

      if (history.length > 20) {
        history.removeLast();
      }
    });
  }

  void toggleFavorite(String code) {
    setState(() {
      if (favorites.contains(code)) {
        favorites.remove(code);
      } else {
        favorites.add(code);
      }
    });
  }

  String formatNumber(double value) {
    if (value == 0) return '0';

    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(2)}B';
    }

    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)}M';
    }

    if (value >= 1000) {
      return value.toStringAsFixed(2);
    }

    if (value >= 1) {
      return value.toStringAsFixed(4);
    }

    return value.toStringAsFixed(8);
  }

  String formatTime(DateTime? time) {
    if (time == null) return '--';

    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    final s = time.second.toString().padLeft(2, '0');

    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: widget.language == AppLanguage.english
          ? TextDirection.ltr
          : TextDirection.rtl,
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () => loadRates(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 175,
                backgroundColor:
                    isDark ? const Color(0xFF061A14) : const Color(0xFF087F5B),
                foregroundColor: Colors.white,
                actions: [
                  IconButton(
                    tooltip: tr('ژبه', 'زبان', 'Language'),
                    onPressed: showLanguageMenu,
                    icon: const Icon(Icons.language_rounded),
                  ),
                  IconButton(
                    tooltip: tr('شپه', 'شب', 'Dark mode'),
                    onPressed: () {
                      widget.onThemeChanged(
                        isDark ? ThemeMode.light : ThemeMode.dark,
                      );
                    },
                    icon: Icon(
                      isDark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                    ),
                  ),
                  IconButton(
                    tooltip: tr('تازه کول', 'تازه‌سازی', 'Refresh'),
                    onPressed: refreshing ? null : () => loadRates(),
                    icon: AnimatedRotation(
                      turns: refreshing ? 1 : 0,
                      duration: const Duration(milliseconds: 700),
                      child: const Icon(Icons.refresh_rounded),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? const [
                                Color(0xFF003D2C),
                                Color(0xFF071D17),
                              ]
                            : const [
                                Color(0xFF00A878),
                                Color(0xFF087F5B),
                                Color(0xFF064E3B),
                              ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          25,
                          20,
                          15,
                        ),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Row(
                            children: [
                              Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(.16),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(.25),
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    '🇦🇫',
                                    style: TextStyle(fontSize: 31),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Afghani Exchange',
                                      style: const TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      tr(
                                        'د اسعارو هوښیار بدلون',
                                        'تبدیل هوشمند اسعار',
                                        'Smart Currency Exchange',
                                      ),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white.withOpacity(.82),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: animationController,
                    curve: Curves.easeOut,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        buildStatusCard(isDark),
                        const SizedBox(height: 14),
                        buildConversionCard(isDark),
                        const SizedBox(height: 16),
                        buildQuickCurrencies(isDark),
                        const SizedBox(height: 16),
                        buildFeatures(isDark),
                        const SizedBox(height: 16),
                        buildHistory(isDark),
                        const SizedBox(height: 20),
                        buildDeveloperCard(isDark),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildStatusCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF10251F)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            offset: const Offset(0, 7),
            color: Colors.black.withOpacity(.06),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: errorMessage == null
                  ? const Color(0xFF087F5B).withOpacity(.12)
                  : Colors.orange.withOpacity(.13),
              shape: BoxShape.circle,
            ),
            child: Icon(
              errorMessage == null
                  ? Icons.cloud_done_rounded
                  : Icons.cloud_off_rounded,
              color: errorMessage == null
                  ? const Color(0xFF087F5B)
                  : Colors.orange,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  errorMessage == null
                      ? tr(
                          'نرخونه فعال دي',
                          'نرخ‌ها فعال هستند',
                          'Rates are live',
                        )
                      : tr(
                          'د نرخونو ستونزه',
                          'مشکل دریافت نرخ‌ها',
                          'Rate update problem',
                        ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  errorMessage ??
                      tr(
                        'هر ۶۰ ثانیې تازه کېږي',
                        'هر ۶۰ ثانیه تازه می‌شود',
                        'Updates every 60 seconds',
                      ),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (lastUpdated != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  tr('وروستی', 'آخرین', 'Last'),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  formatTime(lastUpdated),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget buildConversionCard(bool isDark) {
    final result = convert();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  Color(0xFF12352B),
                  Color(0xFF09231C),
                ]
              : const [
                  Color(0xFFE9FFF7),
                  Color(0xFFFFFFFF),
                ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFF087F5B).withOpacity(.14),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 30,
            offset: const Offset(0, 12),
            color: Colors.black.withOpacity(.08),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFF087F5B),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.currency_exchange_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tr(
                    'د اسعارو تبدیل',
                    'تبدیل ارز',
                    'Currency Conversion',
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${allCodes.length}+',
                style: const TextStyle(
                  color: Color(0xFF087F5B),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Text(
            tr('مقدار', 'مقدار', 'Amount'),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 7),

          TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            onChanged: (_) => setState(() {}),
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.calculate_rounded),
              hintText: '1',
              filled: true,
              fillColor: isDark
                  ? Colors.black.withOpacity(.15)
                  : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(17),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 15),

          buildCurrencySelector(
            title: tr('له', 'از', 'From'),
            code: fromCode,
            isDark: isDark,
            onTap: () async {
              final selected = await showCurrencyPicker(
                selected: fromCode,
              );

              if (selected != null) {
                setState(() => fromCode = selected);
              }
            },
          ),

          const SizedBox(height: 8),

          Center(
            child: Material(
              color: const Color(0xFF087F5B),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: swapCurrencies,
                child: const Padding(
                  padding: EdgeInsets.all(13),
                  child: Icon(
                    Icons.swap_vert_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          buildCurrencySelector(
            title: tr('ته', 'به', 'To'),
            code: toCode,
            isDark: isDark,
            onTap: () async {
              final selected = await showCurrencyPicker(
                selected: toCode,
              );

              if (selected != null) {
                setState(() => toCode = selected);
              }
            },
          ),

          const SizedBox(height: 18),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF087F5B),
                  Color(0xFF00A878),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  tr(
                    'د تبدیل نتیجه',
                    'نتیجه تبدیل',
                    'Conversion Result',
                  ),
                  style: TextStyle(
                    color: Colors.white.withOpacity(.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 7),
                FittedBox(
                  child: Text(
                    '${formatNumber(result)} ${infoFor(toCode).code}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 29,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${amountController.text} ${infoFor(fromCode).code}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: addHistory,
              icon: const Icon(Icons.add_chart_rounded),
              label: Text(
                tr(
                  'تاریخچه کې یې وساته',
                  'در تاریخچه ذخیره کن',
                  'Save to History',
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCurrencySelector({
    required String title,
    required String code,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final currency = infoFor(code);
    final rate = rateFor(code);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.black.withOpacity(.16)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.grey.withOpacity(.13),
          ),
        ),
        child: Row(
          children: [
            Text(
              currency.flag,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${currency.code} • ${currency.name(widget.language)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  if (rate > 0)
                    Text(
                      '1 AFN = ${formatNumber(rate)} ${currency.code}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded),
          ],
        ),
      ),
    );
  }

  Widget buildQuickCurrencies(bool isDark) {
    final codes = favorites
        .where((code) => allCodes.contains(code))
        .take(8)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(
            '⭐ خوښ اسعار',
            '⭐ ارزهای مورد علاقه',
            '⭐ Favorite Currencies',
          ),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 112,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: codes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, index) {
              final code = codes[index];
              final c = infoFor(code);

              return Container(
                width: 125,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF10251F)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                      color: Colors.black.withOpacity(.05),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          c.flag,
                          style: const TextStyle(fontSize: 23),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => toggleFavorite(code),
                          child: Icon(
                            Icons.star_rounded,
                            color: Colors.amber.shade600,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      code,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      formatNumber(rateFor(code)),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildFeatures(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(
            '🌍 د اسعارو لټون',
            '🌍 جستجوی ارزها',
            '🌍 Currency Search',
          ),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () => showAllCurrencies(),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? const [
                        Color(0xFF142C24),
                        Color(0xFF0B211A),
                      ]
                    : const [
                        Color(0xFFFFFFFF),
                        Color(0xFFEFFFF8),
                      ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF087F5B).withOpacity(.12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF087F5B).withOpacity(.12),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF087F5B),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr(
                          'ټول اسعار وګوره',
                          'دیدن همه ارزها',
                          'Browse All Currencies',
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${allCodes.length} ${tr('اسعار موجود دي', 'ارز موجود است', 'currencies available')}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 17),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildHistory(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                tr(
                  '📜 د تبدیل تاریخچه',
                  '📜 تاریخچه تبدیل',
                  '📜 Conversion History',
                ),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (history.isNotEmpty)
              TextButton(
                onPressed: () => setState(() => history.clear()),
                child: Text(
                  tr('پاکول', 'پاک کردن', 'Clear'),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (history.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF10251F)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 42,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(height: 8),
                Text(
                  tr(
                    'تر اوسه تاریخچه نشته',
                    'هنوز تاریخچه‌ای نیست',
                    'No conversion history yet',
                  ),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          )
        else
          ...history.take(5).map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 9),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF10251F)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFF087F5B),
                        child: Icon(
                          Icons.swap_horiz_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.amount} ${item.from} → ${formatNumber(item.result)} ${item.to}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              formatTime(item.time),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  Widget buildDeveloperCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF087F5B),
            Color(0xFF064E3B),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            blurRadius: 25,
            offset: const Offset(0, 10),
            color: const Color(0xFF087F5B).withOpacity(.25),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 31,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Abdullah ALOKOZAI',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tr(
                    'Afghani Exchange',
                    'Afghani Exchange',
                    'Afghani Exchange',
                  ),
                  style: TextStyle(
                    color: Colors.white.withOpacity(.78),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            '🇦🇫',
            style: TextStyle(fontSize: 30),
          ),
        ],
      ),
    );
  }

  Future<String?> showCurrencyPicker({
    required String selected,
  }) async {
    String query = '';

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = allCodes.where((code) {
              final c = infoFor(code);
              final q = query.toLowerCase();

              return code.toLowerCase().contains(q) ||
                  c.en.toLowerCase().contains(q) ||
                  c.ps.toLowerCase().contains(q) ||
                  c.fa.toLowerCase().contains(q);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * .82,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0B1713)
                    : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: TextField(
                      autofocus: true,
                      onChanged: (value) {
                        setModalState(() => query = value);
                      },
                      decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Icons.search_rounded),
                        hintText: tr(
                          'اسعار ولټوه...',
                          'جستجوی ارز...',
                          'Search currencies...',
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withOpacity(.06)
                            : Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(17),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, index) {
                        final code = filtered[index];
                        final c = infoFor(code);

                        return ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 2,
                          ),
                          leading: Text(
                            c.flag,
                            style: const TextStyle(fontSize: 28),
                          ),
                          title: Text(
                            '$code • ${c.name(widget.language)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: rates[code] != null
                              ? Text(
                                  '1 AFN = ${formatNumber(rates[code]!)} $code',
                                )
                              : null,
                          trailing: favorites.contains(code)
                              ? IconButton(
                                  onPressed: () {
                                    toggleFavorite(code);
                                    setModalState(() {});
                                  },
                                  icon: const Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber,
                                  ),
                                )
                              : IconButton(
                                  onPressed: () {
                                    toggleFavorite(code);
                                    setModalState(() {});
                                  },
                                  icon: const Icon(
                                    Icons.star_border_rounded,
                                  ),
                                ),
                          onTap: () =>
                              Navigator.pop(context, code),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void showAllCurrencies() {
    showCurrencyPicker(selected: 'AFN');
  }

  void showLanguageMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Text(
                  '🇦🇫',
                  style: TextStyle(fontSize: 25),
                ),
                title: const Text('پښتو'),
                onTap: () {
                  widget.onLanguageChanged(AppLanguage.pashto);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Text(
                  '🇦🇫',
                  style: TextStyle(fontSize: 25),
                ),
                title: const Text('دری'),
                onTap: () {
                  widget.onLanguageChanged(AppLanguage.dari);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Text(
                  '🇬🇧',
                  style: TextStyle(fontSize: 25),
                ),
                title: const Text('English'),
                onTap: () {
                  widget.onLanguageChanged(AppLanguage.english);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
