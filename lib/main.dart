import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const AfghaniExchangeApp());
}

const Color bg = Color(0xFF031329);
const Color panel = Color(0xFF08264A);
const Color blue = Color(0xFF087BFF);
const Color cyan = Color(0xFF08D9D0);

class Currency {
  final String code;
  final String name;
  final String flag;

  const Currency(this.code, this.name, this.flag);
}

const List<Currency> currencies = [
  Currency('AFN', 'Afghan Afghani', '🇦🇫'),
  Currency('USD', 'US Dollar', '🇺🇸'),
  Currency('EUR', 'Euro', '🇪🇺'),
  Currency('GBP', 'British Pound', '🇬🇧'),
  Currency('PKR', 'Pakistani Rupee', '🇵🇰'),
  Currency('INR', 'Indian Rupee', '🇮🇳'),
  Currency('AED', 'UAE Dirham', '🇦🇪'),
  Currency('SAR', 'Saudi Riyal', '🇸🇦'),
  Currency('IRR', 'Iranian Rial', '🇮🇷'),
  Currency('TRY', 'Turkish Lira', '🇹🇷'),
  Currency('CNY', 'Chinese Yuan', '🇨🇳'),
  Currency('CAD', 'Canadian Dollar', '🇨🇦'),
  Currency('AUD', 'Australian Dollar', '🇦🇺'),
  Currency('JPY', 'Japanese Yen', '🇯🇵'),
  Currency('QAR', 'Qatari Riyal', '🇶🇦'),
  Currency('CHF', 'Swiss Franc', '🇨🇭'),
  Currency('KWD', 'Kuwaiti Dinar', '🇰🇼'),
  Currency('BDT', 'Bangladeshi Taka', '🇧🇩'),
  Currency('NPR', 'Nepalese Rupee', '🇳🇵'),
  Currency('RUB', 'Russian Ruble', '🇷🇺'),
  Currency('MYR', 'Malaysian Ringgit', '🇲🇾'),
  Currency('SGD', 'Singapore Dollar', '🇸🇬'),
  Currency('NZD', 'New Zealand Dollar', '🇳🇿'),
  Currency('ZAR', 'South African Rand', '🇿🇦'),
  Currency('EGP', 'Egyptian Pound', '🇪🇬'),
  Currency('IQD', 'Iraqi Dinar', '🇮🇶'),
  Currency('OMR', 'Omani Rial', '🇴🇲'),
  Currency('BHD', 'Bahraini Dinar', '🇧🇭'),
  Currency('JOD', 'Jordanian Dinar', '🇯🇴'),
  Currency('BRL', 'Brazilian Real', '🇧🇷'),
  Currency('MXN', 'Mexican Peso', '🇲🇽'),
  Currency('THB', 'Thai Baht', '🇹🇭'),
  Currency('IDR', 'Indonesian Rupiah', '🇮🇩'),
  Currency('KRW', 'South Korean Won', '🇰🇷'),
  Currency('HKD', 'Hong Kong Dollar', '🇭🇰'),
];

class AfghaniExchangeApp extends StatelessWidget {
  const AfghaniExchangeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afghani Exchange',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: blue,
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
  Currency from = currencies[0];
  Currency to = currencies[1];

  final amountController = TextEditingController(text: '1000');
  final searchController = TextEditingController();

  Map<String, double> rates = {};
  bool loading = false;
  String? errorMessage;
  String lastUpdated = '';

  int bottomIndex = 0;
  String search = '';

  final Set<String> favorites = {'USD', 'EUR', 'PKR'};
  final List<String> history = [];

  double get amount =>
      double.tryParse(amountController.text.trim()) ?? 0;

  bool get hasBothRates =>
      rates.containsKey(from.code) &&
      rates.containsKey(to.code) &&
      rates[from.code]! > 0;

  double get result {
    if (!hasBothRates) return 0;
    return amount / rates[from.code]! * rates[to.code]!;
  }

  @override
  void initState() {
    super.initState();
    fetchRates();
  }

  @override
  void dispose() {
    amountController.dispose();
    searchController.dispose();
    super.dispose();
  }

  String format(double value) {
    if (value != 0 && value.abs() < 0.01) {
      return value.toStringAsPrecision(5);
    }
    return value.toStringAsFixed(2);
  }

  Future<void> fetchRates() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final response = await http
          .get(
            Uri.parse('https://open.er-api.com/v6/latest/USD'),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception('د نرخونو سرور ځواب ورنه کړ.');
      }

      final data = jsonDecode(response.body)
          as Map<String, dynamic>;

      if (data['result'] != 'success' ||
          data['rates'] is! Map) {
        throw Exception('د نرخونو معلومات سم نه دي.');
      }

      final rawRates = data['rates'] as Map;
      final newRates = <String, double>{};

      for (final currency in currencies) {
        final value = rawRates[currency.code];

        if (value is num && value > 0) {
          newRates[currency.code] = value.toDouble();
        }
      }

      if (!newRates.containsKey('USD')) {
        throw Exception('د ډالر نرخ ترلاسه نه شو.');
      }

      if (!mounted) return;

      setState(() {
        rates = newRates;
        lastUpdated = data['time_last_update_utc']?.toString()
                ?? 'نامعلوم';
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage =
            'د نرخونو ترلاسه کول ناکام شول. انټرنېټ وګوره او بیا هڅه وکړه.';
      });
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  void swapCurrencies() {
    setState(() {
      final old = from;
      from = to;
      to = old;
    });
  }

  void saveHistory() {
    if (!hasBothRates) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لومړی د اسعارو نرخونه تازه کړه.'),
        ),
      );
      return;
    }

    setState(() {
      history.insert(
        0,
        '${format(amount)} ${from.code} = '
        '${format(result)} ${to.code}',
      );
      bottomIndex = 0;
    });
  }

  void openCurrencyPicker({required bool isFrom}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: panel,
      builder: (sheetContext) {
        String query = '';

        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = currencies.where((c) {
              return c.code.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                  c.name.toLowerCase().contains(
                        query.toLowerCase(),
                      );
            }).toList();

            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(18),
                      child: Text(
                        'اسعار وټاکئ / Select Currency',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: TextField(
                        onChanged: (v) {
                          setModalState(() => query = v);
                        },
                        decoration: InputDecoration(
                          hintText: 'د اسعارو لټون...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: bg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final c = filtered[index];
                          final rate = rates[c.code];

                          return ListTile(
                            leading: Text(
                              c.flag,
                              style: const TextStyle(fontSize: 28),
                            ),
                            title: Text('${c.code} - ${c.name}'),
                            subtitle: Text(
                              rate == null
                                  ? 'نرخ موجود نه دی'
                                  : '۱ USD = ${format(rate)} ${c.code}',
                            ),
                            onTap: () {
                              Navigator.pop(sheetContext);
                              setState(() {
                                if (isFrom) {
                                  from = c;
                                } else {
                                  to = c;
                                }
                              });
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

  Widget currencyCard({
    required String title,
    required Currency currency,
    required bool isFrom,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => openCurrencyPicker(isFrom: isFrom),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Text(currency.flag,
                      style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${currency.code} - ${currency.name}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down),
                ],
              ),
            ),
          ),
          const Divider(color: Colors.white12),
          child,
        ],
      ),
    );
  }

  Widget homePage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0752A4), Color(0xFF087E80)],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.currency_exchange, size: 38),
              SizedBox(height: 12),
              Text(
                'Afghani Exchange',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text('د اسعارو نرخونه او تبادله'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: panel,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(
                loading ? Icons.sync : Icons.cloud_done,
                color: cyan,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  loading
                      ? 'د نرخونو تازه کول...'
                      : errorMessage ??
                          (lastUpdated.isEmpty
                              ? 'د نرخونو چمتووالی'
                              : 'وروستی تازه کول: $lastUpdated'),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              IconButton(
                onPressed: loading ? null : fetchRates,
                icon: const Icon(Icons.refresh, color: cyan),
              ),
            ],
          ),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 10),
          Text(
            errorMessage!,
            style: const TextStyle(color: Colors.orangeAccent),
          ),
        ],
        const SizedBox(height: 18),
        currencyCard(
          title: 'له دې اسعارو',
          currency: from,
          isFrom: true,
          child: TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'اندازه ولیکئ',
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        Center(
          child: IconButton.filled(
            onPressed: swapCurrencies,
            icon: const Icon(Icons.swap_vert, size: 28),
            style: IconButton.styleFrom(
              backgroundColor: cyan,
              foregroundColor: bg,
            ),
          ),
        ),
        currencyCard(
          title: 'دې اسعارو ته',
          currency: to,
          isFrom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasBothRates ? format(result) : '--',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: cyan,
                ),
              ),
              if (hasBothRates)
                Text(
                  '${format(rates[from.code]! / rates[to.code]!)} '
                  '${from.code} = 1 ${to.code}',
                  style: const TextStyle(color: Colors.white70),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: loading ? null : saveHistory,
            icon: const Icon(Icons.currency_exchange),
            label: const Text(
              'تبادله حساب کړه',
              style: TextStyle(fontSize: 17),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'یادونه: دا د آنلاین مرجع نرخونه دي. د افغانستان د صرافیو نغدي نرخونه ممکن توپیر ولري.',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'د خوښې اسعار',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        ...currencies
            .where((c) => favorites.contains(c.code))
            .map(currencyTile),
      ],
    );
  }

  Widget currencyTile(Currency currency) {
    final favorite = favorites.contains(currency.code);
    final rate = rates[currency.code];

    return Card(
      color: panel,
      child: ListTile(
        leading: Text(
          currency.flag,
          style: const TextStyle(fontSize: 27),
        ),
        title: Text(currency.name),
        subtitle: Text(
          rate == null
              ? currency.code
              : '۱ USD = ${format(rate)} ${currency.code}',
        ),
        trailing: IconButton(
          onPressed: () {
            setState(() {
              if (favorite) {
                favorites.remove(currency.code);
              } else {
                favorites.add(currency.code);
              }
            });
          },
          icon: Icon(
            favorite ? Icons.star : Icons.star_border,
            color: favorite ? Colors.amber : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget currenciesPage() {
    final filtered = currencies.where((c) {
      return c.name.toLowerCase().contains(search.toLowerCase()) ||
          c.code.toLowerCase().contains(search.toLowerCase());
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: searchController,
            onChanged: (value) => setState(() => search = value),
            decoration: InputDecoration(
              hintText: 'د اسعارو لټون...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: panel,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            children: filtered.map(currencyTile).toList(),
          ),
        ),
      ],
    );
  }

  Widget historyPage() {
    if (history.isEmpty) {
      return const Center(
        child: Text(
          'تر اوسه د تبادلې تاریخچه نشته',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'د تبادلې تاریخچه',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => setState(() => history.clear()),
              child: const Text('پاکول'),
            ),
          ],
        ),
        ...history.map(
          (item) => Card(
            color: panel,
            child: ListTile(
              leading: const Icon(Icons.history, color: cyan),
              title: Text(item),
            ),
          ),
        ),
      ],
    );
  }

  Widget settingsPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 20),
        const Icon(Icons.currency_exchange, size: 65, color: cyan),
        const Center(
          child: Text(
            'Afghani Exchange',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          color: panel,
          child: ListTile(
            leading: const Icon(Icons.language, color: cyan),
            title: const Text('ژبه'),
            subtitle: Text(language),
            onTap: () {
              setState(() {
                language = language == 'پښتو' ? 'English' : 'پښتو';
              });
            },
          ),
        ),
        Card(
          color: panel,
          child: ListTile(
            leading: const Icon(Icons.cloud_sync, color: cyan),
            title: const Text('د نرخونو تازه کول'),
            subtitle: const Text('د انټرنېټ له لارې'),
            onTap: fetchRates,
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'نرخونه د بهرني API له لارې ترلاسه کېږي. د بازار نرخونه ممکن توپیر ولري.',
            style: TextStyle(color: Colors.white60),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: panel,
        title: const Row(
          children: [
            Icon(Icons.currency_exchange, color: cyan),
            SizedBox(width: 10),
            Text(
              'Afghani Exchange',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: loading ? null : fetchRates,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: IndexedStack(
        index: bottomIndex,
        children: [
          homePage(),
          currenciesPage(),
          historyPage(),
          settingsPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: bottomIndex,
        onDestinationSelected: (value) {
          setState(() => bottomIndex = value);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.swap_horiz),
            label: 'تبادله',
          ),
          NavigationDestination(
            icon: Icon(Icons.public),
            label: 'اسعار',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'تاریخچه',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'تنظیمات',
          ),
        ],
      ),
    );
  }
}
