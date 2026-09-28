import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const AfghaniExchangeApp());
}

class AfghaniExchangeApp extends StatelessWidget {
  const AfghaniExchangeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'د اسعارو تبدیل',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      home: const CurrencyHomePage(),
    );
  }
}

class CurrencyHomePage extends StatefulWidget {
  const CurrencyHomePage({super.key});

  @override
  State<CurrencyHomePage> createState() => _CurrencyHomePageState();
}

class _CurrencyHomePageState extends State<CurrencyHomePage> {
  final amountController = TextEditingController(text: '1');

  final currencies = <String, String>{
    'AFN': 'افغانۍ 🇦🇫',
    'USD': 'امریکایي ډالر 🇺🇸',
    'EUR': 'یورو 🇪🇺',
    'GBP': 'پونډ 🇬🇧',
    'PKR': 'پاکستانۍ روپۍ 🇵🇰',
    'INR': 'هندي روپۍ 🇮🇳',
    'CNY': 'چینایي یوان 🇨🇳',
    'AED': 'اماراتي درهم 🇦🇪',
    'SAR': 'سعودي ریال 🇸🇦',
    'TRY': 'ترکي لیره 🇹🇷',
    'CAD': 'کاناډایي ډالر 🇨🇦',
    'AUD': 'استرالیایي ډالر 🇦🇺',
    'JPY': 'جاپاني ین 🇯🇵',
    'CHF': 'سویسي فرانک 🇨🇭',
    'SEK': 'سویډني کرونا 🇸🇪',
    'NOK': 'نارویژي کرونا 🇳🇴',
    'DKK': 'ډنمارکي کرونا 🇩🇰',
    'RUB': 'روسي روبل 🇷🇺',
    'NZD': 'نیوزیلنډي ډالر 🇳🇿',
    'SGD': 'سنګاپوري ډالر 🇸🇬',
  };

  String from = 'AFN';
  String to = 'USD';
  double result = 0;
  double rate = 0;
  bool loading = false;

  final Set<String> favorites = {'USD', 'PKR', 'INR'};

  final List<String> history = [];

  Timer? timer;

  @override
  void initState() {
    super.initState();
    convert();

    // هره دقیقه نرخ بیا تازه کوي.
    timer = Timer.periodic(const Duration(minutes: 1), (_) {
      convert();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    amountController.dispose();
    super.dispose();
  }

  Future<void> convert() async {
    final amount = double.tryParse(amountController.text) ?? 0;

    if (from == to) {
      setState(() {
        rate = 1;
        result = amount;
      });
      return;
    }

    setState(() => loading = true);

    try {
      final url = Uri.parse(
        'https://api.frankfurter.dev/v2/rate/$from/$to',
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('نرخ ترلاسه نه شو');
      }

      final data = jsonDecode(response.body);
      final newRate = (data['rate'] as num).toDouble();

      setState(() {
        rate = newRate;
        result = amount * newRate;
        loading = false;
      });

      final item =
          '${amount.toStringAsFixed(2)} $from = ${result.toStringAsFixed(2)} $to';

      if (!history.contains(item)) {
        history.insert(0, item);
        if (history.length > 10) {
          history.removeLast();
        }
      }
    } catch (e) {
      setState(() => loading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('د اسعارو نرخ ترلاسه نه شو'),
          ),
        );
      }
    }
  }

  void swapCurrencies() {
    setState(() {
      final oldFrom = from;
      from = to;
      to = oldFrom;
    });
    convert();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'د اسعارو تبدیل',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 10),

              const Text(
                '🌍 د اسعارو تبدیل',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'مقدار',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.money),
                ),
                onChanged: (_) => convert(),
              ),

              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: from,
                decoration: const InputDecoration(
                  labelText: 'له کوم اسعارو',
                  border: OutlineInputBorder(),
                ),
                items: currencies.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => from = value);
                    convert();
                  }
                },
              ),

              const SizedBox(height: 12),

              IconButton.filled(
                onPressed: swapCurrencies,
                icon: const Icon(Icons.swap_vert),
                tooltip: 'اسعار بدلول',
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: to,
                decoration: const InputDecoration(
                  labelText: 'کوم اسعارو ته',
                  border: OutlineInputBorder(),
                ),
                items: currencies.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => to = value);
                    convert();
                  }
                },
              ),

              const SizedBox(height: 25),

              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'پایله',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      loading
                          ? const CircularProgressIndicator()
                          : Text(
                              '${result.toStringAsFixed(2)} $to',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      const SizedBox(height: 8),
                      Text(
                        '۱ $from = ${rate.toStringAsFixed(4)} $to',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '⭐ خوښ اسعار',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),

              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                children: favorites.map((code) {
                  return ActionChip(
                    label: Text(code),
                    avatar: const Icon(Icons.star, size: 18),
                    onPressed: () {
                      setState(() => to = code);
                      convert();
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 25),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '📈 د تبدیلولو تاریخچه',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),

              const SizedBox(height: 8),

              if (history.isEmpty)
                const Text('تر اوسه کومه تاریخچه نشته')
              else
                ...history.map(
                  (item) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.history),
                      title: Text(item),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              const Text(
                '🔄 نرخونه هره دقیقه تازه کېږي',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
