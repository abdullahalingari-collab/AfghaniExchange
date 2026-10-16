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
  Currency('EUR', 'یورو', '🇪🇺'),
  Currency('PKR', 'پاکستانۍ روپۍ', '🇵🇰'),
  Currency('INR', 'هندي روپۍ', '🇮🇳'),
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
  State<AfghaniExchangeApp> createState() => _AfghaniExchangeAppState();
}

class _AfghaniExchangeAppState extends State<AfghaniExchangeApp> {
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
            themeMode = dark ? ThemeMode.dark : ThemeMode.light;
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

  final amountController = TextEditingController(text: '1');
  final searchController = TextEditingController();

  Timer? refreshTimer;

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

    refreshTimer = Timer.periodic(
      const Duration(minutes: 1),
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
    if (!mounted) return;

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final url = Uri.parse(
        'https://api.fxratesapi.com/latest'
        '?base=$from'
        '&currencies=$to'
        '&resolution=1m'
        '&amount=1'
        '&places=8'
        '&format=json',
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final data = jsonDecode(response.body);

      final rates = data['rates'];

      if (rates == null) {
        throw Exception('Rate not found');
      }

      final value = rates[to];

      if (value == null) {
        throw Exception('Currency not found');
      }

      final newRate = (value as num).toDouble();

      if (!mounted) return;

      setState(() {
        rate = newRate;
        lastUpdated = DateTime.now();
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = 'د نرخ ترلاسه کولو ستونزه ده';
      });
    }
  }

  void swapCurrencies() {
    setState(() {
      final oldFrom = from;
      from = to;
      to = oldFrom;
    });

    loadRate();
  }

  void convertAmount(String value) {
    final parsed = double.tryParse(
      value.replaceAll(',', ''),
    );

    if (parsed != null) {
      setState(() {
        amount = parsed;
      });
    }
  }

  String resultText() {
    final result = amount * rate;

    if (result == 0) return '0';

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

  Currency getCurrency(String code) {
    return currencies.firstWhere(
      (currency) => currency.code == code,
    );
  }

  String currencyName(Currency currency) {
    if (widget.language == 'English') {
      return currency.code;
    }

    if (widget.language == 'دری') {
      return currency.code;
    }

    return currency.name;
  }

  void addConversionHistory() {
    final item =
        '${amount.toStringAsFixed(2)} $from = ${resultText()} $to';

    setState(() {
      conversionHistory.insert(0, item);

      if (conversionHistory.length > 15) {
        conversionHistory.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = currencies.where((currency) {
      final search = searchController.text.toLowerCase();

      return currency.code.toLowerCase().contains(search) ||
          currency.name.toLowerCase().contains(search);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Afghani Exchange',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Theme',
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
            onSelected: widget.onLanguageChanged,
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
          padding: const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            30,
          ),
          children: [
            _buildHeroCard(),
            const SizedBox(height: 16),
            _buildConverterCard(),
            const SizedBox(height: 20),
            _buildQuickFavorites(),
            const SizedBox(height: 20),
            _buildSearch(),
            const SizedBox(height: 12),
            _buildSectionTitle(
              widget.language == 'English'
                  ? 'World currencies'
                  : widget.language == 'دری'
                      ? 'ارزهای جهان'
                      : 'د نړۍ اسعار',
              Icons.public,
            ),
            const SizedBox(height: 8),
            ...filtered.map(_buildCurrencyTile),
            const SizedBox(height: 16),
            _buildHistorySection(),
            const SizedBox(height: 16),
            _buildCurrencyHistorySection(),
            const SizedBox(height: 16),
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    final primary =
        Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary,
            Theme.of(context)
                .colorScheme
                .secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(.12),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '🇦🇫',
            style: TextStyle(fontSize: 52),
          ),
          const SizedBox(height: 8),
          const Text(
            'Afghani Exchange',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.language == 'English'
                ? 'Smart currency converter'
                : widget.language == 'دری'
                    ? 'تبدیل هوشمند ارزها'
                    : 'د اسعارو هوښیار تبدیل',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.15),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  size: 10,
                  color: loading
                      ? Colors.orangeAccent
                      : Colors.lightGreenAccent,
                ),
                const SizedBox(width: 8),
                Text(
                  loading
                      ? 'Updating...'
                      : 'Rates update automatically',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConverterCard() {
    final fromCurrency = getCurrency(from);
    final toCurrency = getCurrency(to);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _currencyBox(
                    fromCurrency,
                    true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                  ),
                  child: IconButton.filled(
                    onPressed: swapCurrencies,
                    icon: const Icon(
                      Icons.swap_horiz,
                      size: 25,
                    ),
                  ),
                ),
                Expanded(
                  child: _currencyBox(
                    toCurrency,
                    false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            TextField(
              controller: amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: convertAmount,
              decoration: InputDecoration(
                labelText: 'مقدار',
                hintText: 'لکه 100',
                prefixIcon: const Icon(
                  Icons.calculate_outlined,
                ),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
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
                    .surfaceContainerHighest,
              ),
              child: Column(
                children: [
                  Text(
                    '${fromCurrency.flag} '
                    '${amount.toStringAsFixed(2)} $from',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Icon(
                    Icons.arrow_downward_rounded,
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${toCurrency.flag} '
                    '${resultText()} $to',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      error!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  loadRate();
                  addConversionHistory();
                },
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'نرخ تازه کول',
                ),
              ),
            ),
            if (lastUpdated != null) ...[
              const SizedBox(height: 8),
              Text(
                'Last update: '
                '${lastUpdated!.hour.toString().padLeft(2, '0')}:'
                '${lastUpdated!.minute.toString().padLeft(2, '0')}:'
                '${lastUpdated!.second.toString().padLeft(2, '0')}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _currencyBox(
    Currency currency,
    bool isFrom,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _showCurrencyPicker(isFrom),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
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
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 4),
            Text(
              currency.code,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickFavorites() {
    final favoriteCurrencies = currencies
        .where((currency) =>
            favorites.contains(currency.code))
        .toList();

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          '⭐ خوښ اسعار',
          Icons.star_outline,
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 105,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: favoriteCurrencies.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: 10),
            itemBuilder: (_, index) {
              final currency =
                  favoriteCurrencies[index];

              return InkWell(
                borderRadius:
                    BorderRadius.circular(20),
                onTap: () {
                  setState(() {
                    to = currency.code;
                  });
                  loadRate();
                },
                child: Container(
                  width: 105,
                  padding:
                      const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(20),
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Text(
                        currency.flag,
                        style: const TextStyle(
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        currency.code,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearch() {
    return TextField(
      controller: searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'د اسعارو لټون...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon:
            searchController.text.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      searchController.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.clear),
                  ),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
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
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyTile(
    Currency currency,
  ) {
    final isFavorite =
        favorites.contains(currency.code);

    final selected =
        currency.code == from ||
            currency.code == to;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 7),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        leading: Text(
          currency.flag,
          style: const TextStyle(fontSize: 30),
        ),
        title: Text(
          currency.code,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          currencyName(currency),
        ),
        selected: selected,
        trailing: IconButton(
          onPressed: () {
            setState(() {
              if (isFavorite) {
                favorites.remove(currency.code);
              } else {
                favorites.add(currency.code);
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
            to = currency.code;
          });
          loadRate();
        },
      ),
    );
  }

  Widget _buildHistorySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'د تبدیل تاریخچه',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (conversionHistory.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        conversionHistory.clear();
                      });
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                    ),
                  ),
              ],
            ),
            const Divider(),
            if (conversionHistory.isEmpty)
              const Padding(
                padding:
                    EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  'تر اوسه کوم تبدیل نه دی ثبت شوی.',
                ),
              )
            else
              ...conversionHistory.map(
                (item) => ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.currency_exchange,
                  ),
                  title: Text(item),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyHistorySection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              'د اسعارو تاریخ',
              Icons.auto_stories_outlined,
            ),
            const SizedBox(height: 14),
            _historyItem(
              '۱۲۹۸ هـ ش',
              'په افغانستان کې د بانکنوټونو د استعمال لومړنۍ دوره.',
              Icons.account_balance,
            ),
            _historyItem(
              '۱۳۸۱ هـ ش',
              'د افغانۍ د پیسو اصلاح وشوه او درې صفرونه لرې شول.',
              Icons.currency_exchange,
            ),
            _historyItem(
              'نن',
              'افغانۍ د افغانستان رسمي پولي واحد دی.',
              Icons.flag,
            ),
            const SizedBox(height: 8),
            const Text(
              'یادونه: د تاریخ معلومات به د معتبره رسمي سرچینو پر بنسټ نور هم پراخېږي.',
              style: TextStyle(
                fontSize: 12,
              ),
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
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer,
            ),
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
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(text),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
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
            radius: 38,
            child: Icon(
              Icons.person,
              size: 42,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Afghani Exchange',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'د اپ جوړونکی',
            style: TextStyle(
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Abdullah ALOKOZAI',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'د اسعارو د تبدیل لپاره ساده، ښکلی او ګټور اپلیکیشن.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          const Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(Icons.code),
              SizedBox(width: 6),
              Text(
                'Made with Flutter 🇦🇫',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCurrencyPicker(bool isFrom) {
    String search = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (
            context,
            setModalState,
          ) {
            final list =
                currencies.where((currency) {
              return currency.code
                      .toLowerCase()
                      .contains(
                        search.toLowerCase(),
                      ) ||
                  currency.name
                      .toLowerCase()
                      .contains(
                        search.toLowerCase(),
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
                        const EdgeInsets.all(16),
                    child: TextField(
                      autofocus: true,
                      onChanged: (value) {
                        setModalState(() {
                          search = value;
                        });
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
                      itemCount: list.length,
                      itemBuilder:
                          (_, index) {
                        final currency =
                            list[index];

                        return ListTile(
                          leading: Text(
                            currency.flag,
                            style:
                                const TextStyle(
                              fontSize: 28,
                            ),
                          ),
                          title: Text(
                            currency.code,
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                          subtitle:
                              Text(
                            currency.name,
                          ),
                          onTap: () {
                            setState(() {
                              if (isFrom) {
                                from =
                                    currency
                                        .code;
                              } else {
                                to =
                                    currency
                                        .code;
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
