import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const AfghaniExchangeApp());
}

class Currency {
  final String code;
  final String name;
  final String flag;

  const Currency(this.code, this.name, this.flag);
}

const currencies = <Currency>[
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
  Currency('IDR', 'اندونیزیایي روپیه', '🇮🇩'),
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

class _AfghaniExchangeAppState extends State<AfghaniExchangeApp> {
  ThemeMode themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afghani Exchange',
      themeMode: themeMode,

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

      home: HomePage(
        onThemeChanged: (dark) {
          setState(() {
            themeMode =
                dark ? ThemeMode.dark : ThemeMode.light;
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
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String from = 'AFN';
  String to = 'USD';

  double rate = 0;
  double amount = 1;

  bool loading = false;
  String? error;

  DateTime? lastUpdated;

  Timer? timer;

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

    loadRate();

    // هر 60 ثانیې نوی نرخ غواړي
    timer = Timer.periodic(
      const Duration(seconds: 60),
      (_) {
        loadRate();
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    amountController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadRate() async {
    if (loading) return;

    setState(() {
      loading = true;
      error = null;
    });

    try {
      /*
       IMPORTANT:

       resolution=1m = every 60 seconds.

       API Key باید دلته په عامه APK کې ونه لیکل شي.
       وروسته به خوندي server/proxy ورسره وصل کړو.
      */

      final uri = Uri.https(
        'api.fxratesapi.com',
        '/latest',
        {
          'base': from,
          'currencies': to,
          'resolution': '1m',
          'amount': '1',
          'places': '8',
          'format': 'json',
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

      final data =
          jsonDecode(response.body);

      if (data is! Map) {
        throw Exception(
          'Invalid API response',
        );
      }

      if (data['success'] == false) {
        throw Exception(
          data['error']?.toString() ??
              'API error',
        );
      }

      final rates = data['rates'];

      if (rates is! Map) {
        throw Exception(
          'Rates not found',
        );
      }

      final value = rates[to];

      if (value == null) {
        throw Exception(
          'Rate not found',
        );
      }

      final newRate =
          (value as num).toDouble();

      if (!mounted) return;

      setState(() {
        rate = newRate;
        lastUpdated = DateTime.now();
        loading = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error =
            'نرخ ترلاسه نه شو.\n'
            'د انټرنېټ یا API اتصال وګورئ.';
      });
    }
  }

  Currency getCurrency(String code) {
    return currencies.firstWhere(
      (c) => c.code == code,
    );
  }

  void swapCurrencies() {
    setState(() {
      final old = from;
      from = to;
      to = old;
    });

    loadRate();
  }

  void updateAmount(String value) {
    final number =
        double.tryParse(
      value.replaceAll(',', ''),
    );

    if (number == null) return;

    setState(() {
      amount = number;
    });
  }

  String formattedResult() {
    final result = amount * rate;

    if (result == 0) {
      return '0';
    }

    if (result >= 1000000) {
      return result.toStringAsFixed(2);
    }

    if (result >= 1000) {
      return result.toStringAsFixed(2);
    }

    if (result >= 1) {
      return result.toStringAsFixed(4);
    }

    return result.toStringAsFixed(6);
  }

  void saveConversion() {
    if (rate <= 0) return;

    final item =
        '${amount.toStringAsFixed(2)} '
        '$from = ${formattedResult()} $to';

    setState(() {
      conversionHistory.insert(0, item);

      if (conversionHistory.length > 20) {
        conversionHistory.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = currencies.where((c) {
      final q =
          searchController.text.toLowerCase();

      return c.code
              .toLowerCase()
              .contains(q) ||
          c.name
              .toLowerCase()
              .contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,

        title: const Text(
          'Afghani Exchange',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Dark mode',
            onPressed: () {
              final isLight =
                  Theme.of(context)
                          .brightness ==
                      Brightness.light;

              widget.onThemeChanged(
                isLight,
              );
            },
            icon: Icon(
              Theme.of(context)
                      .brightness ==
                  Brightness.light
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
            ),
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: loadRate,

        child: ListView(
          padding:
              const EdgeInsets.all(16),

          children: [
            _header(),

            const SizedBox(height: 18),

            _converter(),

            const SizedBox(height: 22),

            _searchBox(),

            const SizedBox(height: 18),

            _sectionTitle(
              '⭐ خوښ اسعار',
              Icons.star_outline,
            ),

            const SizedBox(height: 10),

            _favoriteCurrencies(),

            const SizedBox(height: 24),

            _sectionTitle(
              '🌍 د نړۍ اسعار',
              Icons.public,
            ),

            const SizedBox(height: 8),

            ...filtered.map(
              _currencyTile,
            ),

            const SizedBox(height: 18),

            _conversionHistory(),

            const SizedBox(height: 18),

            _currencyHistory(),

            const SizedBox(height: 18),

            _aboutDeveloper(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding:
          const EdgeInsets.all(24),

      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(30),

        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,

          colors: [
            Theme.of(context)
                .colorScheme
                .primary,

            Theme.of(context)
                .colorScheme
                .secondary,
          ],
        ),

        boxShadow: [
          BoxShadow(
            blurRadius: 25,
            offset:
                const Offset(0, 12),
            color:
                Colors.black.withOpacity(.16),
          ),
        ],
      ),

      child: Column(
        children: [
          const Text(
            '🇦🇫',
            style:
                TextStyle(fontSize: 58),
          ),

          const SizedBox(height: 5),

          const Text(
            'Afghani Exchange',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'د اسعارو چټک او هوښیار تبدیل',
            textAlign: TextAlign.center,
            style: TextStyle(
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

            decoration: BoxDecoration(
              color:
                  Colors.white.withOpacity(.17),
              borderRadius:
                  BorderRadius.circular(50),
            ),

            child: Row(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  size: 10,
                  color: loading
                      ? Colors.orange
                      : Colors.lightGreenAccent,
                ),

                const SizedBox(width: 8),

                Text(
                  loading
                      ? 'نرخ تازه کېږي...'
                      : 'ژوندی نرخ • هره دقیقه',
                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _converter() {
    final f =
        getCurrency(from);

    final t =
        getCurrency(to);

    return Card(
      elevation: 4,

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(28),
      ),

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

                const SizedBox(width: 5),

                IconButton.filled(
                  onPressed:
                      swapCurrencies,
                  icon: const Icon(
                    Icons.swap_horiz,
                  ),
                ),

                const SizedBox(width: 5),

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
                  updateAmount,

              decoration:
                  InputDecoration(
                labelText: 'مقدار',

                prefixIcon:
                    const Icon(
                  Icons.calculate_outlined,
                ),

                filled: true,

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 18),

            Container(
              width: double.infinity,

              padding:
                  const EdgeInsets.all(20),

              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(23),

                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
              ),

              child: Column(
                children: [
                  Text(
                    '${f.flag} '
                    '${amount.toStringAsFixed(2)} '
                    '$from',

                    style:
                        const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Icon(
                    Icons
                        .arrow_downward_rounded,
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '${t.flag} '
                    '${formattedResult()} $to',

                    style:
                        const TextStyle(
                      fontSize: 28,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),

                  if (error != null) ...[
                    const SizedBox(height: 12),

                    Text(
                      error!,
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        color: Colors.red,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,

              child:
                  FilledButton.icon(
                onPressed: () {
                  loadRate();
                  saveConversion();
                },

                icon: const Icon(
                  Icons.refresh,
                ),

                label: const Text(
                  'نرخ تازه کول',
                ),
              ),
            ),

            if (lastUpdated != null)
              Padding(
                padding:
                    const EdgeInsets.only(
                  top: 10,
                ),

                child: Text(
                  'وروستی تازه کول: '
                  '${lastUpdated!.hour.toString().padLeft(2, '0')}:'
                  '${lastUpdated!.minute.toString().padLeft(2, '0')}:'
                  '${lastUpdated!.second.toString().padLeft(2, '0')}',

                  style: Theme.of(context)
                      .textTheme
                      .bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _currencyButton(
    Currency currency,
    bool isFrom,
  ) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(20),

      onTap: () {
        _showCurrencyPicker(
          isFrom,
        );
      },

      child: Container(
        padding:
            const EdgeInsets.all(12),

        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(20),

          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .outlineVariant,
          ),
        ),

        child: Column(
          children: [
            Text(
              currency.flag,
              style:
                  const TextStyle(
                fontSize: 30,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              currency.code,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.w900,
              ),
            ),

            const Icon(
              Icons
                  .keyboard_arrow_down,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBox() {
    return TextField(
      controller:
          searchController,

      onChanged: (_) {
        setState(() {});
      },

      decoration:
          InputDecoration(
        hintText:
            'د اسعارو لټون...',

        prefixIcon:
            const Icon(
          Icons.search,
        ),

        suffixIcon:
            searchController
                    .text
                    .isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      searchController
                          .clear();

                      setState(() {});
                    },
                    icon:
                        const Icon(
                      Icons.clear,
                    ),
                  ),

        filled: true,

        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(20),
          borderSide:
              BorderSide.none,
        ),
      ),
    );
  }

  Widget _sectionTitle(
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context)
              .colorScheme
              .primary,
        ),

        const SizedBox(width: 8),

        Text(
          title,
          style:
              const TextStyle(
            fontSize: 20,
            fontWeight:
                FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _favoriteCurrencies() {
    final list = currencies
        .where(
          (c) =>
              favorites.contains(c.code),
        )
        .toList();

    return SizedBox(
      height: 105,

      child: ListView.separated(
        scrollDirection:
            Axis.horizontal,

        itemCount:
            list.length,

        separatorBuilder:
            (_, __) =>
                const SizedBox(width: 10),

        itemBuilder: (_, index) {
          final c = list[index];

          return InkWell(
            borderRadius:
                BorderRadius.circular(20),

            onTap: () {
              setState(() {
                to = c.code;
              });

              loadRate();
            },

            child: Container(
              width: 100,

              padding:
                  const EdgeInsets.all(12),

              decoration:
                  BoxDecoration(
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),

                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
              ),

              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [
                  Text(
                    c.flag,
                    style:
                        const TextStyle(
                      fontSize: 28,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    c.code,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
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

  Widget _currencyTile(
    Currency c,
  ) {
    final isFavorite =
        favorites.contains(
      c.code,
    );

    return Card(
      elevation: 0,

      margin:
          const EdgeInsets.only(
        bottom: 6,
      ),

      child: ListTile(
        leading: Text(
          c.flag,
          style:
              const TextStyle(
            fontSize: 29,
          ),
        ),

        title: Text(
          c.code,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.w900,
          ),
        ),

        subtitle:
            Text(c.name),

        trailing:
            IconButton(
          onPressed: () {
            setState(() {
              if (isFavorite) {
                favorites.remove(
                  c.code,
                );
              } else {
                favorites.add(
                  c.code,
                );
              }
            });
          },

          icon: Icon(
            isFavorite
                ? Icons.star_rounded
                : Icons.star_border_rounded,

            color: isFavorite
                ? Colors.amber
                : null,
          ),
        ),

        onTap: () {
          setState(() {
            to = c.code;
          });

          loadRate();
        },
      ),
    );
  }

  Widget _conversionHistory() {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                const Icon(
                  Icons.history,
                ),

                const SizedBox(width: 8),

                const Expanded(
                  child: Text(
                    'د تبدیل تاریخچه',
                    style:
                        TextStyle(
                      fontSize: 19,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                if (conversionHistory
                    .isNotEmpty)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        conversionHistory
                            .clear();
                      });
                    },

                    icon:
                        const Icon(
                      Icons.delete_outline,
                    ),
                  ),
              ],
            ),

            const Divider(),

            if (conversionHistory.isEmpty)
              const Text(
                'تر اوسه کوم تبدیل نه دی ثبت شوی.',
              )
            else
              ...conversionHistory.map(
                (item) => ListTile(
                  dense: true,

                  leading:
                      const Icon(
                    Icons
                        .currency_exchange,
                  ),

                  title:
                      Text(item),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _currencyHistory() {
    return Card(
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(26),
      ),

      child: Padding(
        padding:
            const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            _sectionTitle(
              '📚 د اسعارو تاریخ',
              Icons.auto_stories,
            ),

            const SizedBox(height: 16),

            _historyItem(
              '۱۲۹۸ هـ ش',
              'د افغانستان د بانکنوټونو لومړنۍ دوره.',
              Icons.account_balance,
            ),

            _historyItem(
              '۱۳۸۱ هـ ش',
              'د افغانۍ د پیسو اصلاح وشوه او درې صفرونه لرې شول.',
              Icons.currency_exchange,
            ),

            _historyItem(
              'اوس',
              'افغانۍ د افغانستان رسمي پولي واحد دی.',
              Icons.flag,
            ),
          ],
        ),
      ),
    );
  }

  Widget _historyItem(
    String year,
    String text,
    IconData icon,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 16,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          CircleAvatar(
            child: Icon(icon),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  year,
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w900,
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(text),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _aboutDeveloper() {
    return Container(
      padding:
          const EdgeInsets.all(24),

      decoration:
          BoxDecoration(
        borderRadius:
            BorderRadius.circular(28),

        gradient:
            LinearGradient(
          colors: [
            Theme.of(context)
                .colorScheme
                .primaryContainer,

            Theme.of(context)
                .colorScheme
                .tertiaryContainer,
          ],
        ),
      ),

      child: Column(
        children: [
          const CircleAvatar(
            radius: 43,

            child: Icon(
              Icons.person,
              size: 48,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Afghani Exchange',
            style:
                TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'د اپ جوړونکی',
          ),

          const SizedBox(height: 5),

          const Text(
            'Abdullah ALOKOZAI',
            textAlign:
                TextAlign.center,

            style:
                TextStyle(
              fontSize: 24,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Made with Flutter 🇦🇫',
            style:
                TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showCurrencyPicker(
    bool isFrom,
  ) {
    String search = '';

    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      showDragHandle: true,

      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setModalState) {
            final list =
                currencies.where((c) {
              final q =
                  search.toLowerCase();

              return c.code
                      .toLowerCase()
                      .contains(q) ||
                  c.name
                      .toLowerCase()
                      .contains(q);
            }).toList();

            return SizedBox(
              height:
                  MediaQuery.of(context)
                          .size
                          .height *
                      .80,

              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.all(
                      16,
                    ),

                    child: TextField(
                      autofocus: true,

                      onChanged:
                          (value) {
                        setModalState(
                          () {
                            search =
                                value;
                          },
                        );
                      },

                      decoration:
                          InputDecoration(
                        hintText:
                            'د اسعارو لټون...',

                        prefixIcon:
                            const Icon(
                          Icons.search,
                        ),

                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            18,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child:
                        ListView.builder(
                      itemCount:
                          list.length,

                      itemBuilder:
                          (_, index) {
                        final c =
                            list[index];

                        return ListTile(
                          leading:
                              Text(
                            c.flag,
                            style:
                                const TextStyle(
                              fontSize: 28,
                            ),
                          ),

                          title:
                              Text(
                            c.code,
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          subtitle:
                              Text(
                            c.name,
                          ),

                          onTap: () {
                            setState(() {
                              if (isFrom) {
                                from =
                                    c.code;
                              } else {
                                to =
                                    c.code;
                              }
                            });

                            Navigator.pop(
                              context,
                            );

                            loadRate();
                          },
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
}
