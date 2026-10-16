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
  Currency('EUR', 'یورو', '🇪🇺'),
  Currency('AED', 'اماراتي درهم', '🇦🇪'),
  Currency('SAR', 'سعودي ریال', '🇸🇦'),
  Currency('TRY', 'ترکي لیره', '🇹🇷'),
  Currency('CNY', 'چینایي یوان', '🇨🇳'),
  Currency('GBP', 'برتانوي پونډ', '🇬🇧'),
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

class _AfghaniExchangeAppState
    extends State<AfghaniExchangeApp> {
  ThemeMode themeMode = ThemeMode.light;
  String language = 'پښتو';

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
        language: language,
        onLanguageChanged: (value) {
          setState(() => language = value);
        },
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
  final String language;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<bool> onThemeChanged;

  const HomePage({
    super.key,
    required this.language,
    required this.onLanguageChanged,
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

  Timer? refreshTimer;

  final amountController =
      TextEditingController(text: '1');

  final searchController = TextEditingController();

  final Set<String> favorites = {
    'USD',
    'PKR',
    'INR',
    'AED',
    'SAR',
  };

  final List<String> history = [];

  @override
  void initState() {
    super.initState();

    loadRate();

    // هر 60 ثانیې نوی نرخ غواړي
    refreshTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => loadRate(),
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
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
       * مهم:
       * API Key په عامه Flutter APK کې مه اچوه.
       * وروسته به خوندي server/proxy ورسره وصل کړو.
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
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception(
          'HTTP ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body);

      if (data is! Map) {
        throw Exception('Invalid response');
      }

      if (data['success'] == false) {
        throw Exception(
          data['error']?.toString() ??
              'API error',
        );
      }

      final rates = data['rates'];

      if (rates is! Map) {
        throw Exception('Rates not found');
      }

      final value = rates[to];

      if (value == null) {
        throw Exception(
          'Rate for $to not found',
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
            'اوس نرخ ترلاسه نه شو.\n'
            'د API اتصال باید خوندي شي.';
      });
    }
  }

  Currency currency(String code) {
    return currencies.firstWhere(
      (c) => c.code == code,
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
    final number =
        double.tryParse(
          value.replaceAll(',', ''),
        );

    if (number != null) {
      setState(() {
        amount = number;
      });
    }
  }

  String result() {
    final value = amount * rate;

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

  void saveHistory() {
    if (rate <= 0) return;

    final text =
        '${amount.toStringAsFixed(2)} '
        '$from = ${result()} $to';

    setState(() {
      history.insert(0, text);

      if (history.length > 20) {
        history.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = currencies.where((c) {
      final search =
          searchController.text.toLowerCase();

      return c.code
              .toLowerCase()
              .contains(search) ||
          c.name
              .toLowerCase()
              .contains(search);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Afghani Exchange',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              final dark =
                  Theme.of(context).brightness ==
                      Brightness.light;

              widget.onThemeChanged(dark);
            },
            icon: Icon(
              Theme.of(context).brightness ==
                      Brightness.light
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
            ),
          ),
          PopupMenuButton<String>(
            onSelected:
                widget.onLanguageChanged,
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'پښتو',
                child: Text('🇦🇫 پښتو'),
              ),
              PopupMenuItem(
                value: 'دری',
                child: Text('🇦🇫 دری'),
              ),
              PopupMenuItem(
                value: 'English',
                child: Text('🇬🇧 English'),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadRate,
        child: ListView(
          padding:
              const EdgeInsets.all(16),
          children: [
            _hero(),
            const SizedBox(height: 18),
            _converter(),
            const SizedBox(height: 22),
            _search(),
            const SizedBox(height: 16),
            _title(
              '⭐ خوښ اسعار',
              Icons.star_outline,
            ),
            const SizedBox(height: 10),
            _favorites(),
            const SizedBox(height: 22),
            _title(
              '🌍 د نړۍ اسعار',
              Icons.public,
            ),
            const SizedBox(height: 8),
            ...filtered.map(_currencyTile),
            const SizedBox(height: 18),
            _conversionHistory(),
            const SizedBox(height: 18),
            _currencyHistory(),
            const SizedBox(height: 18),
            _about(),
          ],
        ),
      ),
    );
  }

  Widget _hero() {
    return Container(
      padding: const EdgeInsets.all(24),
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
            blurRadius: 24,
            offset: const Offset(0, 12),
            color:
                Colors.black.withOpacity(.15),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '🇦🇫',
            style:
                TextStyle(fontSize: 55),
          ),
          const SizedBox(height: 6),
          const Text(
            'Afghani Exchange',
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'د اسعارو چټک او هوښیار تبدیل',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color:
                  Colors.white.withOpacity(.16),
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
                const SizedBox(width: 7),
                Text(
                  loading
                      ? 'نرخ تازه کېږي...'
                      : 'هره دقیقه تازه کول',
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
    final f = currency(from);
    final t = currency(to);

    return Card(
      elevation: 3,
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
                      _currencySelector(
                    f,
                    true,
                  ),
                ),
                const SizedBox(width: 6),
                IconButton.filled(
                  onPressed: swap,
                  icon: const Icon(
                    Icons.swap_horiz,
                  ),
                ),
                const SizedBox(width: 6),
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
                  changeAmount,
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
              decoration:
                  BoxDecoration(
                borderRadius:
                    BorderRadius.circular(
                  22,
                ),
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
                  const SizedBox(height: 9),
                  Icon(
                    Icons
                        .arrow_downward_rounded,
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                  ),
                  const SizedBox(height: 9),
                  Text(
                    '${t.flag} '
                    '${result()} $to',
                    style:
                        const TextStyle(
                      fontSize: 28,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(
                        height: 12),
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
                  saveHistory();
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
                  top: 9,
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

  Widget _currencySelector(
    Currency c,
    bool isFrom,
  ) {
    return InkWell(
      onTap: () =>
          _showPicker(isFrom),
      borderRadius:
          BorderRadius.circular(18),
      child: Container(
        padding:
            const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .outlineVariant,
          ),
        ),
        child: Column(
          children: [
            Text(
              c.flag,
              style:
                  const TextStyle(
                fontSize: 30,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              c.code,
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

  Widget _search() {
    return TextField(
      controller:
          searchController,
      onChanged: (_) =>
          setState(() {}),
      decoration:
          InputDecoration(
        hintText:
            'د اسعارو لټون...',
        prefixIcon:
            const Icon(Icons.search),
        suffixIcon:
            searchController.text.isEmpty
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

  Widget _favorites() {
    final list = currencies
        .where((c) =>
            favorites.contains(
              c.code,
            ))
        .toList();

    return SizedBox(
      height: 102,
      child: ListView.separated(
        scrollDirection:
            Axis.horizontal,
        itemCount: list.length,
        separatorBuilder:
            (_, __) =>
                const SizedBox(
          width: 10,
        ),
        itemBuilder: (_, i) {
          final c = list[i];

          return InkWell(
            onTap: () {
              setState(() {
                to = c.code;
              });
              loadRate();
            },
            borderRadius:
                BorderRadius.circular(20),
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

  Widget _title(
    String text,
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

  Widget _currencyTile(
    Currency c,
  ) {
    final fav =
        favorites.contains(c.code);

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
              if (fav) {
                favorites
                    .remove(c.code);
              } else {
                favorites
                    .add(c.code);
              }
            });
          },
          icon: Icon(
            fav
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            color:
                fav ? Colors.amber : null,
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
                if (history.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        history.clear();
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
            if (history.isEmpty)
              const Text(
                'تر اوسه کوم تبدیل نه دی ثبت شوی.',
              )
            else
              ...history.map(
                (x) => ListTile(
                  dense: true,
                  leading:
                      const Icon(
                    Icons
                        .currency_exchange,
                  ),
                  title:
                      Text(x),
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
            BorderRadius.circular(
          26,
        ),
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
            const SizedBox(height: 16),
            _historyRow(
              '۱۲۹۸ هـ ش',
              'د افغانستان د بانکنوټونو لومړنۍ دوره.',
              Icons.account_balance,
            ),
            _historyRow(
              '۱۳۸۱ هـ ش',
              'د افغانۍ د پیسو اصلاح وشوه او درې صفرونه لرې شول.',
              Icons.currency_exchange,
            ),
            _historyRow(
              'اوس',
              'افغانۍ د افغانستان رسمي پولي واحد دی.',
              Icons.flag,
            ),
          ],
        ),
      ),
    );
  }

  Widget _historyRow(
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
                    color: Theme.of(
                      context,
                    )
                        .colorScheme
                        .primary,
                  ),
                ),
                const SizedBox(
                    height: 4),
                Text(text),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _about() {
    return Container(
      padding:
          const EdgeInsets.all(24),
      decoration:
          BoxDecoration(
        borderRadius:
            BorderRadius.circular(
          28,
        ),
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
            radius: 42,
            child: Icon(
              Icons.person,
              size: 46,
            ),
          ),
          const SizedBox(
              height: 12),
          const Text(
            'Afghani Exchange',
            style:
                TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
          const SizedBox(
              height: 6),
          const Text(
            'د اپ جوړونکی',
          ),
          const SizedBox(
              height: 5),
          const Text(
            'Abdullah ALOKOZAI',
            style:
                TextStyle(
              fontSize: 24,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
          const SizedBox(
              height: 10),
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

  void _showPicker(bool isFrom) {
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
              return c.code
                      .toLowerCase()
                      .contains(
                        search
                            .toLowerCase(),
                      ) ||
                  c.name
                      .toLowerCase()
                      .contains(
                        search
                            .toLowerCase(),
                      );
            }).toList();

            return SizedBox(
              height:
                  MediaQuery.of(context)
                          .size
                          .height *
                      .78,
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.all(
                      16,
                    ),
                    child:
                        TextField(
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
                          (_, i) {
                        final c =
                            list[i];

                        return ListTile(
                          leading:
                              Text(
                            c.flag,
                            style:
                                const TextStyle(
                              fontSize:
                                  28,
                            ),
                          ),
                          title:
                              Text(
                            c.code,
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                          subtitle:
                              Text(
                            c.name,
                          ),
                          onTap: () {
                            setState(
                              () {
                                if (isFrom) {
                                  from =
                                      c.code;
                                } else {
                                  to =
                                      c.code;
                                }
                              },
                            );

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
