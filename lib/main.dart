import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AfghaniExchangeApp());
}

class Rate {
  final String currency;
  final String name;
  final double buy;
  final double sell;

  Rate(this.currency, this.name, this.buy, this.sell);
}

class Market {
  final String name;
  final String url;

  const Market(this.name, this.url);
}

class AfghaniExchangeApp extends StatelessWidget {
  const AfghaniExchangeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afghani Exchange Pro',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080808),
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Color(0xFFBDBDBD),
        ),
        cardColor: const Color(0xFF171717),
        useMaterial3: true,
      ),
      home: const ExchangeHome(),
    );
  }
}

class ExchangeHome extends StatefulWidget {
  const ExchangeHome({super.key});

  @override
  State<ExchangeHome> createState() => _ExchangeHomeState();
}

class _ExchangeHomeState extends State<ExchangeHome> {
  final markets = const [
    Market('Sarai Shahzada',
        'https://sarafi.af/en/exchange-rates'),
    Market('Khorasan Market',
        'https://sarafi.af/en/exchange-rates/khorasan-market'),
    Market('Da Afghanistan Bank',
        'https://sarafi.af/en/exchange-rates/da-afg-bank'),
  ];

  final languages = ['پښتو', 'دری', 'English'];

  final Map<String, Map<String, String>> translations = {
    'پښتو': {
      'title': 'د افغانیو تبادله',
      'market': 'د بازار انتخاب',
      'buy': 'پېر',
      'sell': 'پلور',
      'currency': 'اسعار',
      'history': 'د نرخونو تاریخچه',
      'refresh': 'نرخونه تازه کړه',
      'updated': 'وروستی تازه کېدل',
      'developer': 'جوړوونکی',
      'name': 'عبدالله ایمان',
      'error': 'د نرخونو ترلاسه کول ناکام شول',
      'loading': 'نرخونه ترلاسه کېږي...',
      'source': 'سرچینه',
      'date': 'نېټه',
    },
    'دری': {
      'title': 'تبادله اسعار افغانی',
      'market': 'انتخاب بازار',
      'buy': 'خرید',
      'sell': 'فروش',
      'currency': 'ارز',
      'history': 'تاریخچه نرخ‌ها',
      'refresh': 'تازه‌سازی نرخ‌ها',
      'updated': 'آخرین به‌روزرسانی',
      'developer': 'سازنده',
      'name': 'عبدالله ایمان',
      'error': 'دریافت نرخ‌ها ناموفق بود',
      'loading': 'دریافت نرخ‌ها...',
      'source': 'منبع',
      'date': 'تاریخ',
    },
    'English': {
      'title': 'Afghani Exchange',
      'market': 'Select Market',
      'buy': 'Buy',
      'sell': 'Sell',
      'currency': 'Currency',
      'history': 'Rate History',
      'refresh': 'Refresh Rates',
      'updated': 'Last Updated',
      'developer': 'Developer',
      'name': 'Abdullah Eman',
      'error': 'Could not load rates',
      'loading': 'Loading rates...',
      'source': 'Source',
      'date': 'Date',
    },
  };

  String language = 'پښتو';
  int selectedMarket = 0;
  List<Rate> rates = [];
  List<String> history = [];
  bool loading = false;
  String? error;
  DateTime? lastUpdated;

  String t(String key) =>
      translations[language]![key] ?? key;

  @override
  void initState() {
    super.initState();
    loadHistory();
    fetchRates();
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('rate_history') ?? [];
    if (mounted) setState(() => history = saved);
  }

  Future<void> saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'rate_history',
      history.take(100).toList(),
    );
  }

  double? parseNumber(String value) {
    final cleaned = value.replaceAll(',', '').trim();
    return double.tryParse(cleaned);
  }

  Future<void> fetchRates() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final response = await http.get(
        Uri.parse(markets[selectedMarket].url),
        headers: {
          'User-Agent': 'Mozilla/5.0',
          'Accept': 'text/html',
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final document = html_parser.parse(
        utf8.decode(response.bodyBytes),
      );

      final rows = document.querySelectorAll('table tr');
      final List<Rate> newRates = [];

      for (final row in rows) {
        final cells = row.querySelectorAll('td');
        if (cells.length < 3) continue;

        final label = cells[0].text.trim();
        final buy = parseNumber(cells[1].text);
        final sell = parseNumber(cells[2].text);

        final match = RegExp(
          r'([A-Z]{3})/AFN',
        ).firstMatch(label);

        if (match == null || buy == null || sell == null) {
          continue;
        }

        final code = match.group(1)!;

        newRates.add(
          Rate(code, label, buy, sell),
        );
      }

      if (newRates.isEmpty) {
        throw Exception('No valid rate data found');
      }

      final now = DateTime.now();
      final usd = newRates.where((r) => r.currency == 'USD');

      final historyEntry =
          '${markets[selectedMarket].name}|'
          '${now.toIso8601String()}|'
          '${usd.isNotEmpty ? usd.first.buy : 0}';

      setState(() {
        rates = newRates;
        lastUpdated = now;
        loading = false;
        history.insert(0, historyEntry);
        if (history.length > 100) {
          history = history.take(100).toList();
        }
      });

      await saveHistory();
    } catch (e) {
      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  String formattedDate(DateTime date) {
    const months = {
      'پښتو': [
        'جنوري', 'فبروري', 'مارچ', 'اپرېل',
        'مې', 'جون', 'جولای', 'اګست',
        'سپتمبر', 'اکتوبر', 'نومبر', 'دسمبر'
      ],
      'دری': [
        'جنوری', 'فبروری', 'مارچ', 'اپریل',
        'می', 'جون', 'جولای', 'اگست',
        'سپتامبر', 'اکتوبر', 'نوامبر', 'دسامبر'
      ],
      'English': [
        'January', 'February', 'March', 'April',
        'May', 'June', 'July', 'August',
        'September', 'October', 'November', 'December'
      ],
    };

    final month = months[language]![date.month - 1];
    return '${date.day} $month ${date.year}';
  }

  Widget marketSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF191919),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedMarket,
          isExpanded: true,
          dropdownColor: const Color(0xFF191919),
          items: List.generate(
            markets.length,
            (index) => DropdownMenuItem(
              value: index,
              child: Text(markets[index].name),
            ),
          ),
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              selectedMarket = value;
              rates = [];
            });
            fetchRates();
          },
        ),
      ),
    );
  }

  Widget rateCard(Rate rate) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                rate.currency,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rate.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('${t('buy')}: '),
                    Text(
                      rate.buy.toStringAsFixed(2),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text('${t('sell')}: '),
                    Text(
                      rate.sell.toStringAsFixed(2),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget historySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('history'),
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (history.isEmpty)
          const Text('No saved history yet'),
        ...history.take(10).map((item) {
          final parts = item.split('|');
          if (parts.length != 3) return const SizedBox();
          final date = DateTime.tryParse(parts[1]);
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.history),
            title: Text(parts[0]),
            subtitle: Text(
              date == null ? parts[1] : formattedDate(date),
            ),
            trailing: Text(
              'USD: ${parts[2]}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget developerSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              color: Colors.black,
              size: 35,
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t('developer'),
                style: const TextStyle(color: Colors.white54),
              ),
              Text(
                t('name'),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Afghani Exchange Pro',
                style: TextStyle(color: Colors.white54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          t('title'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (value) {
              setState(() => language = value);
            },
            itemBuilder: (_) => languages.map((lang) {
              return PopupMenuItem(
                value: lang,
                child: Text(lang),
              );
            }).toList(),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: Colors.black,
        backgroundColor: Colors.white,
        onRefresh: fetchRates,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF202020),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.currency_exchange, size: 32),
                  const SizedBox(height: 12),
                  Text(
                    'AFN  |  AFGHANISTAN',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'AFGHANI EXCHANGE PRO',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              t('market'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 10),
            marketSelector(),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    t('currency'),
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: loading ? null : fetchRates,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            if (loading)
              Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    const CircularProgressIndicator(
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(t('loading')),
                  ],
                ),
              ),
            if (error != null)
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text('${t('error')}\n$error'),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: fetchRates,
                      child: Text(t('refresh')),
                    ),
                  ],
                ),
              ),
            ...rates.map(rateCard),
            if (lastUpdated != null) ...[
              const SizedBox(height: 10),
              Text(
                '${t('updated')}: ${formattedDate(lastUpdated!)} '
                '${lastUpdated!.hour.toString().padLeft(2, '0')}:'
                '${lastUpdated!.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(color: Colors.white54),
              ),
              Text(
                '${t('source')}: ${markets[selectedMarket].name}',
                style: const TextStyle(color: Colors.white54),
              ),
            ],
            const SizedBox(height: 28),
            historySection(),
            const SizedBox(height: 28),
            developerSection(),
            const SizedBox(height: 30),
            const Center(
              child: Text(
                '© 2026 Abdullah Eman',
                style: TextStyle(color: Colors.white38),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
