import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

void main() => runApp(const AfghaniExchangeApp());

const workerUrl =
    'https://afghani-exchange-api.abdullah-alingari.workers.dev';

class AfghaniExchangeApp extends StatefulWidget {
  const AfghaniExchangeApp({super.key});

  @override
  State<AfghaniExchangeApp> createState() =>
      _AfghaniExchangeAppState();
}

class _AfghaniExchangeAppState extends State<AfghaniExchangeApp> {
  bool dark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afghani Exchange',
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
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
          seedColor: const Color(0xFF20C997),
          brightness: Brightness.dark,
        ),
      ),
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
  final searchController = TextEditingController();

  Map<String, double> rates = {'AFN': 1};
  List<String> currencies = ['AFN', 'USD', 'EUR', 'PKR', 'INR'];
  final Set<String> favorites = {'USD', 'EUR'};
  final List<String> history = [];

  String from = 'AFN';
  String to = 'USD';
  String language = 'پښتو';
  String lastUpdated = '—';
  String error = '';
  bool loading = false;

  Timer? refreshTimer;

  String tr(String ps, String dr, String en) {
    if (language == 'دری') return dr;
    if (language == 'English') return en;
    return ps;
  }

  @override
  void initState() {
    super.initState();
    fetchRates();
    refreshTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => fetchRates(),
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    amountController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchRates() async {
    if (loading) return;

    setState(() {
      loading = true;
      error = '';
    });

    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);

    try {
      final uri = Uri.parse('$workerUrl?base=AFN');
      final request = await client.getUrl(uri);
      request.headers.set(
        HttpHeaders.acceptHeader,
        'application/json',
      );

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      final decoded = jsonDecode(body);

      if (response.statusCode != 200) {
        final message = decoded is Map
            ? (decoded['error'] ??
                decoded['message'] ??
                'HTTP ${response.statusCode}')
            : 'HTTP ${response.statusCode}';

        throw Exception('$message');
      }

      if (decoded is! Map) {
        throw Exception('Invalid response');
      }

      if (decoded['success'] == false) {
        final apiError = decoded['error'];
        final message = apiError is Map
            ? (apiError['message'] ?? 'API error')
            : 'API error';
        throw Exception('$message');
      }

      final raw = decoded['rates'] ?? decoded['results'];

      if (raw is! Map || raw.isEmpty) {
        throw Exception('No currency rates returned');
      }

      final parsed = <String, double>{'AFN': 1};

      for (final entry in raw.entries) {
        final value = entry.value;
        final number = value is num
            ? value.toDouble()
            : double.tryParse('$value');

        if (number != null && number > 0 && number.isFinite) {
          parsed[entry.key.toString().toUpperCase()] = number;
        }
      }

      if (parsed.length < 2) {
        throw Exception('No usable rates returned');
      }

      if (!mounted) return;

      setState(() {
        rates = parsed;
        currencies = parsed.keys.toList()..sort();

        if (!currencies.contains(from)) from = 'AFN';
        if (!currencies.contains(to)) {
          to = currencies.contains('USD') ? 'USD' : currencies.last;
        }

        final date = decoded['date'] ??
            decoded['updated'] ??
            decoded['timestamp'];

        lastUpdated = date?.toString() ?? DateTime.now().toUtc().toIso8601String();
        error = '';
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      client.close(force: true);
      if (mounted) setState(() => loading = false);
    }
  }

  double get converted {
    final amount = double.tryParse(
          amountController.text.trim().replaceAll(',', ''),
        ) ??
        0;

    final fromRate = rates[from];
    final toRate = rates[to];

    if (fromRate == null || toRate == null || fromRate == 0) {
      return 0;
    }

    return (amount / fromRate) * toRate;
  }

  String formatAmount(double value) {
    if (!value.isFinite) return '—';
    return value.toStringAsFixed(value.abs() >= 100 ? 2 : 4);
  }

  void swap() {
    setState(() {
      final previous = from;
      from = to;
      to = previous;
    });
  }

  void saveHistory() {
    final entry =
        '${amountController.text} $from → ${formatAmount(converted)} $to';

    setState(() {
      history.insert(0, entry);
      if (history.length > 30) history.removeLast();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tr('تبدیل ثبت شو', 'تبدیل ثبت شد', 'Conversion saved'))),
    );
  }

  void showCurrencies(bool choosingFrom) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        String query = '';

        return StatefulBuilder(
          builder: (context, setSheetState) {
            final list = currencies.where((code) {
              final matchesSearch =
                  code.toLowerCase().contains(query.toLowerCase());
              final matchesFavorite =
                  favorites.contains(code) || query.isNotEmpty;
              return matchesSearch && matchesFavorite;
            }).toList();

            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: tr('اسعار ولټوه', 'جستجوی ارز', 'Search currencies'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onChanged: (value) =>
                            setSheetState(() => query = value),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final code = list[index];

                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(code.substring(0, 1)),
                            ),
                            title: Text(code),
                            subtitle: Text(
                              '1 AFN = ${formatAmount(rates[code] ?? 0)} $code',
                            ),
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
                            onTap: () {
                              setState(() {
                                if (choosingFrom) {
                                  from = code;
                                } else {
                                  to = code;
                                }
                              });
                              Navigator.pop(sheetContext);
                            },
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
  }

  Widget currencySelector(String code, bool choosingFrom) {
    return InkWell(
      onTap: () => showCurrencies(choosingFrom),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(code, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }

  Widget rateCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('زه لرم', 'من دارم', 'You send'),
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '0',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                currencySelector(from, true),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: IconButton.filledTonal(
                onPressed: swap,
                icon: const Icon(Icons.swap_vert, size: 28),
                tooltip: tr('اسعار بدل کړه', 'تعویض ارز', 'Swap currencies'),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              tr('ته ترلاسه کوې', 'شما دریافت می‌کنید', 'You receive'),
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      formatAmount(converted),
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                currencySelector(to, false),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: saveHistory,
                icon: const Icon(Icons.bookmark_add_outlined),
                label: Text(
                  tr('تبدیل ثبت کړه', 'ذخیره تبدیل', 'Save conversion'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredFavorites = favorites.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🇦🇫 Afghani Exchange',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.translate),
            onSelected: (value) => setState(() => language = value),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'پښتو', child: Text('پښتو')),
              PopupMenuItem(value: 'دری', child: Text('دری')),
              PopupMenuItem(value: 'English', child: Text('English')),
            ],
          ),
          IconButton(
            tooltip: 'Dark mode',
            onPressed: () => widget.onDarkChanged(!widget.dark),
            icon: Icon(
              widget.dark ? Icons.light_mode : Icons.dark_mode,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchRates,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF087F5B), Color(0xFF20C997)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.currency_exchange,
                    color: Colors.white,
                    size: 42,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('د نړۍ اسعار', 'ارزهای جهان', 'World currencies'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          tr('چټک او اسانه تبدیل', 'تبدیل سریع و آسان', 'Fast and simple conversion'),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: fetchRates,
                    color: Colors.white,
                    icon: loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (error.isNotEmpty)
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr('د نرخونو ستونزه', 'مشکل نرخ‌ها', 'Rate loading problem'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(error),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: fetchRates,
                        icon: const Icon(Icons.refresh),
                        label: Text(
                          tr('بیا هڅه وکړه', 'دوباره تلاش کنید', 'Try again'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            rateCard(),
            const SizedBox(height: 18),
            Card(
              elevation: 0,
              child: ListTile(
                leading: const Icon(Icons.schedule),
                title: Text(
                  tr('وروستی تازه کېدل', 'آخرین به‌روزرسانی', 'Last updated'),
                ),
                subtitle: Text(lastUpdated),
                trailing: Text('${currencies.length}'),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              tr('⭐ خوښې اسعار', '⭐ ارزهای مورد علاقه', '⭐ Favorites'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Wrap(
              spacing: 8,
              children: filteredFavorites.map((code) {
                return ActionChip(
                  avatar: const Icon(Icons.star, size: 16),
                  label: Text(code),
                  onPressed: () => setState(() => to = code),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    tr('📜 د تبدیل تاریخچه', '📜 تاریخچه تبدیل', '📜 History'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => history.clear()),
                  child: Text(tr('پاکول', 'پاک کردن', 'Clear')),
                ),
              ],
            ),
            if (history.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  tr('تر اوسه تاریخچه نشته', 'هنوز تاریخچه‌ای نیست', 'No history yet'),
                ),
              )
            else
              ...history.map(
                (entry) => Card(
                  elevation: 0,
                  child: ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(entry),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            const Center(
              child: Column(
                children: [
                  Icon(Icons.public, size: 26),
                  SizedBox(height: 6),
                  Text(
                    'Abdullah ALOKOZAI',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Afghani Exchange'),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
