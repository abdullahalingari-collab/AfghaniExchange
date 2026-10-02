import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

void main() {
  runApp(const AfghaniExchangeApp());
}

const String workerUrl =
    'https://afghani-exchange-api.abdullah-alingari.workers.dev';

enum AppLanguage {
  pashto,
  dari,
  english,
}

class CurrencyInfo {
  final String code;
  final String ps;
  final String fa;
  final String en;
  final String flag;

  const CurrencyInfo({
    required this.code,
    required this.ps,
    required this.fa,
    required this.en,
    required this.flag,
  });
}

/*
  مشهور اسعار.
  که API کې نور اسعار هم وي، اپلیکیشن یې هم ښکاره کوي.
  د هغو نوم به د ISO code په شکل ښکاره شي.
*/
const Map<String, CurrencyInfo> currencyInfo = {
  'AFN': CurrencyInfo(
    code: 'AFN',
    ps: 'افغانۍ',
    fa: 'افغانی',
    en: 'Afghan Afghani',
    flag: '🇦🇫',
  ),
  'USD': CurrencyInfo(
    code: 'USD',
    ps: 'امریکايي ډالر',
    fa: 'دالر امریکا',
    en: 'US Dollar',
    flag: '🇺🇸',
  ),
  'EUR': CurrencyInfo(
    code: 'EUR',
    ps: 'یورو',
    fa: 'یورو',
    en: 'Euro',
    flag: '🇪🇺',
  ),
  'GBP': CurrencyInfo(
    code: 'GBP',
    ps: 'برتانوي پونډ',
    fa: 'پوند بریتانیا',
    en: 'British Pound',
    flag: '🇬🇧',
  ),
  'PKR': CurrencyInfo(
    code: 'PKR',
    ps: 'پاکستانۍ روپۍ',
    fa: 'روپیه پاکستان',
    en: 'Pakistani Rupee',
    flag: '🇵🇰',
  ),
  'INR': CurrencyInfo(
    code: 'INR',
    ps: 'هندي روپۍ',
    fa: 'روپیه هند',
    en: 'Indian Rupee',
    flag: '🇮🇳',
  ),
  'AED': CurrencyInfo(
    code: 'AED',
    ps: 'اماراتي درهم',
    fa: 'درهم امارات',
    en: 'UAE Dirham',
    flag: '🇦🇪',
  ),
  'SAR': CurrencyInfo(
    code: 'SAR',
    ps: 'سعودي ریال',
    fa: 'ریال سعودی',
    en: 'Saudi Riyal',
    flag: '🇸🇦',
  ),
  'QAR': CurrencyInfo(
    code: 'QAR',
    ps: 'قطري ریال',
    fa: 'ریال قطر',
    en: 'Qatari Riyal',
    flag: '🇶🇦',
  ),
  'KWD': CurrencyInfo(
    code: 'KWD',
    ps: 'کویتي دینار',
    fa: 'دینار کویت',
    en: 'Kuwaiti Dinar',
    flag: '🇰🇼',
  ),
  'BHD': CurrencyInfo(
    code: 'BHD',
    ps: 'بحریني دینار',
    fa: 'دینار بحرین',
    en: 'Bahraini Dinar',
    flag: '🇧🇭',
  ),
  'OMR': CurrencyInfo(
    code: 'OMR',
    ps: 'عماني ریال',
    fa: 'ریال عمان',
    en: 'Omani Rial',
    flag: '🇴🇲',
  ),
  'TRY': CurrencyInfo(
    code: 'TRY',
    ps: 'ترکي لیره',
    fa: 'لیر ترکیه',
    en: 'Turkish Lira',
    flag: '🇹🇷',
  ),
  'IRR': CurrencyInfo(
    code: 'IRR',
    ps: 'ایراني ریال',
    fa: 'ریال ایران',
    en: 'Iranian Rial',
    flag: '🇮🇷',
  ),
  'CNY': CurrencyInfo(
    code: 'CNY',
    ps: 'چینایي یوان',
    fa: 'یوان چین',
    en: 'Chinese Yuan',
    flag: '🇨🇳',
  ),
  'JPY': CurrencyInfo(
    code: 'JPY',
    ps: 'جاپاني ین',
    fa: 'ین ژاپن',
    en: 'Japanese Yen',
    flag: '🇯🇵',
  ),
  'KRW': CurrencyInfo(
    code: 'KRW',
    ps: 'کوریایي وان',
    fa: 'وون کوریای جنوبی',
    en: 'South Korean Won',
    flag: '🇰🇷',
  ),
  'CAD': CurrencyInfo(
    code: 'CAD',
    ps: 'کاناډايي ډالر',
    fa: 'دالر کانادا',
    en: 'Canadian Dollar',
    flag: '🇨🇦',
  ),
  'AUD': CurrencyInfo(
    code: 'AUD',
    ps: 'اسټرالیايي ډالر',
    fa: 'دالر استرالیا',
    en: 'Australian Dollar',
    flag: '🇦🇺',
  ),
  'NZD': CurrencyInfo(
    code: 'NZD',
    ps: 'نیوزیلنډي ډالر',
    fa: 'دالر نیوزیلند',
    en: 'New Zealand Dollar',
    flag: '🇳🇿',
  ),
  'CHF': CurrencyInfo(
    code: 'CHF',
    ps: 'سویسي فرانک',
    fa: 'فرانک سوئیس',
    en: 'Swiss Franc',
    flag: '🇨🇭',
  ),
  'RUB': CurrencyInfo(
    code: 'RUB',
    ps: 'روسي روبل',
    fa: 'روبل روسیه',
    en: 'Russian Ruble',
    flag: '🇷🇺',
  ),
  'MYR': CurrencyInfo(
    code: 'MYR',
    ps: 'مالیزیايي رینګیټ',
    fa: 'رینگیت مالیزیا',
    en: 'Malaysian Ringgit',
    flag: '🇲🇾',
  ),
  'THB': CurrencyInfo(
    code: 'THB',
    ps: 'تایلنډي بات',
    fa: 'بات تایلند',
    en: 'Thai Baht',
    flag: '🇹🇭',
  ),
  'BDT': CurrencyInfo(
    code: 'BDT',
    ps: 'بنګله دېشي ټکه',
    fa: 'تاکای بنگلادیش',
    en: 'Bangladeshi Taka',
    flag: '🇧🇩',
  ),
  'NPR': CurrencyInfo(
    code: 'NPR',
    ps: 'نیپالي روپۍ',
    fa: 'روپیه نپال',
    en: 'Nepalese Rupee',
    flag: '🇳🇵',
  ),
  'LKR': CurrencyInfo(
    code: 'LKR',
    ps: 'سریلانکايي روپۍ',
    fa: 'روپیه سریلانکا',
    en: 'Sri Lankan Rupee',
    flag: '🇱🇰',
  ),
  'IDR': CurrencyInfo(
    code: 'IDR',
    ps: 'اندونیزیايي روپیه',
    fa: 'روپیه اندونیزیا',
    en: 'Indonesian Rupiah',
    flag: '🇮🇩',
  ),
  'SGD': CurrencyInfo(
    code: 'SGD',
    ps: 'سنګاپوري ډالر',
    fa: 'دالر سنگاپور',
    en: 'Singapore Dollar',
    flag: '🇸🇬',
  ),
  'HKD': CurrencyInfo(
    code: 'HKD',
    ps: 'هانګ کانګ ډالر',
    fa: 'دالر هنگ کنگ',
    en: 'Hong Kong Dollar',
    flag: '🇭🇰',
  ),
  'SEK': CurrencyInfo(
    code: 'SEK',
    ps: 'سویډني کرونا',
    fa: 'کرون سویدن',
    en: 'Swedish Krona',
    flag: '🇸🇪',
  ),
  'NOK': CurrencyInfo(
    code: 'NOK',
    ps: 'ناروېژي کرونا',
    fa: 'کرون نروژ',
    en: 'Norwegian Krone',
    flag: '🇳🇴',
  ),
  'DKK': CurrencyInfo(
    code: 'DKK',
    ps: 'ډنمارکي کرونا',
    fa: 'کرون دنمارک',
    en: 'Danish Krone',
    flag: '🇩🇰',
  ),
  'ZAR': CurrencyInfo(
    code: 'ZAR',
    ps: 'د سویلي افریقا رنډ',
    fa: 'رند آفریقای جنوبی',
    en: 'South African Rand',
    flag: '🇿🇦',
  ),
  'BRL': CurrencyInfo(
    code: 'BRL',
    ps: 'برازیلي ریال',
    fa: 'رئال برزیل',
    en: 'Brazilian Real',
    flag: '🇧🇷',
  ),
  'MXN': CurrencyInfo(
    code: 'MXN',
    ps: 'مکسیکوي پېسو',
    fa: 'پزوی مکزیک',
    en: 'Mexican Peso',
    flag: '🇲🇽',
  ),
  'EGP': CurrencyInfo(
    code: 'EGP',
    ps: 'مصري پونډ',
    fa: 'پوند مصر',
    en: 'Egyptian Pound',
    flag: '🇪🇬',
  ),
  'IQD': CurrencyInfo(
    code: 'IQD',
    ps: 'عراقي دینار',
    fa: 'دینار عراق',
    en: 'Iraqi Dinar',
    flag: '🇮🇶',
  ),
  'KZT': CurrencyInfo(
    code: 'KZT',
    ps: 'قزاقستاني ټېنګې',
    fa: 'تنگه قزاقستان',
    en: 'Kazakhstani Tenge',
    flag: '🇰🇿',
  ),
  'TJS': CurrencyInfo(
    code: 'TJS',
    ps: 'تاجکستاني سوموني',
    fa: 'سامانی تاجیکستان',
    en: 'Tajikistani Somoni',
    flag: '🇹🇯',
  ),
};

class AfghaniExchangeApp extends StatefulWidget {
  const AfghaniExchangeApp({super.key});

  @override
  State<AfghaniExchangeApp> createState() =>
      _AfghaniExchangeAppState();
}

class _AfghaniExchangeAppState extends State<AfghaniExchangeApp> {
  AppLanguage language = AppLanguage.pashto;
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afghani Exchange',
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        brightness: Brightness.dark,
      ),
      home: ExchangePage(
        language: language,
        darkMode: darkMode,
        onLanguageChanged: (v) {
          setState(() => language = v);
        },
        onDarkModeChanged: (v) {
          setState(() => darkMode = v);
        },
      ),
    );
  }
}

class ExchangePage extends StatefulWidget {
  final AppLanguage language;
  final bool darkMode;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final ValueChanged<bool> onDarkModeChanged;

  const ExchangePage({
    super.key,
    required this.language,
    required this.darkMode,
    required this.onLanguageChanged,
    required this.onDarkModeChanged,
  });

  @override
  State<ExchangePage> createState() => _ExchangePageState();
}

class _ExchangePageState extends State<ExchangePage> {
  Timer? timer;

  Map<String, double> rates = {};

  String fromCurrency = 'AFN';
  String toCurrency = 'USD';

  double amount = 1;

  bool loading = true;
  String? error;
  DateTime? lastUpdated;

  String search = '';

  Set<String> favorites = {
    'USD',
    'EUR',
    'PKR',
    'INR',
    'AED',
    'SAR',
  };

  List<String> history = [];

  final TextEditingController amountController =
      TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();

    loadRates();

    timer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => loadRates(),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    amountController.dispose();
    super.dispose();
  }

  String tr(String ps, String fa, String en) {
    switch (widget.language) {
      case AppLanguage.pashto:
        return ps;
      case AppLanguage.dari:
        return fa;
      case AppLanguage.english:
        return en;
    }
  }

  CurrencyInfo info(String code) {
    return currencyInfo[code] ??
        CurrencyInfo(
          code: code,
          ps: code,
          fa: code,
          en: code,
          flag: '🌐',
        );
  }

  String nameOf(String code) {
    final c = info(code);

    switch (widget.language) {
      case AppLanguage.pashto:
        return c.ps;
      case AppLanguage.dari:
        return c.fa;
      case AppLanguage.english:
        return c.en;
    }
  }

  Future<void> loadRates() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      error = null;
    });

    HttpClient? client;

    try {
      client = HttpClient();

      final uri = Uri.parse(
        '$workerUrl?base=AFN&t=${DateTime.now().millisecondsSinceEpoch}',
      );

      final request = await client
          .getUrl(uri)
          .timeout(const Duration(seconds: 20));

      final response = await request.close().timeout(
            const Duration(seconds: 20),
          );

      final body = await response
          .transform(utf8.decoder)
          .join();

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          'HTTP ${response.statusCode}',
        );
      }

      final data = jsonDecode(body);

      final dynamic raw = data['rates'] ?? data['results'];

      if (raw == null || raw is! Map) {
        throw Exception('No rates');
      }

      final Map<String, double> newRates = {
        'AFN': 1.0,
      };

      for (final item in raw.entries) {
        final code = item.key.toString().toUpperCase();

        final value = item.value;

        double? number;

        if (value is num) {
          number = value.toDouble();
        } else {
          number = double.tryParse(
            value.toString(),
          );
        }

        if (number != null &&
            number.isFinite &&
            number > 0) {
          newRates[code] = number;
        }
      }

      if (newRates.length < 2) {
        throw Exception('Too few currencies');
      }

      if (!mounted) return;

      setState(() {
        rates = newRates;
        lastUpdated = DateTime.now();
        loading = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = tr(
          'نرخونه نه شي راوړل کېدای',
          'نرخ‌ها دریافت نشدند',
          'Unable to load rates',
        );
      });
    } finally {
      client?.close(force: true);
    }
  }

  double rateOf(String code) {
    if (code == 'AFN') return 1;

    return rates[code] ?? 0;
  }

  double convertedValue() {
    if (fromCurrency == toCurrency) {
      return amount;
    }

    final fromRate = rateOf(fromCurrency);
    final toRate = rateOf(toCurrency);

    if (fromRate <= 0 || toRate <= 0) {
      return 0;
    }

    return (amount / fromRate) * toRate;
  }

  String number(double value) {
    if (!value.isFinite) return '0';

    if (value == 0) return '0';

    if (value.abs() >= 1000) {
      return value.toStringAsFixed(2);
    }

    if (value.abs() >= 1) {
      return value.toStringAsFixed(4);
    }

    return value.toStringAsFixed(8);
  }

  void swap() {
    setState(() {
      final temp = fromCurrency;

      fromCurrency = toCurrency;
      toCurrency = temp;
    });
  }

  void saveHistory() {
    final result = convertedValue();

    final text =
        '${number(amount)} $fromCurrency  →  '
        '${number(result)} $toCurrency';

    setState(() {
      history.insert(0, text);

      if (history.length > 15) {
        history.removeLast();
      }
    });
  }

  List<String> get allCurrencies {
    final list = rates.keys.toList();

    list.sort();

    return list;
  }

  List<String> get filteredCurrencies {
    final q = search.trim().toLowerCase();

    if (q.isEmpty) {
      return allCurrencies;
    }

    return allCurrencies.where((code) {
      return code.toLowerCase().contains(q) ||
          nameOf(code).toLowerCase().contains(q);
    }).toList();
  }

  Future<void> chooseCurrency({
    required bool from,
  }) async {
    String localSearch = '';

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final q = localSearch.toLowerCase();

            final list = allCurrencies.where((code) {
              return q.isEmpty ||
                  code.toLowerCase().contains(q) ||
                  nameOf(code).toLowerCase().contains(q);
            }).toList();

            return SafeArea(
              child: SizedBox(
                height:
                    MediaQuery.of(context).size.height * .85,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.search),
                          hintText: tr(
                            'اسعار ولټوه',
                            'جستجوی ارز',
                            'Search currency',
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(18),
                          ),
                        ),
                        onChanged: (v) {
                          setModalState(() {
                            localSearch = v;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final code = list[index];
                          final c = info(code);

                          return ListTile(
                            leading: Text(
                              c.flag,
                              style:
                                  const TextStyle(fontSize: 28),
                            ),
                            title: Text(
                              '$code  •  ${nameOf(code)}',
                            ),
                            subtitle: code == 'AFN'
                                ? const Text('1 AFN = 1 AFN')
                                : Text(
                                    '1 AFN = '
                                    '${number(rateOf(code))} $code',
                                  ),
                            trailing: IconButton(
                              icon: Icon(
                                favorites.contains(code)
                                    ? Icons.star
                                    : Icons.star_border,
                                color:
                                    favorites.contains(code)
                                        ? Colors.amber
                                        : null,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (favorites
                                      .contains(code)) {
                                    favorites.remove(code);
                                  } else {
                                    favorites.add(code);
                                  }
                                });

                                setModalState(() {});
                              },
                            ),
                            onTap: () {
                              Navigator.pop(
                                context,
                                code,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null && mounted) {
      setState(() {
        if (from) {
          fromCurrency = result;
        } else {
          toCurrency = result;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Afghani Exchange',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          PopupMenuButton<AppLanguage>(
            icon: const Icon(Icons.language),
            onSelected: widget.onLanguageChanged,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: AppLanguage.pashto,
                child: Text('🇦🇫 پښتو'),
              ),
              PopupMenuItem(
                value: AppLanguage.dari,
                child: Text('🇦🇫 دری'),
              ),
              PopupMenuItem(
                value: AppLanguage.english,
                child: Text('🇬🇧 English'),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              widget.onDarkModeChanged(
                !widget.darkMode,
              );
            },
            icon: Icon(
              widget.darkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadRates,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _header(),

            const SizedBox(height: 16),

            _status(),

            const SizedBox(height: 18),

            Text(
              tr(
                'د اسعارو تبدیل',
                'تبدیل ارز',
                'Currency Converter',
              ),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            _converter(),

            const SizedBox(height: 22),

            Text(
              tr(
                '⭐ خوښ اسعار',
                '⭐ ارزهای مورد علاقه',
                '⭐ Favorite Currencies',
              ),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            _favorites(),

            const SizedBox(height: 22),

            Text(
              tr(
                '🌍 ټول موجود اسعار',
                '🌍 تمام ارزهای موجود',
                '🌍 All Available Currencies',
              ),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: tr(
                  'د اسعارو نوم یا کوډ ولټوه',
                  'نام یا کد ارز را جستجو کنید',
                  'Search currency name or code',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onChanged: (v) {
                setState(() {
                  search = v;
                });
              },
            ),

            const SizedBox(height: 12),

            if (loading && rates.isEmpty)
              const Padding(
                padding: EdgeInsets.all(30),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),

            if (error != null && rates.isEmpty)
              _errorCard(),

            ...filteredCurrencies.map(
              (code) => _currencyTile(code),
            ),

            if (history.isNotEmpty) ...[
              const SizedBox(height: 25),

              Text(
                tr(
                  '📜 د تبدیلولو تاریخچه',
                  '📜 تاریخچه تبدیل',
                  '📜 Conversion History',
                ),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Card(
                child: Column(
                  children: history.map(
                    (item) {
                      return ListTile(
                        leading:
                            const Icon(Icons.history),
                        title: Text(item),
                      );
                    },
                  ).toList(),
                ),
              ),
            ],

            const SizedBox(height: 25),

            _developerCard(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF075E1D),
            Color(0xFF16A63A),
            Color(0xFF41C96A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 20,
            offset: Offset(0, 8),
            color: Colors.black26,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.currency_exchange,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            tr(
              'افغاني تبادله',
              'تبدیل افغانی',
              'Afghani Exchange',
            ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 29,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            tr(
              'د نړۍ د اسعارو تازه نرخونه',
              'نرخ‌های تازه ارزهای جهان',
              'Live world currency rates',
            ),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _status() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            if (loading)
              const SizedBox(
                width: 23,
                height: 23,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                ),
              )
            else
              Icon(
                error == null
                    ? Icons.check_circle
                    : Icons.error,
                color: error == null
                    ? Colors.green
                    : Colors.red,
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    error ??
                        tr(
                          'نرخونه تازه دي',
                          'نرخ‌ها تازه هستند',
                          'Rates are up to date',
                        ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastUpdated == null
                        ? tr(
                            'د تازه کېدو په تمه...',
                            'در انتظار به‌روزرسانی...',
                            'Waiting for update...',
                          )
                        : '${tr(
                            'وروستی تازه کول',
                            'آخرین به‌روزرسانی',
                            'Last Updated',
                          )}: ${timeText()}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed:
                  loading ? null : loadRates,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }

  String timeText() {
    if (lastUpdated == null) return '';

    final d = lastUpdated!;

    return '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}:'
        '${d.second.toString().padLeft(2, '0')}';
  }

  Widget _converter() {
    final result = convertedValue();

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _currencySelector(
              title: tr(
                'له',
                'از',
                'From',
              ),
              code: fromCurrency,
              onTap: () {
                chooseCurrency(from: true);
              },
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: Theme.of(context)
                        .colorScheme
                        .outline,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                  ),
                  child: IconButton(
                    onPressed: swap,
                    color: Colors.white,
                    icon: const Icon(
                      Icons.swap_vert,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: Theme.of(context)
                        .colorScheme
                        .outline,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            TextField(
              controller: amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: tr(
                  'مقدار',
                  'مقدار',
                  'Amount',
                ),
                prefixIcon:
                    const Icon(Icons.calculate),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(18),
                ),
              ),
              onChanged: (v) {
                setState(() {
                  amount =
                      double.tryParse(v) ?? 0;
                });
              },
            ),

            const SizedBox(height: 14),

            _currencySelector(
              title: tr(
                'ته',
                'به',
                'To',
              ),
              code: toCurrency,
              onTap: () {
                chooseCurrency(from: false);
              },
            ),

            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(22),
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer,
              ),
              child: Column(
                children: [
                  Text(
                    tr(
                      'نتیجه',
                      'نتیجه',
                      'Result',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${number(result)} $toCurrency',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: saveHistory,
                icon:
                    const Icon(Icons.save_alt),
                label: Text(
                  tr(
                    'تبدیل ثبت کړه',
                    'ثبت تبدیل',
                    'Save Conversion',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _currencySelector({
    required String title,
    required String code,
    required VoidCallback onTap,
  }) {
    final c = info(code);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .outline,
          ),
          borderRadius:
              BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Text(
              c.flag,
              style:
                  const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$code • ${nameOf(code)}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
            ),
          ],
        ),
      ),
    );
  }

  Widget _favorites() {
    final list = allCurrencies
        .where(
          (code) => favorites.contains(code),
        )
        .take(10)
        .toList();

    if (list.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            tr(
              'تر اوسه خوښ اسعار نشته.',
              'هنوز ارز مورد علاقه‌ای نیست.',
              'No favorite currencies yet.',
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final code = list[index];
          final c = info(code);

          return InkWell(
            onTap: () {
              setState(() {
                toCurrency = code;
              });
            },
            borderRadius:
                BorderRadius.circular(20),
            child: Container(
              width: 155,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(20),
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        c.flag,
                        style: const TextStyle(
                          fontSize: 25,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        code,
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    '${number(rateOf(code))}',
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const Text(
                    '1 AFN',
                    style: TextStyle(
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _currencyTile(String code) {
    final c = info(code);
    final favorite = favorites.contains(code);

    return Card(
      margin:
          const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(
          c.flag,
          style:
              const TextStyle(fontSize: 28),
        ),
        title: Text(
          '$code  •  ${nameOf(code)}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          code == 'AFN'
              ? '1 AFN = 1 AFN'
              : '1 AFN = '
                  '${number(rateOf(code))} $code',
        ),
        trailing: IconButton(
          onPressed: () {
            setState(() {
              if (favorite) {
                favorites.remove(code);
              } else {
                favorites.add(code);
              }
            });
          },
          icon: Icon(
            favorite
                ? Icons.star
                : Icons.star_border,
            color: favorite
                ? Colors.amber
                : null,
          ),
        ),
        onTap: () {
          setState(() {
            toCurrency = code;
          });
        },
      ),
    );
  }

  Widget _errorCard() {
    return Card(
      color: Theme.of(context)
          .colorScheme
          .errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(
              Icons.wifi_off,
              color: Theme.of(context)
                  .colorScheme
                  .onErrorContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                tr(
                  'انټرنېټ یا د نرخونو سرور ستونزه لري. بیا هڅه وکړه.',
                  'اینترنت یا سرور نرخ‌ها مشکل دارد. دوباره تلاش کنید.',
                  'Internet or rate server problem. Please try again.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _developerCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(25),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF111827),
            Color(0xFF263449),
          ],
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.code,
            color: Colors.white,
            size: 35,
          ),
          const SizedBox(height: 8),
          const Text(
            'Abdullah Eman',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            tr(
              'جوړونکی',
              'سازنده',
              'Developer',
            ),
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Afghani Exchange 🇦🇫',
            style: TextStyle(
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}
