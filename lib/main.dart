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
      home: const ExchangePage(),
    );
  }
}

class Currency {
  final String code;
  final String name;
  final String symbol;

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
  });
}

class ExchangePage extends StatefulWidget {
  const ExchangePage({super.key});

  @override
  State<ExchangePage> createState() => _ExchangePageState();
}

class _ExchangePageState extends State<ExchangePage> {
  List<Currency> currencies = [];

  Currency? fromCurrency;
  Currency? toCurrency;

  final amountController = TextEditingController();

  double? result;
  double? rate;

  bool loading = true;
  bool converting = false;

  final Set<String> favorites = {};
  final List<String> history = [];

  Timer? timer;

  @override
  void initState() {
    super.initState();
    loadCurrencies();

    timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) {
        if (amountController.text.isNotEmpty &&
            fromCurrency != null &&
            toCurrency != null) {
          convert();
        }
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    amountController.dispose();
    super.dispose();
  }

  Future<void> loadCurrencies() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.frankfurter.dev/v2/currencies'),
      );

      if (response.statusCode != 200) {
        throw Exception('API error');
      }

      final decoded = jsonDecode(response.body);

      List<Currency> list = [];

      // API د اسعارو معلومات د List په شکل راکوي
      if (decoded is List) {
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            final code = item['iso_code']?.toString() ?? '';
            final name = item['name']?.toString() ?? '';
            final symbol = item['symbol']?.toString() ?? '';

            if (code.isNotEmpty && name.isNotEmpty) {
              list.add(
                Currency(
                  code: code,
                  name: name,
                  symbol: symbol,
                ),
              );
            }
          }
        }
      }

      list.sort((a, b) => a.name.compareTo(b.name));

      if (!mounted) return;

      setState(() {
        currencies = list;
        loading = false;

        fromCurrency = findCurrency('USD');
        toCurrency = findCurrency('AFN');
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('د اسعارو لست ترلاسه نه شو'),
        ),
      );
    }
  }

  Currency? findCurrency(String code) {
    for (final currency in currencies) {
      if (currency.code == code) {
        return currency;
      }
    }
    return currencies.isNotEmpty ? currencies.first : null;
  }

  Future<void> convert() async {
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

        history.insert(
          0,
          '${amount.toString()} ${fromCurrency!.code} = '
          '${converted.toStringAsFixed(2)} ${toCurrency!.code}',
        );

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
          content: Text('د دې دوو اسعارو نرخ موجود نه دی'),
        ),
      );
    }
  }

  void swap() {
    if (fromCurrency == null || toCurrency == null) return;

    setState(() {
      final old = fromCurrency;
      fromCurrency = toCurrency;
      toCurrency = old;
      result = null;
      rate = null;
    });
  }

  Future<void> chooseCurrency(bool from) async {
    Currency? selected;

    selected = await showModalBottomSheet<Currency>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        String search = '';

        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = currencies.where((currency) {
              final text =
                  '${currency.name} ${currency.code}'.toLowerCase();

              return text.contains(search.toLowerCase());
            }).toList();

            return Directionality(
              textDirection: TextDirection.rtl,
              child: SafeArea(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * .88,
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      const Text(
                        'اسعار وټاکئ',
                        style: TextStyle(
                          fontSize: 21,
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
                            setModalState(() {
                              search = value;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: filtered.isEmpty
                            ? const Center(
                                child: Text('اسعار پیدا نه شول'),
                              )
                            : ListView.builder(
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final currency = filtered[index];

                                  return ListTile(
                                    leading: CircleAvatar(
                                      child: Text(
                                        currency.code.substring(0, 2),
                                      ),
                                    ),
                                    title: Text(currency.name),
                                    subtitle: Text(
                                      '${currency.code} ${currency.symbol}',
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        favorites.contains(
                                          currency.code,
                                        )
                                            ? Icons.star
                                            : Icons.star_border,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          if (favorites.contains(
                                            currency.code,
                                          )) {
                                            favorites.remove(
                                              currency.code,
                                            );
                                          } else {
                                            favorites.add(
                                              currency.code,
                                            );
                                          }
                                        });

                                        setModalState(() {});
                                      },
                                    ),
                                    onTap: () {
                                      Navigator.pop(
                                        context,
                                        currency,
                                      );
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
                                leading: const Icon(Icons.history),
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

  Widget currencyBox({
    required String title,
    required Currency? currency,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(14),
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
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 5),
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
              onPressed: showHistory,
              icon: const Icon(Icons.history),
            ),
          ],
        ),
        body: loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: loadCurrencies,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
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
                              'د نړۍ اسعار',
                              style: TextStyle(
                                fontSize: 21,
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

                    currencyBox(
                      title: 'له اسعارو',
                      currency: fromCurrency,
                      onTap: () => chooseCurrency(true),
                    ),

                    const SizedBox(height: 10),

                    Center(
                      child: FloatingActionButton.small(
                        heroTag: 'swapButton',
                        onPressed: swap,
                        child: const Icon(Icons.swap_vert),
                      ),
                    ),

                    const SizedBox(height: 10),

                    currencyBox(
                      title: 'ته اسعارو',
                      currency: toCurrency,
                      onTap: () => chooseCurrency(false),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      height: 55,
                      child: FilledButton.icon(
                        onPressed: converting ? null : convert,
                        icon: converting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.currency_exchange,
                              ),
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
                              const SizedBox(height: 8),
                              if (rate != null)
                                Text(
                                  '1 ${fromCurrency!.code} = '
                                  '${rate!.toStringAsFixed(6)} '
                                  '${toCurrency!.code}',
                                ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 15),

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
                      child: const ListTile(
                        leading: Icon(Icons.update),
                        title: Text('اتومات تازه کول'),
                        subtitle: Text(
                          'د نرخ غوښتنه هره دقیقه بیا کېږي',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
