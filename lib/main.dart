import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

void main() {
  runApp(const AfghaniExchangeApp());
}

const apiUrl =
    'https://afghani-exchange-api.abdullah-alingari.workers.dev';

const currencies = <String, String>{
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
  'IRR': 'Iranian Rial',
  'CAD': 'Canadian Dollar',
  'AUD': 'Australian Dollar',
  'CHF': 'Swiss Franc',
  'JPY': 'Japanese Yen',
  'KWD': 'Kuwaiti Dinar',
  'QAR': 'Qatari Riyal',
  'BDT': 'Bangladeshi Taka',
  'NPR': 'Nepalese Rupee',
  'LKR': 'Sri Lankan Rupee',
  'MYR': 'Malaysian Ringgit',
  'SGD': 'Singapore Dollar',
  'THB': 'Thai Baht',
  'RUB': 'Russian Ruble',
  'SEK': 'Swedish Krona',
  'NOK': 'Norwegian Krone',
  'DKK': 'Danish Krone',
  'NZD': 'New Zealand Dollar',
  'HKD': 'Hong Kong Dollar',
  'ZAR': 'South African Rand',
  'EGP': 'Egyptian Pound',
  'IQD': 'Iraqi Dinar',
  'OMR': 'Omani Rial',
  'BHD': 'Bahraini Dinar',
  'JOD': 'Jordanian Dinar',
  'KRW': 'South Korean Won',
  'IDR': 'Indonesian Rupiah',
  'VND': 'Vietnamese Dong',
  'BRL': 'Brazilian Real',
  'MXN': 'Mexican Peso',
  'PLN': 'Polish Zloty',
  'CZK': 'Czech Koruna',
  'HUF': 'Hungarian Forint',
  'ILS': 'Israeli Shekel',
  'UAH': 'Ukrainian Hryvnia',
  'KES': 'Kenyan Shilling',
  'NGN': 'Nigerian Naira',
  'GEL': 'Georgian Lari',
  'UZS': 'Uzbekistani Som',
  'KZT': 'Kazakhstani Tenge',
};

class AfghaniExchangeApp extends StatefulWidget {
  const AfghaniExchangeApp({super.key});

  @override
  State<AfghaniExchangeApp> createState() =>
      _AfghaniExchangeAppState();
}

class _AfghaniExchangeAppState extends State<AfghaniExchangeApp> {
  bool dark = false;
  String language = 'ps';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afghani Exchange',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF087F68),
          brightness: dark ? Brightness.dark : Brightness.light,
        ),
        scaffoldBackgroundColor:
            dark ? const Color(0xFF101B1A) : const Color(0xFFF2F7F5),
      ),
      home: ExchangeHome(
        dark: dark,
        language: language,
        onDark: (v) => setState(() => dark = v),
        onLanguage: (v) => setState(() => language = v),
      ),
    );
  }
}

class ExchangeHome extends StatefulWidget {
  final bool dark;
  final String language;
  final ValueChanged<bool> onDark;
  final ValueChanged<String> onLanguage;

  const ExchangeHome({
    super.key,
    required this.dark,
    required this.language,
    required this.onDark,
    required this.onLanguage,
  });

  @override
  State<ExchangeHome> createState() => _ExchangeHomeState();
}

class _ExchangeHomeState extends State<ExchangeHome> {
  final amountController = TextEditingController(text: '1000');

  String from = 'AFN';
  String to = 'USD';
  String message = '';
  bool loading = false;

  Map<String, double> rates = {'AFN': 1};
  Set<String> favorites = {'USD', 'EUR', 'PKR'};
  List<String> history = [];
  DateTime? updated;
  Timer? timer;

  String tr(String ps, String fa, String en) {
    if (widget.language == 'ps') return ps;
    if (widget.language == 'fa') return fa;
    return en;
  }

  @override
  void initState() {
    super.initState();
    fetchRates();
    timer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => fetchRates(),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    amountController.dispose();
    super.dispose();
  }

  Future<void> fetchRates() async {
    if (loading) return;

    setState(() {
      loading = true;
      message = '';
    });

    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);

    try {
      final uri = Uri.parse(apiUrl).replace(
        queryParameters: {'base': 'AFN'},
      );

      final request = await client.getUrl(uri);
      request.headers.set('Accept', 'application/json');

      final response = await request.close().timeout(
        const Duration(seconds: 20),
      );

      final body = await response
          .transform(utf8.decoder)
          .join();

      final decoded = jsonDecode(body);

      if (response.statusCode != 200) {
        throw Exception(
          'HTTP ${response.statusCode}: ${decoded is Map ? decoded['error'] ?? decoded['message'] ?? 'API error' : 'API error'}',
        );
      }

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid API response');
      }

      if (decoded['success'] == false) {
        throw Exception(
          decoded['error']?.toString() ?? 'API request failed',
        );
      }

      final raw = decoded['rates'] ?? decoded['results'];

      if (raw is! Map) {
        throw Exception('No currency rates in API response');
      }

      final newRates = <String, double>{'AFN': 1};

      raw.forEach((key, value) {
        final rate = double.tryParse(value.toString());
        if (rate != null && rate > 0) {
          newRates[key.toString().toUpperCase()] = rate;
        }
      });

      if (newRates.length < 2) {
        throw Exception('No usable currency rates');
      }

      if (!mounted) return;

      setState(() {
        rates = newRates;
        updated = DateTime.now();
        message = '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        message = tr(
          'د نرخونو ترلاسه کولو ستونزه. انټرنېټ او API وګوره.',
          'مشکل در دریافت نرخ‌ها. اینترنت و API را بررسی کنید.',
          'Could not load rates. Check internet and API.',
        );
      });
    } finally {
      client.close(force: true);
      if (mounted) setState(() => loading = false);
    }
  }

  double get converted {
    final amount =
        double.tryParse(amountController.text.trim()) ?? 0;
    final fromRate = rates[from];
    final toRate = rates[to];

    if (fromRate == null || toRate == null || fromRate == 0) {
      return 0;
    }

    return amount / fromRate * toRate;
  }

  String money(double value) {
    if (!value.isFinite) return '—';
    return value.toStringAsFixed(value.abs() >= 100 ? 2 : 4);
  }

  void swap() {
    setState(() {
      final oldFrom = from;
      from = to;
      to = oldFrom;
    });
  }

  Future<void> chooseCurrency(bool isFrom) async {
    final search = TextEditingController();
    String query = '';

    final selected = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final options = currencies.keys.where((code) {
            return code.toLowerCase().contains(query.toLowerCase()) ||
                currencies[code]!.toLowerCase().contains(
                      query.toLowerCase(),
                    );
          }).toList()
            ..sort((a, b) {
              if (a == 'AFN') return -1;
              if (b == 'AFN') return 1;
              return a.compareTo(b);
            });

          return AlertDialog(
            title: Text(tr('اسعار انتخاب کړه', 'انتخاب ارز', 'Select currency')),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: Column(
                children: [
                  TextField(
                    controller: search,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: tr('لټون...', 'جستجو...', 'Search...'),
                    ),
                    onChanged: (v) =>
                        setDialogState(() => query = v),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: options.length,
                      itemBuilder: (context, i) {
                        final code = options[i];
                        return ListTile(
                          title: Text(code),
                          subtitle: Text(currencies[code]!),
                          trailing: rates.containsKey(code)
                              ? const Icon(Icons.check_circle_outline)
                              : null,
                          onTap: () => Navigator.pop(context, code),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    search.dispose();

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

  void saveHistory() {
    setState(() {
      history.insert(
        0,
        '${amountController.text} $from = ${money(converted)} $to',
      );
      if (history.length > 30) history.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final available = rates.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Afghani Exchange',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.translate),
            onSelected: widget.onLanguage,
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'ps', child: Text('پښتو')),
              PopupMenuItem(value: 'fa', child: Text('دری')),
              PopupMenuItem(value: 'en', child: Text('English')),
            ],
          ),
          IconButton(
            tooltip: 'Dark mode',
            icon: Icon(
              widget.dark ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () => widget.onDark(!widget.dark),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchRates,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF087F68), Color(0xFF18B99A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('🇦🇫', style: TextStyle(fontSize: 30)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Currency Converter',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    tr(
                      'خپل اسعار په اسانه بدل کړه',
                      'ارز خود را به آسانی تبدیل کنید',
                      'Convert currencies with ease',
                    ),
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    tr('مقدار', 'مقدار', 'Amount'),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: '1000',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: currencyButton(
                          code: from,
                          label: tr('له', 'از', 'From'),
                          onTap: () => chooseCurrency(true),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: IconButton.filled(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF087F68),
                          ),
                          onPressed: swap,
                          icon: const Icon(Icons.swap_horiz),
                        ),
                      ),
                      Expanded(
                        child: currencyButton(
                          code: to,
                          label: tr('ته', 'به', 'To'),
                          onTap: () => chooseCurrency(false),
                        ),
                      ),
                    ],
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
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('د تبدیل پایله', 'نتیجه تبدیل', 'Converted amount'),
                      style: TextStyle(color: color.onSurfaceVariant),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${money(converted)} $to',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: color.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      rates.containsKey(from) && rates.containsKey(to)
                          ? '1 $from = ${money((rates[to] ?? 0) / (rates[from] ?? 1))} $to'
                          : tr(
                              'د اسعارو نرخ نشته',
                              'نرخ ارز موجود نیست',
                              'Rate unavailable',
                            ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: rates.containsKey(from) &&
                                rates.containsKey(to)
                            ? saveHistory
                            : null,
                        icon: const Icon(Icons.save_alt),
                        label: Text(
                          tr('تاریخچه کې ثبت کړه', 'ثبت در تاریخچه', 'Save to history'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (message.isNotEmpty)
              Card(
                color: color.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    message,
                    style: TextStyle(color: color.onErrorContainer),
                  ),
                ),
              ),
            Card(
              elevation: 0,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.primaryContainer,
                  child: Icon(Icons.update, color: color.primary),
                ),
                title: Text(
                  tr('وروستی تازه کېدل', 'آخرین به‌روزرسانی', 'Last Updated'),
                ),
                subtitle: Text(
                  updated == null
                      ? tr('لا تر اوسه نه دی تازه شوی', 'هنوز به‌روز نشده', 'Not updated yet')
                      : updated!.toLocal().toString().substring(0, 19),
                ),
                trailing: IconButton(
                  onPressed: loading ? null : fetchRates,
                  icon: loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                ),
              ),
            ),
            const SizedBox(height: 10),
            sectionTitle(
              tr('⭐ خوښ اسعار', '⭐ ارزهای مورد علاقه', '⭐ Favorites'),
            ),
            if (favorites.isEmpty)
              const ListTile(title: Text('No favorites yet'))
            else
              ...favorites.map(
                (code) => currencyTile(code, available),
              ),
            Row(
              children: [
                Expanded(
                  child: sectionTitle(
                    tr('🌍 اسعار', '🌍 ارزها', '🌍 Currencies'),
                  ),
                ),
                Text('${available.length}'),
              ],
            ),
            ...available.take(100).map(
                  (code) => currencyTile(code, available),
                ),
            sectionTitle(
              tr('📜 د تبدیل تاریخچه', '📜 تاریخچه تبدیل', '📜 History'),
            ),
            if (history.isEmpty)
              ListTile(
                leading: const Icon(Icons.history),
                title: Text(
                  tr('تراوسه تاریخچه نشته', 'تاریخچه‌ای نیست', 'No history yet'),
                ),
              )
            else ...[
              ...history.map(
                (item) => ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: Text(item),
                ),
              ),
              TextButton.icon(
                onPressed: () => setState(() => history.clear()),
                icon: const Icon(Icons.delete_outline),
                label: Text(
                  tr('تاریخچه پاک کړه', 'پاک کردن تاریخچه', 'Clear history'),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Card(
              elevation: 0,
              child: const Padding(
                padding: EdgeInsets.all(22),
                child: Column(
                  children: [
                    Icon(Icons.account_circle, size: 42),
                    SizedBox(height: 8),
                    Text(
                      'Afghani Exchange',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text('Created by Abdullah ALOKOZAI'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Widget currencyButton({
    required String code,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white30),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 5),
            Text(
              code,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              currencies[code] ?? code,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget currencyTile(String code, List<String> available) {
    final isFavorite = favorites.contains(code);
    final hasRate = rates.containsKey(code);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(code.substring(0, code.length > 3 ? 3 : code.length)),
        ),
        title: Text(code, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          '${currencies[code] ?? code} • ${hasRate ? '1 AFN = ${money(rates[code]!)} $code' : 'Rate unavailable'}',
        ),
        trailing: IconButton(
          tooltip: 'Favorite',
          onPressed: () {
            setState(() {
              if (isFavorite) {
                favorites.remove(code);
              } else {
                favorites.add(code);
              }
            });
          },
          icon: Icon(
            isFavorite ? Icons.star : Icons.star_border,
            color: isFavorite ? Colors.amber : null,
          ),
        ),
      ),
    );
  }
}
