import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

const String rateServerUrl =
    'https://afghani-exchange-api.abdullah-alingari.workers.dev';

void main() {
  runApp(const AfghaniExchangeApp());
}

class Currency {
  final String code;
  final String name;
  final String flag;

  const Currency(this.code, this.name, this.flag);
}

const List<Currency> currencies = [
  Currency('AFN', 'افغانۍ', '🇦🇫'),
  Currency('USD', 'امریکایي ډالر', '🇺🇸'),
  Currency('EUR', 'یورو', '🇪🇺'),
  Currency('GBP', 'برتانوي پونډ', '🇬🇧'),
  Currency('PKR', 'پاکستانۍ روپۍ', '🇵🇰'),
  Currency('INR', 'هندي روپۍ', '🇮🇳'),
  Currency('AED', 'اماراتي درهم', '🇦🇪'),
  Currency('SAR', 'سعودي ریال', '🇸🇦'),
  Currency('QAR', 'قطري ریال', '🇶🇦'),
  Currency('KWD', 'کویتي دینار', '🇰🇼'),
  Currency('BHD', 'بحریني دینار', '🇧🇭'),
  Currency('OMR', 'عماني ریال', '🇴🇲'),
  Currency('TRY', 'ترکي لیره', '🇹🇷'),
  Currency('CNY', 'چینایي یوان', '🇨🇳'),
  Currency('JPY', 'جاپاني ین', '🇯🇵'),
  Currency('KRW', 'کوریایي وون', '🇰🇷'),
  Currency('RUB', 'روسي روبل', '🇷🇺'),
  Currency('CAD', 'کاناډایي ډالر', '🇨🇦'),
  Currency('AUD', 'اسټرالیايي ډالر', '🇦🇺'),
  Currency('NZD', 'نیوزیلنډي ډالر', '🇳🇿'),
  Currency('CHF', 'سویسي فرانک', '🇨🇭'),
  Currency('SEK', 'سویډني کرونا', '🇸🇪'),
  Currency('NOK', 'ناروېژي کرونا', '🇳🇴'),
  Currency('DKK', 'ډنمارکي کرونا', '🇩🇰'),
  Currency('SGD', 'سنګاپوري ډالر', '🇸🇬'),
  Currency('MYR', 'مالیزیايي رینګټ', '🇲🇾'),
  Currency('THB', 'تایلنډي بات', '🇹🇭'),
  Currency('IDR', 'اندونیزیايي روپیه', '🇮🇩'),
  Currency('IRR', 'ایراني ریال', '🇮🇷'),
  Currency('IQD', 'عراقي دینار', '🇮🇶'),
  Currency('EGP', 'مصري پونډ', '🇪🇬'),
  Currency('ZAR', 'سویلي افریقایي رنډ', '🇿🇦'),
  Currency('BRL', 'برازیلي ریال', '🇧🇷'),
  Currency('MXN', 'مکسیکوي پېسو', '🇲🇽'),
  Currency('PLN', 'پولنډي زلوټي', '🇵🇱'),
  Currency('CZK', 'چېکي کرونا', '🇨🇿'),
  Currency('HUF', 'هنګري فورینټ', '🇭🇺'),
  Currency('ILS', 'اسرائیلي شیکل', '🇮🇱'),
  Currency('HKD', 'هانګ کانګ ډالر', '🇭🇰'),
  Currency('VND', 'ویتنامي دونګ', '🇻🇳'),
];

class AfghaniExchangeApp extends StatefulWidget {
  const AfghaniExchangeApp({super.key});

  @override
  State<AfghaniExchangeApp> createState() => _AfghaniExchangeAppState();
}

class _AfghaniExchangeAppState extends State<AfghaniExchangeApp> {
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afghani Exchange',
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF087F5B),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF19A974),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF101412),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
      ),
      home: HomePage(
        darkMode: darkMode,
        onDarkModeChanged: (value) {
          setState(() => darkMode = value);
        },
      ),
    );
  }
}

class ConversionRecord {
  final String from;
  final String to;
  final double amount;
  final double result;
  final DateTime time;

  ConversionRecord({
    required this.from,
    required this.to,
    required this.amount,
    required this.result,
    required this.time,
  });
}

class HomePage extends StatefulWidget {
  final bool darkMode;
  final ValueChanged<bool> onDarkModeChanged;

  const HomePage({
    super.key,
    required this.darkMode,
    required this.onDarkModeChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  Currency fromCurrency = currencies[0];
  Currency toCurrency = currencies[1];

  final TextEditingController amountController =
      TextEditingController(text: '1');

  double rate = 0;
  double converted = 0;

  bool loading = false;
  String? errorMessage;

  DateTime? lastUpdated;

  Timer? refreshTimer;

  final Set<String> favorites = {
    'USD',
    'PKR',
    'INR',
    'EUR',
    'AED',
    'SAR',
  };

  final List<ConversionRecord> history = [];

  late AnimationController animationController;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    animationController.forward();

    loadRate();

    refreshTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => loadRate(),
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    animationController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> requestRate(
    String base,
    String currency,
  ) async {
    final uri = Uri.parse(
      '$rateServerUrl?base=$base&currencies=$currency',
    );

    final client = HttpClient();

    try {
      final request = await client.getUrl(uri);
      request.headers.set(
        HttpHeaders.acceptHeader,
        'application/json',
      );

      final response = await request.close();

      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Server error: ${response.statusCode}');
      }

      final decoded = jsonDecode(body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid server response');
      }

      return decoded;
    } finally {
      client.close(force: true);
    }
  }

  Future<void> loadRate() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      if (fromCurrency.code == toCurrency.code) {
        if (!mounted) return;

        setState(() {
          rate = 1;
          converted = double.tryParse(amountController.text) ?? 0;
          lastUpdated = DateTime.now();
          loading = false;
        });

        return;
      }

      final data = await requestRate(
        fromCurrency.code,
        toCurrency.code,
      );

      dynamic rateMap = data['rates'];

      if (rateMap == null) {
        rateMap = data['results'];
      }

      if (rateMap is! Map) {
        throw Exception('Rate data not found');
      }

      final rawRate = rateMap[toCurrency.code];

      if (rawRate == null) {
        throw Exception('Rate not found');
      }

      final newRate = double.tryParse(rawRate.toString());

      if (newRate == null) {
        throw Exception('Invalid rate');
      }

      final amount =
          double.tryParse(amountController.text.replaceAll(',', '.')) ??
              0;

      if (!mounted) return;

      setState(() {
        rate = newRate;
        converted = amount * newRate;
        lastUpdated = DateTime.now();
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = 'د نرخونو ترلاسه کولو کې ستونزه راغله';
      });
    }
  }

  void calculate() {
    final amount =
        double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0;

    setState(() {
      converted = amount * rate;
    });
  }

  void swapCurrencies() {
    final oldFrom = fromCurrency;

    setState(() {
      fromCurrency = toCurrency;
      toCurrency = oldFrom;
    });

    loadRate();
  }

  void saveConversion() {
    final amount =
        double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0;

    if (amount <= 0 || rate <= 0) {
      return;
    }

    setState(() {
      history.insert(
        0,
        ConversionRecord(
          from: fromCurrency.code,
          to: toCurrency.code,
          amount: amount,
          result: converted,
          time: DateTime.now(),
        ),
      );

      if (history.length > 20) {
        history.removeLast();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تبدیل تاریخچه کې خوندي شو'),
        behavior: SnackBarBehavior.floating,
      ),
    );
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

  String formatNumber(double number) {
    if (number.abs() >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(2)}B';
    }

    if (number.abs() >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(2)}M';
    }

    if (number.abs() >= 1000) {
      return '${(number / 1000).toStringAsFixed(2)}K';
    }

    if (number == number.roundToDouble()) {
      return number.toStringAsFixed(0);
    }

    return number.toStringAsFixed(4);
  }

  String timeText() {
    if (lastUpdated == null) {
      return 'تر اوسه تازه شوی نه دی';
    }

    final h = lastUpdated!.hour.toString().padLeft(2, '0');
    final m = lastUpdated!.minute.toString().padLeft(2, '0');
    final s = lastUpdated!.second.toString().padLeft(2, '0');

    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          titleSpacing: 18,
          title: const Row(
            children: [
              Text(
                '🇦🇫',
                style: TextStyle(fontSize: 26),
              ),
              SizedBox(width: 9),
              Text(
                'Afghani Exchange',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'توره/روښانه بڼه',
              onPressed: () {
                widget.onDarkModeChanged(!widget.darkMode);
              },
              icon: Icon(
                widget.darkMode
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: loadRate,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              FadeTransition(
                opacity: animationController,
                child: _heroCard(),
              ),
              const SizedBox(height: 16),
              _converterCard(),
              const SizedBox(height: 16),
              _statusCard(),
              const SizedBox(height: 20),
              _sectionTitle(
                '⭐ خوښ اسعار',
                'ستاسو مهم اسعار',
              ),
              const SizedBox(height: 10),
              _favoritesCard(),
              const SizedBox(height: 20),
              _sectionTitle(
                '🌍 ۴۰ مهم اسعار',
                'هر وخت خپل اسعار پیدا کړئ',
              ),
              const SizedBox(height: 10),
              _currencySearchCard(),
              const SizedBox(height: 20),
              _sectionTitle(
                '📜 د تبدیلولو تاریخچه',
                'ستاسو وروستي تبدیلونه',
              ),
              const SizedBox(height: 10),
              _historyCard(),
              const SizedBox(height: 20),
              _sectionTitle(
                '📚 د اسعارو معلومات',
                'د مهمو اسعارو لنډ معلومات',
              ),
              const SizedBox(height: 10),
              _currencyInfoCard(),
              const SizedBox(height: 20),
              _developerCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF087F5B),
            Color(0xFF0B7285),
            Color(0xFF1864AB),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🇦🇫 AFN',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Afghani Exchange',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'د نړۍ اسعار په ساده او چټک ډول تبدیل کړئ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _heroSmallInfo(
                Icons.update_rounded,
                'هر ۶۰ ثانیې',
              ),
              const SizedBox(width: 10),
              _heroSmallInfo(
                Icons.public_rounded,
                '۴۰ اسعار',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroSmallInfo(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 17,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _converterCard() {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '💱 اسعار تبدیل کړئ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: loading ? null : swapCurrencies,
                  icon: const Icon(Icons.swap_horiz_rounded),
                  tooltip: 'بدلول',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _currencySelector(
              title: 'له',
              currency: fromCurrency,
              onTap: () => _showCurrencyPicker(
                selected: fromCurrency,
                onSelected: (currency) {
                  setState(() {
                    fromCurrency = currency;
                  });
                  loadRate();
                },
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) => calculate(),
              decoration: InputDecoration(
                labelText: 'مقدار',
                hintText: 'لکه 100',
                prefixIcon: const Icon(
                  Icons.calculate_rounded,
                ),
                suffixText: fromCurrency.code,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _currencySelector(
              title: 'ته',
              currency: toCurrency,
              onTap: () => _showCurrencyPicker(
                selected: toCurrency,
                onSelected: (currency) {
                  setState(() {
                    toCurrency = currency;
                  });
                  loadRate();
                },
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withOpacity(0.09),
              ),
              child: Column(
                children: [
                  const Text(
                    'تبدیل شوې اندازه',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    child: Text(
                      '${formatNumber(converted)} ${toCurrency.code}',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    rate > 0
                        ? '1 ${fromCurrency.code} = ${formatNumber(rate)} ${toCurrency.code}'
                        : 'نرخ ترلاسه کېږي...',
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: loading ? null : loadRate,
                    icon: loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.refresh_rounded),
                    label: const Text('نرخ تازه کړه'),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filledTonal(
                  onPressed: saveConversion,
                  icon: const Icon(Icons.bookmark_add_rounded),
                  tooltip: 'تاریخچه کې خوندي کړه',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _currencySelector({
    required String title,
    required Currency currency,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .outline
                .withOpacity(0.35),
          ),
        ),
        child: Row(
          children: [
            Text(
              currency.flag,
              style: const TextStyle(fontSize: 27),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${currency.code} • ${currency.name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: loading
                    ? Colors.orange.withOpacity(0.12)
                    : Colors.green.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                loading
                    ? Icons.sync_rounded
                    : Icons.check_circle_rounded,
                color: loading ? Colors.orange : Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loading
                        ? 'نرخ تازه کېږي...'
                        : 'نرخونه فعال دي',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '🕐 وروستی تازه کول: ${timeText()}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.65),
                    ),
                  ),
                ],
              ),
            ),
            if (errorMessage != null)
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _favoritesCard() {
    final list = currencies
        .where((currency) => favorites.contains(currency.code))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: list.map((currency) {
            return ActionChip(
              avatar: Text(currency.flag),
              label: Text(
                currency.code,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                setState(() {
                  toCurrency = currency;
                });
                loadRate();
              },
              onDeleted: () => toggleFavorite(currency.code),
              deleteIcon: const Icon(
                Icons.star_rounded,
                size: 17,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _currencySearchCard() {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.search_rounded),
        ),
        title: const Text(
          'د اسعارو لټون',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: const Text(
          'USD، PKR، INR، EUR او نور',
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 17,
        ),
        onTap: _showSearch,
      ),
    );
  }

  void _showSearch() {
    showSearch(
      context: context,
      delegate: CurrencySearchDelegate(
        onSelect: (currency) {
          setState(() {
            toCurrency = currency;
          });
          loadRate();
        },
        favorites: favorites,
        onFavorite: toggleFavorite,
      ),
    );
  }

  Widget _historyCard() {
    if (history.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 42,
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.5),
                ),
                const SizedBox(height: 8),
                const Text(
                  'تر اوسه تاریخچه نشته',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: history.take(6).map((item) {
          return ListTile(
            leading: CircleAvatar(
              child: Text(
                item.to.substring(0, 1),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              '${item.amount} ${item.from} → ${formatNumber(item.result)} ${item.to}',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
            subtitle: Text(
              '${item.time.hour.toString().padLeft(2, '0')}:${item.time.minute.toString().padLeft(2, '0')}',
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _currencyInfoCard() {
    final important = [
      currencies[0],
      currencies[1],
      currencies[4],
      currencies[5],
      currencies[6],
      currencies[7],
    ];

    return Card(
      child: Column(
        children: important.map((currency) {
          String description = '';

          switch (currency.code) {
            case 'AFN':
              description = 'د افغانستان ملي پیسه';
              break;
            case 'USD':
              description = 'د امریکا متحده ایالاتو پیسه';
              break;
            case 'PKR':
              description = 'د پاکستان ملي روپۍ';
              break;
            case 'INR':
              description = 'د هند ملي روپۍ';
              break;
            case 'AED':
              description = 'د متحده عربي اماراتو درهم';
              break;
            case 'SAR':
              description = 'د سعودي عربستان ریال';
              break;
          }

          return ListTile(
            leading: Text(
              currency.flag,
              style: const TextStyle(fontSize: 27),
            ),
            title: Text(
              '${currency.code} • ${currency.name}',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
            subtitle: Text(description),
            trailing: IconButton(
              onPressed: () => toggleFavorite(currency.code),
              icon: Icon(
                favorites.contains(currency.code)
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _developerCard() {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.12),
              Theme.of(context).colorScheme.secondary.withOpacity(0.08),
            ],
          ),
        ),
        child: const Row(
          children: [
            CircleAvatar(
              radius: 27,
              child: Icon(
                Icons.person_rounded,
                size: 30,
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '👤 Developer',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Abdullah ALOKOZAI',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Afghani Exchange',
                    style: TextStyle(
                      fontSize: 12,
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

  void _showCurrencyPicker({
    required Currency selected,
    required ValueChanged<Currency> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 25),
              children: [
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    '🌍 اسعار انتخاب کړئ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                ...currencies.map(
                  (currency) => ListTile(
                    leading: Text(
                      currency.flag,
                      style: const TextStyle(fontSize: 27),
                    ),
                    title: Text(
                      currency.code,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    subtitle: Text(currency.name),
                    trailing: currency.code == selected.code
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: Colors.green,
                          )
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      onSelected(currency);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CurrencySearchDelegate extends SearchDelegate<Currency?> {
  final ValueChanged<Currency> onSelect;
  final Set<String> favorites;
  final ValueChanged<String> onFavorite;

  CurrencySearchDelegate({
    required this.onSelect,
    required this.favorites,
    required this.onFavorite,
  });

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () => query = '',
          icon: const Icon(Icons.clear_rounded),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back_rounded),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _results();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _results();
  }

  Widget _results() {
    final q = query.toLowerCase().trim();

    final results = currencies.where((currency) {
      if (q.isEmpty) return true;

      return currency.code.toLowerCase().contains(q) ||
          currency.name.toLowerCase().contains(q);
    }).toList();

    if (results.isEmpty) {
      return const Center(
        child: Text('اسعار پیدا نه شول'),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final currency = results[index];

          return ListTile(
            leading: Text(
              currency.flag,
              style: const TextStyle(fontSize: 27),
            ),
            title: Text(
              currency.code,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
            subtitle: Text(currency.name),
            trailing: IconButton(
              onPressed: () => onFavorite(currency.code),
              icon: Icon(
                favorites.contains(currency.code)
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
              ),
            ),
            onTap: () {
              onSelect(currency);
              close(context, currency);
            },
          );
        },
      ),
    );
  }
}
