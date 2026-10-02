import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const AfghaniExchangeApp());
}

// ============================================================
// APP CONFIG
// ============================================================

// دلته وروسته خپل خوندي Backend URL واچوه.
// مثال:
// https://your-domain.com/api/latest
//
// API Key دلته مه لیکئ.
const String backendUrl = '';

const Duration refreshInterval = Duration(minutes: 1);

// ============================================================
// CURRENCIES
// ============================================================

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

// ============================================================
// APP
// ============================================================

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
        colorSchemeSeed: Colors.green,
        scaffoldBackgroundColor:
            const Color(0xffF5F8F6),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        inputDecorationTheme:
            InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.all(
              Radius.circular(18),
            ),
            borderSide: BorderSide.none,
          ),
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.green,
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

// ============================================================
// HOME
// ============================================================

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

class _HomePageState
    extends State<HomePage> {
  String from = 'AFN';
  String to = 'USD';

  double amount = 1;
  double rate = 0;

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

    timer = Timer.periodic(
      refreshInterval,
      (_) => loadRate(),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    amountController.dispose();
    searchController.dispose();
    super.dispose();
  }

  // ==========================================================
  // RATE
  // ==========================================================

  Future<void> loadRate() async {
    if (loading) return;

    setState(() {
      loading = true;
      error = null;
    });

    try {
      if (from == to) {
        if (!mounted) return;

        setState(() {
          rate = 1;
          lastUpdated = DateTime.now();
          loading = false;
        });

        return;
      }

      if (backendUrl.trim().isEmpty) {
        throw Exception(
          'Backend URL is not configured',
        );
      }

      final uri = Uri.parse(
        backendUrl,
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

      final data =
          jsonDecode(response.body);

      if (data is! Map) {
        throw Exception(
          'Invalid response',
        );
      }

      dynamic rates =
          data['rates'] ??
          data['results'];

      if (rates is! Map) {
        throw Exception(
          'Rates not found',
        );
      }

      final value =
          rates[to];

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
        lastUpdated = DateTime.now();
        loading = false;
        error = null;
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

  // ==========================================================
  // HELPERS
  // ==========================================================

  Currency getCurrency(
    String code,
  ) {
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

  void updateAmount(
    String value,
  ) {
    final number =
        double.tryParse(
      value.replaceAll(',', ''),
    );

    if (number == null) return;

    setState(() {
      amount = number;
    });
  }

  String formatNumber(
    double value,
  ) {
    if (value == 0) return '0';

    if (value >= 1000000) {
      return value.toStringAsFixed(2);
    }

    if (value >= 1000) {
      return value.toStringAsFixed(2);
    }

    if (value >= 1) {
      return value.toStringAsFixed(4);
    }

    return value.toStringAsFixed(6);
  }

  String resultText() {
    return formatNumber(
      amount * rate,
    );
  }

  void saveConversion() {
    if (rate <= 0) return;

    final item =
        '${formatNumber(amount)} $from'
        '  =  '
        '${resultText()} $to';

    setState(() {
      conversionHistory.insert(
        0,
        item,
      );

      if (conversionHistory.length > 20) {
        conversionHistory.removeLast();
      }
    });
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final filtered =
        currencies.where((c) {
      final q =
          searchController.text
              .toLowerCase()
              .trim();

      return c.code
              .toLowerCase()
              .contains(q) ||
          c.name
              .toLowerCase()
              .contains(q);
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
                  ? Icons.light_mode
                  : Icons.dark_mode,
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
              const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            40,
          ),

          children: [
            _hero(),

            const SizedBox(height: 18),

            _converterCard(),

            const SizedBox(height: 22),

            _search(),

            const SizedBox(height: 20),

            _title(
              '⭐ خوښ اسعار',
              Icons.star,
            ),

            const SizedBox(height: 10),

            _favorites(),

            const SizedBox(height: 24),

            _title(
              '🌍 ټول اسعار',
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

            _developer(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // HERO
  // ==========================================================

  Widget _hero() {
    return Container(
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

        boxShadow: [
          BoxShadow(
            blurRadius: 25,
            offset:
                const Offset(0, 12),
            color:
                Colors.black26,
          ),
        ],
      ),

      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration:
                BoxDecoration(
              color:
                  Colors.white24,
              shape:
                  BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '🇦🇫',
                style:
                    TextStyle(
                  fontSize: 43,
                ),
              ),
            ),
          ),

          const SizedBox(height: 13),

          const Text(
            'Afghani Exchange',
            style:
                TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(height: 7),

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
              horizontal: 15,
              vertical: 10,
            ),

            decoration:
                BoxDecoration(
              color:
                  Colors.white.withOpacity(.16),
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
                      ? Colors.orangeAccent
                      : Colors.lightGreenAccent,
                ),

                const SizedBox(width: 8),

                Text(
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // CONVERTER
  // ==========================================================

  Widget _converterCard() {
    final f =
        getCurrency(from);

    final t =
        getCurrency(to);

    return Card(
      elevation: 3,

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(30),
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
                      _currencySelector(
                    f,
                    true,
                  ),
                ),

                Padding(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 5,
                  ),

                  child:
                      IconButton.filled(
                    onPressed:
                        swapCurrencies,
                    icon:
                        const Icon(
                      Icons
                          .swap_horiz_rounded,
                    ),
                  ),
                ),

                Expanded(
                  child:
                      _currencySelector(
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

            const SizedBox(height: 16),

            Container(
              width: double.infinity,

              padding:
                  const EdgeInsets.all(
                22,
              ),

              decoration:
                  BoxDecoration(
                borderRadius:
                    BorderRadius.circular(
                  25,
                ),

                gradient:
                    LinearGradient(
                  colors: [
                    Theme.of(context)
                        .colorScheme
                        .primaryContainer,
                    Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                  ],
                ),
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

                  Text(
                    '${t.flag} '
                    '${resultText()} '
                    '$to',

                    textAlign:
                        TextAlign.center,

                    style:
                        const TextStyle(
                      fontSize: 28,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),

                  if (rate > 0)
                    Padding(
                      padding:
                          const EdgeInsets
                              .only(
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
                          const EdgeInsets
                              .only(
                        top: 12,
                      ),
                      child: Text(
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
                    ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child:
                      FilledButton.icon(
                    onPressed:
                        loading
                            ? null
                            : loadRate,

                    icon: loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons
                                .refresh_rounded,
                          ),

                    label:
                        const Text(
                      'نرخ تازه کول',
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                IconButton.filledTonal(
                  onPressed:
                      saveConversion,
                  icon: const Icon(
                    Icons
                        .bookmark_add_outlined,
                  ),
                  tooltip:
                      'تبدیل ثبت کړه',
                ),
              ],
            ),

            if (lastUpdated != null)
              Padding(
                padding:
                    const EdgeInsets.only(
                  top: 10,
                ),
                child: Text(
                  'وروستی تازه کول: '
                  '${_time(lastUpdated!)}',
                  style:
                      Theme.of(context)
                          .textTheme
                          .bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _time(
    DateTime time,
  ) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
  }

  Widget _currencySelector(
    Currency currency,
    bool isFrom,
  ) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(22),

      onTap: () =>
          _showCurrencyPicker(
        isFrom,
      ),

      child: Container(
        padding:
            const EdgeInsets.all(13),

        decoration:
            BoxDecoration(
          borderRadius:
              BorderRadius.circular(22),

          border: Border.all(
            color:
                Theme.of(context)
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
                fontSize: 31,
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
                  .keyboard_arrow_down_rounded,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // SEARCH
  // ==========================================================

  Widget _search() {
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
          Icons.search_rounded,
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
      ),
    );
  }

  // ==========================================================
  // SECTION TITLE
  // ==========================================================

  Widget _title(
    String text,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color:
              Theme.of(context)
                  .colorScheme
                  .primary,
        ),

        const SizedBox(width: 8),

        Text(
          text,
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

  // ==========================================================
  // FAVORITES
  // ==========================================================

  Widget _favorites() {
    final list =
        currencies.where(
      (c) =>
          favorites.contains(
        c.code,
      ),
    ).toList();

    return SizedBox(
      height: 112,

      child: ListView.separated(
        scrollDirection:
            Axis.horizontal,

        itemCount:
            list.length,

        separatorBuilder:
            (_, __) =>
                const SizedBox(
          width: 10,
        ),

        itemBuilder: (_, index) {
          final c =
              list[index];

          return InkWell(
            borderRadius:
                BorderRadius.circular(
              22,
            ),

            onTap: () {
              setState(() {
                to = c.code;
              });

              loadRate();
            },

            child: Container(
              width: 105,

              padding:
                  const EdgeInsets.all(
                12,
              ),

              decoration:
                  BoxDecoration(
                color:
                    Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                borderRadius:
                    BorderRadius.circular(
                  22,
                ),
              ),

              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,

                children: [
                  Text(
                    c.flag,
                    style:
                        const TextStyle(
                      fontSize: 29,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    c.code,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.w900,
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

  // ==========================================================
  // CURRENCY TILE
  // ==========================================================

  Widget _currencyTile(
    Currency c,
  ) {
    final favorite =
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
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 2,
        ),

        leading: Text(
          c.flag,
          style:
              const TextStyle(
            fontSize: 30,
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
              if (favorite) {
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
            favorite
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            color: favorite
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

  // ==========================================================
  // CONVERSION HISTORY
  // ==========================================================

  Widget _conversionHistory() {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(
          18,
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                const Icon(
                  Icons.history_rounded,
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
                      Icons
                          .delete_outline,
                    ),
                  ),
              ],
            ),

            const Divider(),

            if (conversionHistory
                .isEmpty)
              const Padding(
                padding:
                    EdgeInsets.all(8),
                child: Text(
                  'تر اوسه کوم تبدیل نه دی ثبت شوی.',
                ),
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

  // ==========================================================
  // CURRENCY HISTORY
  // ==========================================================

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
            _title(
              '📚 د اسعارو تاریخ',
              Icons.auto_stories,
            ),

            const SizedBox(height: 18),

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
                  style:
                      TextStyle(
                    fontWeight:
                        FontWeight.w900,
                    color:
                        Theme.of(context)
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

  // ==========================================================
  // DEVELOPER
  // ==========================================================

  Widget _developer() {
    return Container(
      padding:
          const EdgeInsets.all(25),

      decoration:
          BoxDecoration(
        borderRadius:
            BorderRadius.circular(30),

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
              Icons.person_rounded,
              size: 48,
            ),
          ),

          const SizedBox(height: 13),

          const Text(
            'Afghani Exchange',
            style:
                TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(height: 5),

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

          const SizedBox(height: 12),

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

  // ==========================================================
  // CURRENCY PICKER
  // ==========================================================

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
                currencies.where(
              (c) {
                final q =
                    search
                        .toLowerCase()
                        .trim();

                return c.code
                        .toLowerCase()
                        .contains(q) ||
                    c.name
                        .toLowerCase()
                        .contains(q);
              },
            ).toList();

            return SizedBox(
              height:
                  MediaQuery.of(context)
                          .size
                          .height *
                      .82,

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
                          const InputDecoration(
                        hintText:
                            'د اسعارو لټون...',
                        prefixIcon:
                            Icon(
                          Icons.search,
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
                              fontSize: 29,
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
