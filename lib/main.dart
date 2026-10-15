import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

void main() => runApp(const AfghaniExchangeApp());

const apiUrl =
    'https://afghani-exchange-api.abdullah-alingari.workers.dev';

const currencyNames = <String, String>{
  'AFN': 'Afghan Afghani',
  'USD': 'US Dollar',
  'EUR': 'Euro',
  'GBP': 'British Pound',
  'PKR': 'Pakistani Rupee',
  'INR': 'Indian Rupee',
  'AED': 'UAE Dirham',
  'SAR': 'Saudi Riyal',
  'CNY': 'Chinese Yuan',
  'TRY': 'Turkish Lira',
  'CAD': 'Canadian Dollar',
  'AUD': 'Australian Dollar',
  'JPY': 'Japanese Yen',
  'CHF': 'Swiss Franc',
  'IRR': 'Iranian Rial',
  'BDT': 'Bangladeshi Taka',
  'KWD': 'Kuwaiti Dinar',
  'QAR': 'Qatari Riyal',
  'OMR': 'Omani Rial',
  'MYR': 'Malaysian Ringgit',
  'SGD': 'Singapore Dollar',
  'THB': 'Thai Baht',
  'RUB': 'Russian Ruble',
  'NZD': 'New Zealand Dollar',
  'NOK': 'Norwegian Krone',
  'SEK': 'Swedish Krona',
  'DKK': 'Danish Krone',
  'ZAR': 'South African Rand',
  'BRL': 'Brazilian Real',
  'KRW': 'South Korean Won',
  'HKD': 'Hong Kong Dollar',
  'EGP': 'Egyptian Pound',
  'IQD': 'Iraqi Dinar',
  'KZT': 'Kazakhstani Tenge',
  'UZS': 'Uzbekistani Som',
  'TJS': 'Tajikistani Somoni',
};

const words = {
  'ps': {
    'title': 'افغاني اېکسچېنج',
    'converter': 'د اسعارو تبدیل',
    'amount': 'اندازه ولیکئ',
    'from': 'له کوم اسعارو',
    'to': 'کوم اسعارو ته',
    'swap': 'اسعار بدلول',
    'favorites': 'زما خوښې',
    'history': 'د تبدیل تاریخچه',
    'search': 'اسعار ولټوئ',
    'refresh': 'نرخونه تازه کړئ',
    'updated': 'وروستی تازه کېدل',
    'loading': 'نرخونه ترلاسه کېږي...',
    'error': 'د نرخونو ترلاسه کول ناکام شول',
    'dark': 'تیاره بڼه',
    'about': 'د اپ جوړوونکی',
    'retry': 'بیا هڅه',
    'result': 'د تبدیل نتیجه',
  },
  'dr': {
    'title': 'افغانی اکسچنج',
    'converter': 'تبدیل اسعار',
    'amount': 'مقدار را وارد کنید',
    'from': 'از اسعار',
    'to': 'به اسعار',
    'swap': 'تعویض اسعار',
    'favorites': 'علاقه‌مندی‌ها',
    'history': 'تاریخچه تبدیل',
    'search': 'جستجوی اسعار',
    'refresh': 'تازه‌سازی نرخ‌ها',
    'updated': 'آخرین به‌روزرسانی',
    'loading': 'نرخ‌ها دریافت می‌شوند...',
    'error': 'دریافت نرخ‌ها ناکام شد',
    'dark': 'حالت تاریک',
    'about': 'سازنده برنامه',
    'retry': 'تلاش دوباره',
    'result': 'نتیجه تبدیل',
  },
  'en': {
    'title': 'Afghani Exchange',
    'converter': 'Currency Converter',
    'amount': 'Enter amount',
    'from': 'From currency',
    'to': 'To currency',
    'swap': 'Swap currencies',
    'favorites': 'Favorites',
    'history': 'Conversion History',
    'search': 'Search currencies',
    'refresh': 'Refresh rates',
    'updated': 'Last updated',
    'loading': 'Loading exchange rates...',
    'error': 'Could not load exchange rates',
    'dark': 'Dark mode',
    'about': 'Created by',
    'retry': 'Try again',
    'result': 'Conversion result',
  },
};

class AfghaniExchangeApp extends StatefulWidget {
  const AfghaniExchangeApp({super.key});

  @override
  State<AfghaniExchangeApp> createState() =>
      _AfghaniExchangeAppState();
}

class _AfghaniExchangeAppState
    extends State<AfghaniExchangeApp> {
  bool dark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afghani Exchange',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF087F5B),
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F7F5),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF19A77A),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: ExchangeHome(
        dark: dark,
        onDarkChanged: (v) => setState(() => dark = v),
      ),
    );
  }
}

class ExchangeHome extends StatefulWidget {
  final bool dark;
  final ValueChanged<bool> onDarkChanged;

  const ExchangeHome({
    super.key,
    required this.dark,
    required this.onDarkChanged,
  });

  @override
  State<ExchangeHome> createState() => _ExchangeHomeState();
}

class _ExchangeHomeState extends State<ExchangeHome> {
  final amountController = TextEditingController(text: '1000');

  String language = 'ps';
  String from = 'AFN';
  String to = 'USD';

  Map<String, double> rates = {'AFN': 1};
  List<String> currencies = currencyNames.keys.toList();
  List<String> favorites = ['USD', 'PKR', 'EUR'];
  List<String> history = [];

  bool loading = false;
  String? error;
  DateTime? lastUpdated;
  Timer? timer;

  String get resultText =>
      words[language]!['result']!;

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

  String tr(String key) => words[language]![key] ?? key;

  Future<void> loadRates() async {
    if (loading) return;

    setState(() {
      loading = true;
      error = null;
    });

    HttpClient? client;

    try {
      client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 15);

      final request = await client.getUrl(
        Uri.parse('$apiUrl?base=AFN'),
      );

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      final data = jsonDecode(body) as Map<String, dynamic>;

      if (response.statusCode != 200 ||
          data['success'] == false ||
          data['error'] != null) {
        throw Exception(data['error'] ?? 'API error');
      }

      final raw = data['rates'] ?? data['results'];

      if (raw is! Map) {
        throw Exception('Rates are missing');
      }

      final parsed = <String, double>{'AFN': 1};

      for (final entry in raw.entries) {
        final value = entry.value;
        if (value is num && value > 0) {
          parsed[entry.key.toString().toUpperCase()] =
              value.toDouble();
        }
      }

      if (parsed.length < 2) {
        throw Exception('No currency rates');
      }

      if (!mounted) return;

      setState(() {
        rates = parsed;
        currencies = {
          ...currencyNames.keys,
          ...parsed.keys,
        }.toList()
          ..sort();

        lastUpdated = DateTime.now();
        error = null;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          error = tr('error');
        });
      }
    } finally {
      client?.close(force: true);
      if (mounted) setState(() => loading = false);
    }
  }

  double get converted {
    final amount = double.tryParse(amountController.text) ?? 0;
    final fromRate = rates[from];
    final toRate = rates[to];

    if (fromRate == null || toRate == null || fromRate == 0) {
      return 0;
    }

    return amount / fromRate * toRate;
  }

  String currencyLabel(String code) =>
      '$code  •  ${currencyNames[code] ?? code}';

  void swap() {
    setState(() {
      final oldFrom = from;
      from = to;
      to = oldFrom;
    });
  }

  void saveHistory() {
    final amount = amountController.text.trim();
    final entry =
        '$amount $from → ${converted.toStringAsFixed(2)} $to';

    setState(() {
      history.remove(entry);
      history.insert(0, entry);
      if (history.length > 20) history.removeLast();
    });
  }

  Future<void> chooseCurrency(bool isFrom) async {
    final searchController = TextEditingController();

    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, updateDialog) {
            final query = searchController.text.toLowerCase();
            final filtered = currencies.where((code) {
              final name = currencyNames[code] ?? code;
              return code.toLowerCase().contains(query) ||
                  name.toLowerCase().contains(query);
            }).toList();

            return AlertDialog(
              title: Text(tr('search')),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      controller: searchController,
                      onChanged: (_) => updateDialog(() {}),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'AFN, USD, EUR...',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (_, index) {
                          final code = filtered[index];
                          return ListTile(
                            title: Text(code),
                            subtitle: Text(
                              currencyNames[code] ?? code,
                            ),
                            onTap: () =>
                                Navigator.pop(context, code),
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

    searchController.dispose();

    if (selected != null && mounted) {
      setState(() {
        if (isFrom) {
          from = selected;
        } else {
          to = selected;
        }
      });
    }
  }

  Widget currencyButton(String code, bool isFrom) {
    return InkWell(
      onTap: () => chooseCurrency(isFrom),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withOpacity(.45),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 19,
              child: Text(code.substring(0, 2)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    code,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    currencyNames[code] ?? code,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('🇦🇫'),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                tr('title'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          DropdownButton<String>(
            value: language,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'ps', child: Text('پښتو')),
              DropdownMenuItem(value: 'dr', child: Text('دری')),
              DropdownMenuItem(value: 'en', child: Text('EN')),
            ],
            onChanged: (v) {
              if (v != null) setState(() => language = v);
            },
          ),
          IconButton(
            tooltip: tr('dark'),
            icon: Icon(
              widget.dark ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () => widget.onDarkChanged(!widget.dark),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadRates,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF075E46),
                    Color(0xFF11A579),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF087F5B).withOpacity(.22),
                    blurRadius: 20,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('converter'),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: tr('amount'),
                      hintStyle:
                          const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(.12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  currencyButton(from, true),
                  Align(
                    alignment: Alignment.center,
                    child: IconButton.filled(
                      onPressed: swap,
                      icon: const Icon(Icons.swap_vert),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF087F5B),
                      ),
                    ),
                  ),
                  currencyButton(to, false),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resultText,
                          style: const TextStyle(
                            color: Color(0xFF65736D),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${converted.toStringAsFixed(2)} $to',
                          style: const TextStyle(
                            color: Color(0xFF075E46),
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: saveHistory,
                            icon: const Icon(Icons.history),
                            label: Text(tr('history')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          error == null
                              ? Icons.check_circle_outline
                              : Icons.error_outline,
                        ),
                ),
                title: Text(
                  error ?? (loading ? tr('loading') : tr('updated')),
                ),
                subtitle: Text(
                  lastUpdated == null
                      ? '—'
                      : lastUpdated!.toLocal().toString().substring(0, 16),
                ),
                trailing: IconButton(
                  tooltip: tr('refresh'),
                  onPressed: loading ? null : loadRates,
                  icon: const Icon(Icons.refresh),
                ),
              ),
            ),

            if (error != null)
              Card(
                child: ListTile(
                  title: Text(error!),
                  trailing: TextButton(
                    onPressed: loadRates,
                    child: Text(tr('retry')),
                  ),
                ),
              ),

            sectionTitle(tr('favorites'), Icons.star),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: favorites.map((code) {
                return ActionChip(
                  avatar: const Icon(Icons.star, size: 16),
                  label: Text(code),
                  onPressed: () {
                    setState(() => to = code);
                  },
                  onDeleted: code == 'USD'
                      ? null
                      : () => setState(() => favorites.remove(code)),
                );
              }).toList(),
            ),

            Wrap(
              spacing: 8,
              children: currencies
                  .where((code) => !favorites.contains(code))
                  .take(20)
                  .map(
                    (code) => ActionChip(
                      label: Text(code),
                      onPressed: () {
                        setState(() {
                          to = code;
                          if (!favorites.contains(code)) {
                            favorites.add(code);
                          }
                        });
                      },
                    ),
                  )
                  .toList(),
            ),

            sectionTitle(tr('history'), Icons.history),
            if (history.isEmpty)
              const Text('—')
            else
              ...history.map(
                (item) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.swap_horiz),
                    title: Text(item),
                  ),
                ),
              ),

            const SizedBox(height: 25),
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.currency_exchange,
                    size: 34,
                    color: Color(0xFF087F5B),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Afghani Exchange',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${tr('about')}: Abdullah ALOKOZAI',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
