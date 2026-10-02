import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

const String workerUrl =
    'https://afghani-exchange-api.abdullah-alingari.workers.dev';

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
  Currency('NZD', 'نیوزیلنډ ډالر', '🇳🇿'),
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

class Currency {
  final String code;
  final String name;
  final String flag;

  const Currency(this.code, this.name, this.flag);
}

class HistoryItem {
  final String from;
  final String to;
  final double amount;
  final double result;
  final DateTime time;

  HistoryItem({
    required this.from,
    required this.to,
    required this.amount,
    required this.result,
    required this.time,
  });
}

void main() {
  runApp(const AfghaniExchangeApp());
}

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
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7F6),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF16A085),
          brightness: Brightness.dark,
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
      ),
      home: HomePage(
        darkMode: darkMode,
        onDarkModeChanged: (value) {
          setState(() {
            darkMode = value;
          });
        },
      ),
    );
  }
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
  double result = 0;

  bool loading = false;
  String error = '';

  DateTime? lastUpdated;

  Timer? timer;

  final Set<String> favorites = {
    'USD',
    'PKR',
    'INR',
    'EUR',
    'AED',
    'SAR',
  };

  final List<HistoryItem> history = [];

  late AnimationController animationController;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    animationController.forward();

    loadRate();

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
    animationController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> fetchRate() async {
    final uri = Uri.parse(workerUrl).replace(
      queryParameters: {
        'base': fromCurrency.code,
        'currencies': toCurrency.code,
      },
    );

    final client = HttpClient();

    try {
      final request = await client.getUrl(uri);

      request.headers.set(
        HttpHeaders.acceptHeader,
        'application/json',
      );

      final response = await request.close();

      final body = await response
          .transform(utf8.decoder)
          .join();

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          'Server status ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid response');
      }

      return decoded;
    } finally {
      client.close(force: true);
    }
  }

  Future<void> loadRate() async {
    if (!mounted) return;

    if (fromCurrency.code == toCurrency.code) {
      final amount =
          double.tryParse(amountController.text) ?? 0;

      setState(() {
        rate = 1;
        result = amount;
        loading = false;
        error = '';
        lastUpdated = DateTime.now();
      });

      return;
    }

    setState(() {
      loading = true;
      error = '';
    });

    try {
      final data = await fetchRate();

      dynamic rates = data['rates'];

      if (rates == null) {
        rates = data['results'];
      }

      if (rates is! Map) {
        throw Exception('No rates');
      }

      final raw = rates[toCurrency.code];

      if (raw == null) {
        throw Exception('Currency rate not found');
      }

      final newRate =
          double.tryParse(raw.toString());

      if (newRate == null) {
        throw Exception('Invalid rate');
      }

      final amount =
          double.tryParse(
                amountController.text.replaceAll(',', '.'),
              ) ??
              0;

      if (!mounted) return;

      setState(() {
        rate = newRate;
        result = amount * newRate;
        lastUpdated = DateTime.now();
        loading = false;
        error = '';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = 'د نرخ ترلاسه کولو کې ستونزه راغله';
      });
    }
  }

  void calculate() {
    final amount =
        double.tryParse(
              amountController.text.replaceAll(',', '.'),
            ) ??
            0;

    setState(() {
      result = amount * rate;
    });
  }

  void swap() {
    final old = fromCurrency;

    setState(() {
      fromCurrency = toCurrency;
      toCurrency = old;
    });

    loadRate();
  }

  void saveHistory() {
    final amount =
        double.tryParse(amountController.text) ?? 0;

    if (amount <= 0 || rate <= 0) return;

    setState(() {
      history.insert(
        0,
        HistoryItem(
          from: fromCurrency.code,
          to: toCurrency.code,
          amount: amount,
          result: result,
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

  String number(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(4);
  }

  String updatedText() {
    if (lastUpdated == null) {
      return 'تر اوسه تازه شوی نه دی';
    }

    final h =
        lastUpdated!.hour.toString().padLeft(2, '0');

    final m =
        lastUpdated!.minute.toString().padLeft(2, '0');

    final s =
        lastUpdated!.second.toString().padLeft(2, '0');

    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              Text(
                '🇦🇫',
                style: TextStyle(fontSize: 25),
              ),
              SizedBox(width: 8),
              Text(
                'Afghani Exchange',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                widget.onDarkModeChanged(
                  !widget.darkMode,
                );
              },
              icon: Icon(
                widget.darkMode
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: loadRate,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              FadeTransition(
                opacity: animationController,
                child: heroCard(),
              ),
              const SizedBox(height: 16),
              converterCard(),
              const SizedBox(height: 14),
              statusCard(),
              const SizedBox(height: 22),
              sectionTitle(
                '⭐ خوښ اسعار',
                'ستاسو مهم اسعار',
              ),
              const SizedBox(height: 10),
              favoritesCard(),
              const SizedBox(height: 22),
              sectionTitle(
                '🌍 ۴۰ مهم اسعار',
                'د هر اسعارو لټون او انتخاب',
              ),
              const SizedBox(height: 10),
              searchCard(),
              const SizedBox(height: 22),
              sectionTitle(
                '📜 د تبدیلولو تاریخچه',
                'وروستي تبدیلونه',
              ),
              const SizedBox(height: 10),
              historyCard(),
              const SizedBox(height: 22),
              sectionTitle(
                '📚 د اسعارو معلومات',
                'مهم نړیوال اسعار',
              ),
              const SizedBox(height: 10),
              currencyInfoCard(),
              const SizedBox(height: 22),
              developerCard(),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  Widget heroCard() {
    return Container(
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF087F5B),
            Color(0xFF0B7285),
            Color(0xFF1864AB),
          ],
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 22,
            offset: const Offset(0, 10),
            color: Colors.black26,
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🇦🇫 AFN',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Afghani Exchange',
            style: TextStyle(
              color: Colors.white,
              fontSize: 29,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'د نړۍ اسعار په ساده او چټک ډول تبدیل کړئ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 18),
          Row(
            children: [
              Text(
                '🔄 هر ۶۰ ثانیې',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 20),
              Text(
                '🌍 ۴۰ اسعار',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget converterCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '💱 Currency Conversion',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: loading ? null : swap,
                  icon: const Icon(
                    Icons.swap_horiz_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            currencyButton(
              'له',
              fromCurrency,
              () {
                openPicker(
                  fromCurrency,
                  (c) {
                    setState(() {
                      fromCurrency = c;
                    });
                    loadRate();
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) => calculate(),
              decoration: InputDecoration(
                labelText: 'مقدار',
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
            currencyButton(
              'ته',
              toCurrency,
              () {
                openPicker(
                  toCurrency,
                  (c) {
                    setState(() {
                      toCurrency = c;
                    });
                    loadRate();
                  },
                );
              },
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
                    .withOpacity(.10),
              ),
              child: Column(
                children: [
                  const Text(
                    'تبدیل شوې اندازه',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 7),
                  FittedBox(
                    child: Text(
                      '${number(result)} ${toCurrency.code}',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context)
                            .colorScheme
                            .primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    rate > 0
                        ? '1 ${fromCurrency.code} = ${number(rate)} ${toCurrency.code}'
                        : 'نرخ ترلاسه کېږي...',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed:
                        loading ? null : loadRate,
                    icon: loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.refresh_rounded,
                          ),
                    label: const Text(
                      'تازه کول',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filledTonal(
                  onPressed: saveHistory,
                  icon: const Icon(
                    Icons.bookmark_add_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget currencyButton(
    String title,
    Currency currency,
    VoidCallback onTap,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .outline
                .withOpacity(.35),
          ),
        ),
        child: Row(
          children: [
            Text(
              currency.flag,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 11),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${currency.code} • ${currency.name}',
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

  Widget statusCard() {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(
            loading
                ? Icons.sync_rounded
                : Icons.check_circle_rounded,
          ),
        ),
        title: Text(
          loading
              ? 'نرخونه تازه کېږي...'
              : 'نرخونه فعال دي',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          '🕐 Last Updated: ${updatedText()}',
        ),
        trailing: error.isNotEmpty
            ? const Icon(
                Icons.error_outline,
                color: Colors.red,
              )
            : null,
      ),
    );
  }

  Widget sectionTitle(
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
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
                .withOpacity(.60),
          ),
        ),
      ],
    );
  }

  Widget favoritesCard() {
    final list = currencies
        .where(
          (c) => favorites.contains(c.code),
        )
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: list.map(
            (currency) {
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
              );
            },
          ).toList(),
        ),
      ),
    );
  }

  Widget searchCard() {
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
          'USD • PKR • INR • EUR • CNY او نور',
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 17,
        ),
        onTap: showCurrencySearch,
      ),
    );
  }

  void showCurrencySearch() {
    showSearch(
      context: context,
      delegate: CurrencyDelegate(
        favorites: favorites,
        onFavorite: toggleFavorite,
        onSelect: (currency) {
          setState(() {
            toCurrency = currency;
          });
          loadRate();
        },
      ),
    );
  }

  Widget historyCard() {
    if (history.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Center(
            child: Column(
              children: [
                const Icon(
                  Icons.history_rounded,
                  size: 45,
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
        children: history.take(8).map(
          (item) {
            return ListTile(
              leading: CircleAvatar(
                child: Text(
                  item.to.substring(0, 1),
                ),
              ),
              title: Text(
                '${item.amount} ${item.from} → ${number(item.result)} ${item.to}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: Text(
                '${item.time.hour.toString().padLeft(2, '0')}:${item.time.minute.toString().padLeft(2, '0')}',
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget currencyInfoCard() {
    final important = [
      currencies[0],
      currencies[1],
      currencies[4],
      currencies[5],
      currencies[6],
      currencies[7],
      currencies[13],
      currencies[14],
    ];

    return Card(
      child: Column(
        children: important.map(
          (currency) {
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
              trailing: IconButton(
                onPressed: () {
                  toggleFavorite(currency.code);
                },
                icon: Icon(
                  favorites.contains(currency.code)
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget developerCard() {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [
              Theme.of(context)
                  .colorScheme
                  .primary
                  .withOpacity(.12),
              Theme.of(context)
                  .colorScheme
                  .secondary
                  .withOpacity(.08),
            ],
          ),
        ),
        child: const Row(
          children: [
            CircleAvatar(
              radius: 28,
              child: Icon(
                Icons.person_rounded,
                size: 30,
              ),
            ),
            SizedBox(width: 14),
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  '👤 Developer',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 4),
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
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void openPicker(
    Currency selected,
    ValueChanged<Currency> onSelected,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SizedBox(
            height:
                MediaQuery.of(context).size.height * .78,
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    '🌍 اسعار انتخاب کړئ',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                ...currencies.map(
                  (currency) {
                    return ListTile(
                      leading: Text(
                        currency.flag,
                        style: const TextStyle(
                          fontSize: 27,
                        ),
                      ),
                      title: Text(
                        currency.code,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      subtitle: Text(currency.name),
                      trailing:
                          selected.code == currency.code
                              ? const Icon(
                                  Icons
                                      .check_circle_rounded,
                                  color: Colors.green,
                                )
                              : null,
                      onTap: () {
                        Navigator.pop(context);
                        onSelected(currency);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CurrencyDelegate
    extends SearchDelegate<Currency?> {
  final Set<String> favorites;
  final ValueChanged<String> onFavorite;
  final ValueChanged<Currency> onSelect;

  CurrencyDelegate({
    required this.favorites,
    required this.onFavorite,
    required this.onSelect,
  });

  @override
  List<Widget>? buildActions(
    BuildContext context,
  ) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear_rounded),
        ),
    ];
  }

  @override
  Widget? buildLeading(
    BuildContext context,
  ) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(
        Icons.arrow_back_rounded,
      ),
    );
  }

  @override
  Widget buildResults(
    BuildContext context,
  ) {
    return results();
  }

  @override
  Widget buildSuggestions(
    BuildContext context,
  ) {
    return results();
  }

  Widget results() {
    final search = query.toLowerCase().trim();

    final list = currencies.where(
      (currency) {
        if (search.isEmpty) return true;

        return currency.code
                .toLowerCase()
                .contains(search) ||
            currency.name
                .toLowerCase()
                .contains(search);
      },
    ).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          final currency = list[index];

          return ListTile(
            leading: Text(
              currency.flag,
              style: const TextStyle(
                fontSize: 27,
              ),
            ),
            title: Text(
              currency.code,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
            subtitle: Text(currency.name),
            trailing: IconButton(
              onPressed: () {
                onFavorite(currency.code);
              },
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
