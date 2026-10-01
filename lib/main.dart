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
      title: 'Afghani Exchange',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      home: const ExchangeHomePage(),
    );
  }
}

class Currency {
  final String code;
  final String name;
  final String symbol;

  Currency({
    required this.code,
    required this.name,
    required this.symbol,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      code: json['iso_code'] ?? '',
      name: json['name'] ?? '',
      symbol: json['symbol'] ?? '',
    );
  }
}

class ExchangeHomePage extends StatefulWidget {
  const ExchangeHomePage({super.key});

  @override
  State<ExchangeHomePage> createState() => _ExchangeHomePageState();
}

class _ExchangeHomePageState extends State<ExchangeHomePage> {
  List<Currency> currencies = [];
  List<Currency> filteredCurrencies = [];

  Currency? fromCurrency;
  Currency? toCurrency;

  final amountController = TextEditingController();

  double? result;
  double? rate;

  bool loadingCurrencies = true;
  bool converting = false;

  final Set<String> favorites = {};
  final List<String> history = [];

  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    loadCurrencies();

    refreshTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) {
        if (fromCurrency != null &&
            toCurrency != null &&
            amountController.text.isNotEmpty) {
          convertCurrency();
        }
      },
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    amountController.dispose();
    super.dispose();
  }

  Future<void> loadCurrencies() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.frankfurter.dev/v2/currencies'),
      );

      if (response.statusCode != 200) {
        throw Exception();
      }

      final List data = jsonDecode(response.body);

      final loaded = data
          .map((item) => Currency.fromJson(item))
          .where((c) => c.code.isNotEmpty)
          .toList();

      loaded.sort((a, b) => a.name.compareTo(b.name));

      if (!mounted) return;

      setState(() {
        currencies = loaded;
        filteredCurrencies = loaded;

        fromCurrency = loaded.firstWhere(
          (c) => c.code == 'USD',
          orElse: () => loaded.first,
        );

        toCurrency = loaded.firstWhere(
          (c) => c.code == 'AFN',
          orElse: () => loaded.first,
        );

        loadingCurrencies = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingCurrencies = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('د اسعارو لست ترلاسه نه شو'),
        ),
      );
    }
  }

  Future<void> convertCurrency() async {
    if (fromCurrency == null || toCurrency == null) return;

    final amount = double.tryParse(
      amountController.text.replaceAll(',', ''),
    );

    if (amount == null) {
      setState(() {
        result = null;
      });
      return;
    }

    if (fromCurrency!.code == toCurrency!.code) {
      setState(() {
        rate = 1;
        result = amount;
      });
      return;
    }

    setState(() {
      converting = true;
    });

    try {
      final url = Uri.parse(
        'https://api.frankfurter.dev/v2/rate/'
        '${fromCurrency!.code}/${toCurrency!.code}',
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception();
      }

      final data = jsonDecode(response.body);
      final currentRate = (data['rate'] as num).toDouble();
      final converted = amount * currentRate;

      if (!mounted) return;

      setState(() {
        rate = currentRate;
        result = converted;
        converting = false;

        final item =
            '${amount.toString()} ${fromCurrency!.code} = '
            '${converted.toStringAsFixed(2)} ${toCurrency!.code}';

        history.insert(0, item);

        if (history.length > 20) {
          history.removeLast();
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        converting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('د دې دوو اسعارو نرخ پیدا نه شو'),
        ),
      );
    }
  }

  void swapCurrencies() {
    if (fromCurrency == null || toCurrency == null) return;

    setState(() {
      final temp = fromCurrency;
      fromCurrency = toCurrency;
      toCurrency = temp;
      result = null;
      rate = null;
    });
  }

  void toggleFavorite(Currency currency) {
    setState(() {
      if (favorites.contains(currency.code)) {
        favorites.remove(currency.code);
      } else {
        favorites.add(currency.code);
      }
    });
  }

  Future<void> selectCurrency({
    required bool from,
  }) async {
    Currency? selected;

    selected = await showModalBottomSheet<Currency>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        String search = '';
        List<Currency> list = currencies;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            list = currencies.where((currency) {
              final text =
                  '${currency.name} ${currency.code}'.toLowerCase();
              return text.contains(search.toLowerCase());
            }).toList();

            return Directionality(
              textDirection: TextDirection.rtl,
              child: SafeArea(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      const Text(
                        'اسعار وټاکئ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'د اسعارو نوم یا کوډ ولټوئ',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setSheetState(() {
                              search = value;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            final currency = list[index];

                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  currency.code.substring(
                                    0,
                                    currency.code.length > 2 ? 2 : 1,
                                  ),
                                ),
                              ),
                              title: Text(currency.name),
                              subtitle: Text(
                                '${currency.code} ${currency.symbol}',
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  favorites.contains(currency.code)
                                      ? Icons.star
                                      : Icons.star_border,
                                ),
                                onPressed: () {
                                  toggleFavorite(currency);
                                  setSheetState(() {});
                                },
                              ),
                              onTap: () {
                                Navigator.pop(context, currency);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (selected == null) return;

    setState(() {
      if (from) {
        fromCurrency = selected;
      } else {
        toCurrency = selected;
      }

      result = null;
      rate = null;
    });
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
          actions: [
            IconButton(
              tooltip: 'تاریخچه',
              icon: const Icon(Icons.history),
              onPressed: showHistory,
            ),
          ],
        ),
        body: loadingCurrencies
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: loadCurrencies,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SizedBox(height: 10),

                    Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.currency_exchange,
                              size: 55,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'هر هېواد خپل اسعار وټاکئ',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${currencies.length} اسعار موجود دي',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'مقدار',
                        hintText: 'لکه 100',
                        prefixIcon: Icon(Icons.calculate),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 15),

                    currencyButton(
                      title: 'له اسعارو',
                      currency: fromCurrency,
                      onTap: () {
                        selectCurrency(from: true);
                      },
                    ),

                    const SizedBox(height: 8),

                    Center(
                      child: FloatingActionButton.small(
                        heroTag: 'swap',
                        onPressed: swapCurrencies,
                        child: const Icon(Icons.swap_vert),
                      ),
                    ),

                    const SizedBox(height: 8),

                    currencyButton(
                      title: 'ته اسعارو',
                      currency: toCurrency,
                      onTap: () {
                        selectCurrency(from: false);
                      },
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      height: 55,
                      child: FilledButton.icon(
                        onPressed:
                            converting ? null : convertCurrency,
                        icon: converting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.currency_exchange),
                        label: const Text(
                          'تبدیل کول',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (result != null)
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const Text(
                                'نتیجه',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${result!.toStringAsFixed(2)} '
                                '${toCurrency!.code}',
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (rate != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  '1 ${fromCurrency!.code} = '
                                  '${rate!.toStringAsFixed(6)} '
                                  '${toCurrency!.code}',
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.star),
                        title: const Text('خوښ اسعار'),
                        subtitle: Text(
                          favorites.isEmpty
                              ? 'تر اوسه کوم اسعار نه دي خوښ شوي'
                              : favorites.join(', '),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.update),
                        title: const Text('د نرخ تازه کول'),
                        subtitle: const Text(
                          'اپ هره دقیقه نرخ بیا ترلاسه کوي',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget currencyButton({
    required String title,
    required Currency? currency,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.public),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currency == null
                        ? 'اسعار وټاکئ'
                        : '${currency.name} (${currency.code})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  void showHistory() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: SizedBox(
              height: 450,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'د تبدیل تاریخچه',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: history.isEmpty
                        ? const Center(
                            child: Text('تر اوسه تاریخچه نشته'),
                          )
                        : ListView.builder(
                            itemCount: history.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading:
                                    const Icon(Icons.history),
                                title: Text(history[index]),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
