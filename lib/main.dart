import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

void main() => runApp(const AfghaniExchange());

class AfghaniExchange extends StatelessWidget {
  const AfghaniExchange({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afghani Exchange',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF087F68)),
        scaffoldBackgroundColor: const Color(0xFFF3F7F6),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF25B99A),
          brightness: Brightness.dark,
        ),
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
  static const api =
      'https://afghani-exchange-api.abdullah-alingari.workers.dev';

  final amountController = TextEditingController(text: '1000');

  final currencies = <String>[
    'AFN','USD','EUR','GBP','PKR','INR','AED','SAR','CNY','TRY',
    'JPY','CAD','AUD','CHF','KWD','QAR','OMR','BHD','BDT','LKR',
    'NPR','IRR','IQD','RUB','SGD','MYR','IDR','THB','KRW','HKD',
    'NZD','ZAR','SEK','NOK','DKK','PLN','CZK','HUF','EGP','NGN',
    'KES','GHS','MAD','TND','BRL','MXN','ARS','CLP','COP','VND',
    'PHP','TWD','UAH','ILS','JOD','LBP','ETB','TZS','UGX','XOF',
    'XAF','DZD','LYD','SDG','YER','MVR','MNT','KZT','UZS','GEL',
    'AMD','AZN','BYN','RON','BGN','HRK','ISK','ALL','MKD','RSD',
    'BND','KHR','LAK','MMK','MOP','FJD','PGK','WST','TOP','VUV',
    'XPF','BOB','PEN','PYG','UYU','DOP','CRC','GTQ','HNL','JMD'
  ];

  Map<String, double> rates = {'AFN': 1};
  String from = 'AFN';
  String to = 'USD';
  String language = 'ps';
  String error = '';
  String updated = '';
  bool loading = false;
  bool dark = false;

  final favorites = <String>{'USD', 'EUR', 'PKR'};
  final history = <String>[];
  Timer? timer;

  final labels = {
    'ps': {
      'title': 'افغاني اېکسچېنج',
      'convert': 'د اسعارو تبدیل',
      'amount': 'مقدار',
      'from': 'له دې اسعارو',
      'to': 'دې اسعارو ته',
      'favorites': 'خوښې شوې',
      'history': 'تاریخچه',
      'refresh': 'نرخونه تازه کړه',
      'search': 'اسعار ولټوه',
      'updated': 'وروستی تازه کېدل',
      'about': 'جوړوونکی',
      'error': 'د نرخونو په ترلاسه کولو کې ستونزه',
    },
    'fa': {
      'title': 'افغانی اکسچنج',
      'convert': 'تبدیل ارز',
      'amount': 'مقدار',
      'from': 'از ارز',
      'to': 'به ارز',
      'favorites': 'علاقه‌مندی‌ها',
      'history': 'تاریخچه',
      'refresh': 'تازه‌سازی نرخ‌ها',
      'search': 'جستجوی ارز',
      'updated': 'آخرین به‌روزرسانی',
      'about': 'سازنده',
      'error': 'دریافت نرخ‌ها مشکل دارد',
    },
    'en': {
      'title': 'Afghani Exchange',
      'convert': 'Currency Converter',
      'amount': 'Amount',
      'from': 'From',
      'to': 'To',
      'favorites': 'Favorites',
      'history': 'History',
      'refresh': 'Refresh rates',
      'search': 'Search currencies',
      'updated': 'Last updated',
      'about': 'Created by',
      'error': 'Could not get exchange rates',
    },
  };

  String tr(String key) => labels[language]![key] ?? key;

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

  Future<void> loadRates() async {
    if (loading) return;
    setState(() {
      loading = true;
      error = '';
    });

    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse('$api?base=AFN'));
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final data = jsonDecode(body) as Map<String, dynamic>;
      final raw = data['rates'] ?? data['results'];

      if (raw is! Map) throw Exception('Invalid rates response');

      final parsed = <String, double>{'AFN': 1};
      raw.forEach((key, value) {
        final number = value is num ? value.toDouble() : double.tryParse('$value');
        if (number != null && number > 0) {
          parsed[key.toString().toUpperCase()] = number;
        }
      });

      if (parsed.length < 2) throw Exception('No currencies received');

      if (!mounted) return;
      setState(() {
        rates = parsed;
        updated = DateTime.now().toLocal().toString().substring(0, 16);
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          error = '${tr('error')} — API/Worker وګوره';
        });
      }
    } finally {
      client.close(force: true);
      if (mounted) setState(() => loading = false);
    }
  }

  double get converted {
    final amount = double.tryParse(amountController.text) ?? 0;
    final fromRate = rates[from];
    final toRate = rates[to];
    if (fromRate == null || toRate == null || fromRate == 0) return 0;
    return amount / fromRate * toRate;
  }

  void swap() {
    setState(() {
      final old = from;
      from = to;
      to = old;
    });
  }

  void saveHistory() {
    final item =
        '${amountController.text} $from = ${converted.toStringAsFixed(4)} $to';
    setState(() {
      history.insert(0, item);
      if (history.length > 50) history.removeLast();
    });
  }

  Future<void> chooseCurrency(bool isFrom) async {
    final searchController = TextEditingController();
    String query = '';

    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final available = currencies
              .where((c) => rates.containsKey(c))
              .where((c) => c.toLowerCase().contains(query.toLowerCase()))
              .toList();

          return SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * .75,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: tr('search'),
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onChanged: (value) =>
                          setSheetState(() => query = value),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        for (final code in available)
                          ListTile(
                            leading: CircleAvatar(
                              child: Text(code.substring(0, 2)),
                            ),
                            title: Text(code),
                            trailing: IconButton(
                              icon: Icon(
                                favorites.contains(code)
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (!favorites.add(code)) {
                                    favorites.remove(code);
                                  }
                                });
                                setSheetState(() {});
                              },
                            ),
                            onTap: () => Navigator.pop(context, code),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    if (selected != null) {
      setState(() {
        if (isFrom) {
          from = selected;
        } else {
          to = selected;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('title'), style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (value) => setState(() => language = value),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'ps', child: Text('پښتو')),
              PopupMenuItem(value: 'fa', child: Text('دری')),
              PopupMenuItem(value: 'en', child: Text('English')),
            ],
          ),
          IconButton(
            icon: Icon(dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => setState(() => dark = !dark),
          ),
        ],
      ),
      body: Theme(
        data: dark
            ? ThemeData.dark(useMaterial3: true)
            : Theme.of(context),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF087F68), Color(0xFF20B69A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.currency_exchange,
                      color: Colors.white, size: 36),
                  const SizedBox(height: 12),
                  Text(
                    tr('convert'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${rates.length} currencies available',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(tr('amount')),
                    const SizedBox(height: 8),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: '1000',
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    Text(tr('from')),
                    const SizedBox(height: 6),
                    OutlinedButton(
                      onPressed: () => chooseCurrency(true),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Text('🇦🇫  '),
                            Text(from, style: const TextStyle(fontSize: 18)),
                            const Spacer(),
                            const Icon(Icons.keyboard_arrow_down),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: IconButton.filled(
                        onPressed: swap,
                        icon: const Icon(Icons.swap_vert),
                        tooltip: 'Swap',
                      ),
                    ),
                    Text(tr('to')),
                    const SizedBox(height: 6),
                    OutlinedButton(
                      onPressed: () => chooseCurrency(false),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Text(to, style: const TextStyle(fontSize: 18)),
                            const Spacer(),
                            const Icon(Icons.keyboard_arrow_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tr('convert')),
                          const SizedBox(height: 8),
                          Text(
                            '${converted.toStringAsFixed(4)} $to',
                            style: TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                              color: cs.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: saveHistory,
                      icon: const Icon(Icons.history),
                      label: Text(tr('history')),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.star, color: Colors.amber),
                    title: Text(tr('favorites')),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final code in favorites)
                        if (rates.containsKey(code))
                          ActionChip(
                            label: Text(code),
                            onPressed: () => setState(() => to = code),
                          ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            Card(
              elevation: 0,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.update),
                    title: Text(tr('updated')),
                    subtitle: Text(updated.isEmpty ? '—' : updated),
                    trailing: IconButton(
                      onPressed: loadRates,
                      icon: loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh),
                    ),
                  ),
                  if (error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(error, style: const TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            ),
            Card(
              elevation: 0,
              child: ExpansionTile(
                leading: const Icon(Icons.history),
                title: Text(tr('history')),
                children: [
                  if (history.isEmpty)
                    const ListTile(title: Text('No history yet'))
                  else
                    for (final item in history)
                      ListTile(
                        dense: true,
                        title: Text(item),
                      ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  const Icon(Icons.public, size: 28),
                  const SizedBox(height: 6),
                  Text(tr('about')),
                  const Text(
                    'Abdullah ALOKOZAI',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
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
