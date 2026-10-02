import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const AfghaniExchangeApp());
}

/// Cloudflare Worker URL
/// API Key دلته مه لیکئ.
const String rateServerUrl =
    'https://afghani-exchange-api.abdullah-alingari.workers.dev';

const Duration refreshDuration = Duration(seconds: 60);

class Currency {
  final String code;
  final String name;
  final String flag;

  const Currency(
    this.code,
    this.name,
    this.flag,
  );
}

/// 40 اسعار
const List<Currency> currencies = [
  Currency('AFN', 'افغانۍ', '🇦🇫'),
  Currency('USD', 'امریکايي ډالر', '🇺🇸'),
  Currency('PKR', 'پاکستانۍ روپۍ', '🇵🇰'),
  Currency('INR', 'هندي روپۍ', '🇮🇳'),
  Currency('AED', 'اماراتي درهم', '🇦🇪'),
  Currency('SAR', 'سعودي ریال', '🇸🇦'),
  Currency('EUR', 'یورو', '🇪🇺'),
  Currency('GBP', 'برتانوي پونډ', '🇬🇧'),
  Currency('CNY', 'چینایي یوان', '🇨🇳'),
  Currency('TRY', 'ترکي لیره', '🇹🇷'),
  Currency('CAD', 'کاناډایي ډالر', '🇨🇦'),
  Currency('AUD', 'اسټرالیايي ډالر', '🇦🇺'),
  Currency('JPY', 'جاپاني ین', '🇯🇵'),
  Currency('CHF', 'سویسي فرانک', '🇨🇭'),
  Currency('QAR', 'قطري ریال', '🇶🇦'),
  Currency('KWD', 'کویتي دینار', '🇰🇼'),
  Currency('OMR', 'عماني ریال', '🇴🇲'),
  Currency('BHD', 'بحریني دینار', '🇧🇭'),
  Currency('IRR', 'ایراني ریال', '🇮🇷'),
  Currency('RUB', 'روسي روبل', '🇷🇺'),
  Currency('MYR', 'مالیزیايي رینګټ', '🇲🇾'),
  Currency('THB', 'تایلنډي بات', '🇹🇭'),
  Currency('IDR', 'اندونیزیايي روپیه', '🇮🇩'),
  Currency('BDT', 'بنګله دېشي ټکه', '🇧🇩'),
  Currency('NPR', 'نېپالي روپۍ', '🇳🇵'),
  Currency('LKR', 'سریلانکایي روپۍ', '🇱🇰'),
  Currency('EGP', 'مصري پونډ', '🇪🇬'),
  Currency('ZAR', 'سویلي افریقایي رنډ', '🇿🇦'),
  Currency('SEK', 'سویډني کرونا', '🇸🇪'),
  Currency('NOK', 'ناروېژي کرونا', '🇳🇴'),
  Currency('DKK', 'ډنمارکي کرونا', '🇩🇰'),
  Currency('NZD', 'نیوزیلنډي ډالر', '🇳🇿'),
  Currency('SGD', 'سنګاپوري ډالر', '🇸🇬'),
  Currency('HKD', 'هانګ کانګي ډالر', '🇭🇰'),
  Currency('KRW', 'کوریایي وان', '🇰🇷'),
  Currency('UZS', 'ازبکستاني سوم', '🇺🇿'),
  Currency('TJS', 'تاجکستاني سوموني', '🇹🇯'),
  Currency('KZT', 'قزاقستاني ټینګي', '🇰🇿'),
  Currency('AZN', 'اذربایجاني منات', '🇦🇿'),
  Currency('GEL', 'ګرجستاني لاري', '🇬🇪'),
];

class AfghaniExchangeApp extends StatefulWidget {
  const AfghaniExchangeApp({super.key});

  @override
  State<AfghaniExchangeApp> createState() =>
      _AfghaniExchangeAppState();
}

class _AfghaniExchangeAppState
    extends State<AfghaniExchangeApp> {
  ThemeMode themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afghani Exchange',
      themeMode: themeMode,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff087F5B),
        ),
        scaffoldBackgroundColor:
            const Color(0xffF4F8F5),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        inputDecorationTheme:
            InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(25),
          ),
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff20C997),
          brightness: Brightness.dark,
        ),
        inputDecorationTheme:
            InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(25),
          ),
        ),
      ),

      home: HomePage(
        onThemeChanged: (dark) {
          setState(() {
            themeMode = dark
                ? ThemeMode.dark
                : ThemeMode.light;
          });
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final ValueChanged<bool> onThemeChanged;

  const HomePage({
    super.key,
    required this.onThemeChanged,
  });

  @override
  State<HomePage> createState() =>
      _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  String from = 'AFN';
  String to = 'USD';

  double amount = 1;
  double rate = 0;

  bool loading = false;
  String? error;

  DateTime? lastUpdated;

  Timer? refreshTimer;

  late AnimationController animationController;

  final amountController =
      TextEditingController(text: '1');

  final searchController =
      TextEditingController();

  final Set<String> favorites = {
    'USD',
    'PKR',
    'INR',
    'AED',
    'SAR',
  };

  final List<String> conversionHistory = [];

  @override
  void initState() {
    super.initState();

    animationController =
        AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 900),
    );

    animationController.forward();

    loadRate();

    refreshTimer = Timer.periodic(
      refreshDuration,
      (_) => loadRate(),
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    animationController.dispose();
    amountController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadRate() async {
    if (loading) return;

    if (from == to) {
      setState(() {
        rate = 1;
        loading = false;
        error = null;
        lastUpdated = DateTime.now();
      });
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final uri = Uri.parse(
        rateServerUrl,
      ).replace(
        queryParameters: {
          'base': from,
          'currencies': to,
          'resolution': '1m',
        },
      );

      final response = await http
          .get(uri)
          .timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode != 200) {
        throw Exception(
          'HTTP ${response.statusCode}',
        );
      }

      final data = jsonDecode(
        response.body,
      );

      if (data is! Map) {
        throw Exception(
          'Invalid response',
        );
      }

      final dynamic rates =
          data['rates'] ??
          data['results'];

      if (rates is! Map) {
        throw Exception(
          'Rates not found',
        );
      }

      final dynamic value = rates[to];

      if (value == null) {
        throw Exception(
          'Currency not found',
        );
      }

      final newRate =
          (value as num).toDouble();

      if (!mounted) return;

      setState(() {
        rate = newRate;
        loading = false;
        error = null;
        lastUpdated = DateTime.now();
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error =
            'نرخ ترلاسه نه شو.\n'
            'انټرنېټ یا د نرخ سرور وګورئ.';
      });
    }
  }

  Currency getCurrency(String code) {
    return currencies.firstWhere(
      (item) => item.code == code,
    );
  }

  void swap() {
    setState(() {
      final old = from;
      from = to;
      to = old;
    });

    loadRate();
  }

  void changeAmount(String value) {
    final parsed = double.tryParse(
      value.replaceAll(',', ''),
    );

    if (parsed == null) return;

    setState(() {
      amount = parsed;
    });
  }

  String formatNumber(double value) {
    if (value == 0) return '0';

    if (value >= 1000) {
      return value.toStringAsFixed(2);
    }

    if (value >= 1) {
      return value.toStringAsFixed(4);
    }

    return value.toStringAsFixed(6);
  }

  String convertedResult() {
    return formatNumber(
      amount * rate,
    );
  }

  String formatTime(DateTime value) {
    return '${value.hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}:'
        '${value.second.toString().padLeft(2, '0')}';
  }

  void saveConversion() {
    if (rate <= 0) return;

    final item =
        '${formatNumber(amount)} $from'
        ' = '
        '${convertedResult()} $to';

    setState(() {
      conversionHistory.insert(
        0,
        item,
      );

      if (conversionHistory.length > 20) {
        conversionHistory.removeLast();
      }
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'تبدیل تاریخچه کې ثبت شو ✅',
        ),
        duration:
            Duration(seconds: 1),
      ),
    );
  }

  void chooseCurrency(
    String code,
    bool isFrom,
  ) {
    setState(() {
      if (isFrom) {
        from = code;
      } else {
        to = code;
      }
    });

    Navigator.pop(context);
    loadRate();
  }

  @override
  Widget build(BuildContext context) {
    final filtered =
        currencies.where((item) {
      final query =
          searchController.text
              .toLowerCase()
              .trim();

      return item.code
              .toLowerCase()
              .contains(query) ||
          item.name
              .toLowerCase()
              .contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Afghani Exchange',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Dark Mode',
            onPressed: () {
              final dark =
                  Theme.of(context)
                      .brightness ==
                  Brightness.dark;

              widget.onThemeChanged(
                !dark,
              );
            },
            icon: Icon(
              Theme.of(context)
                          .brightness ==
                      Brightness.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: loadRate,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding:
              const EdgeInsets.all(16),
          children: [
            FadeTransition(
              opacity:
                  animationController,
              child: _hero(),
            ),

            const SizedBox(height: 18),

            _converter(),

            const SizedBox(height: 22),

            _search(),

            const SizedBox(height: 22),

            _section(
              '⭐ خوښ اسعار',
              Icons.star_rounded,
            ),

            const SizedBox(height: 10),

            _favorites(),

            const SizedBox(height: 25),

            _section(
              '🌍 د نړۍ ۴۰ اسعار',
              Icons.public_rounded,
            ),

            const SizedBox(height: 8),

            ...filtered.map(
              _currencyTile,
            ),

            const SizedBox(height: 18),

            _history(),

            const SizedBox(height: 18),

            _currencyHistory(),

            const SizedBox(height: 18),

            _developer(),

            const SizedBox(height: 35),
          ],
        ),
      ),
    );
  }

  Widget _hero() {
    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: 0.92,
        end: 1,
      ),
      duration:
          const Duration(milliseconds: 900),
      curve: Curves.easeOutBack,

      builder:
          (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },

      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(25),

        decoration:
            BoxDecoration(
          borderRadius:
              BorderRadius.circular(32),

          gradient:
              const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff087F5B),
              Color(0xff12B886),
              Color(0xff20C997),
            ],
          ),

          boxShadow: const [
            BoxShadow(
              blurRadius: 25,
              offset:
                  Offset(0, 12),
              color:
                  Colors.black26,
            ),
          ],
        ),

        child: Column(
          children: [
            const Text(
              '🇦🇫',
              style:
                  TextStyle(
                fontSize: 60,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Afghani Exchange',
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                color: Colors.white,
                fontSize: 29,
                fontWeight:
                    FontWeight.w900,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'د اسعارو چټک او هوښیار تبدیل',
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                color: Colors.white70,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 18),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),

              decoration:
                  BoxDecoration(
                color: Colors.white
                    .withOpacity(.16),
                borderRadius:
                    BorderRadius.circular(30),
              ),

              child: Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Icon(
                    Icons.circle,
                    size: 9,
                    color: loading
                        ? Colors.orange
                        : Colors
                            .lightGreenAccent,
                  ),

                  const SizedBox(width: 8),

                  Flexible(
                    child: Text(
                      loading
                          ? 'نرخ تازه کېږي...'
                          : 'نرخ هره دقیقه تازه کېږي',
                      style:
                          const TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _converter() {
    final f = getCurrency(from);
    final t = getCurrency(to);

    return Card(
      elevation: 5,

      child: Padding(
        padding:
            const EdgeInsets.all(18),

        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child:
                      _currencyButton(
                    f,
                    true,
                  ),
                ),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                  child:
                      IconButton.filled(
                    onPressed: swap,
                    icon:
                        const Icon(
                      Icons
                          .swap_horiz_rounded,
                    ),
                  ),
                ),

                Expanded(
                  child:
                      _currencyButton(
                    t,
                    false,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            TextField(
              controller:
                  amountController,
              keyboardType:
                  const TextInputType
                      .numberWithOptions(
                decimal: true,
              ),
              onChanged:
                  changeAmount,
              decoration:
                  const InputDecoration(
                labelText:
                    'د پیسو مقدار',
                prefixIcon:
                    Icon(
                  Icons
                      .calculate_outlined,
                ),
              ),
            ),

            const SizedBox(height: 17),

            AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 400,
              ),

              width: double.infinity,

              padding:
                  const EdgeInsets.all(22),

              decoration:
                  BoxDecoration(
                borderRadius:
                    BorderRadius.circular(25),

                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
              ),

              child: Column(
                children: [
                  Text(
                    '${f.flag} '
                    '${formatNumber(amount)} '
                    '$from',

                    style:
                        const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Icon(
                    Icons
                        .keyboard_double_arrow_down_rounded,
                    color:
                        Theme.of(context)
                            .colorScheme
                            .primary,
                  ),

                  const SizedBox(height: 7),

                  AnimatedSwitcher(
                    duration:
                        const Duration(
                      milliseconds: 350,
                    ),

                    child: Text(
                      '${t.flag} '
                      '${convertedResult()} '
                      '$to',

                      key: ValueKey(
                        '${convertedResult()}_$to',
                      ),

                      textAlign:
                          TextAlign.center,

                      style:
                          const TextStyle(
                        fontSize: 28,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ),

                  if (rate > 0)
                    Padding(
                      padding:
                          const EdgeInsets.only(
                        top: 10,
                      ),
                      child: Text(
                        '1 $from = '
                        '${formatNumber(rate)} $to',
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                  if (error != null)
                    Padding(
                      padding:
                          const EdgeInsets.only(
                        top: 12,
                      ),
                      child: Text(
                
