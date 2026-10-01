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
  final double rateFromAfn;

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.rateFromAfn,
  });
}

class ExchangePage extends StatefulWidget {
  const ExchangePage({super.key});

  @override
  State<ExchangePage> createState() => _ExchangePageState();
}

class _ExchangePageState extends State<ExchangePage> {
  final amountController = TextEditingController(text: '100');

  List<Currency> currencies = [];
  Currency? selectedCurrency;

  double? result;
  bool loading = true;
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
      (_) => loadCurrencies(silent: true),
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    amountController.dispose();
    super.dispose();
  }

  Future<void> loadCurrencies({bool silent = false}) async {
    if (!silent) {
      setState(() {
        loading = true;
      });
    }

    try {
      // EUR د منځني اسعار په توګه کاروو.
      final response = await http.get(
        Uri.parse(
          'https://api.frankfurter.dev/v2/rates?base=EUR',
        ),
      );

      if (response.statusCode != 200) {
        throw Exception();
      }

      final List data = jsonDecode(response.body);

      double? afnRate;

      final Map<String, double> eurRates = {};

      for (final item in data) {
        if (item is Map<String, dynamic>) {
          final quote = item['quote']?.toString();
          final rate = (item['rate'] as num?)?.toDouble();

          if (quote != null && rate != null && rate > 0) {
            eurRates[quote] = rate;

            if (quote == 'AFN') {
              afnRate = rate;
            }
          }
        }
      }

      if (afnRate == null) {
        throw Exception('AFN rate not found');
      }

      final List<Currency> list = [];

      // افغانۍ تل لومړی.
      list.add(
        const Currency(
          code: 'AFN',
          name: 'افغانۍ',
          symbol: '؋',
          rateFromAfn: 1,
        ),
      );

      // AFN -> هر اسعار محاسبه کوو.
      eurRates.forEach((code, eurRate) {
        if (code == 'AFN') return;

        final afnToCurrency = eurRate / afnRate!;

        list.add(
          Currency(
            code: code,
            name: currencyName(code),
            symbol: currencySymbol(code),
            rateFromAfn: afnToCurrency,
          ),
        );
      });

      list.sort((a, b) {
        if (a.code == 'AFN') return -1;
        if (b.code == 'AFN') return 1;
        return a.name.compareTo(b.name);
      });

      if (!mounted) return;

      Currency? old;

      if (selectedCurrency != null) {
        for (final c in list) {
          if (c.code == selectedCurrency!.code) {
            old = c;
            break;
          }
        }
      }

      setState(() {
        currencies = list;

        selectedCurrency = old ??
            list.firstWhere(
              (c) => c.code == 'USD',
              orElse: () => list.first,
            );

        loading = false;
      });

      convert();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'د اسعارو معلومات ترلاسه نه شول. انټرنېټ وګورئ.',
            ),
          ),
        );
      }
    }
  }

  void convert() {
    if (selectedCurrency == null) return;

    final amount = double.tryParse(
      amountController.text.replaceAll(',', ''),
    );

    if (amount == null) {
      setState(() {
        result = null;
      });
      return;
    }

    setState(() {
      converting = true;
      result = amount * selectedCurrency!.rateFromAfn;
      converting = false;
    });
  }

  Future<void> chooseCurrency() async {
    String search = '';

    final selected = await showModalBottomSheet<Currency>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = currencies.where((c) {
              final text =
                  '${c.name} ${c.code}'.toLowerCase();

              return text.contains(search.toLowerCase());
            }).toList();

            return Directionality(
              textDirection: TextDirection.rtl,
              child: SafeArea(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * .9,
                  child: Column(
                    children: [
                      const SizedBox(height: 15),

                      const Text(
                        'د نړۍ اسعار وټاکئ',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText:
                                'د هېواد یا اسعارو نوم ولټوئ',
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
                        child: filtered.isEmpty
                            ? const Center(
                                child: Text(
                                  'اسعار پیدا نه شول',
                                ),
                              )
                            : ListView.builder(
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final c = filtered[index];

                                  return ListTile(
                                    leading: CircleAvatar(
                                      child: Text(
                                        c.code.substring(
                                          0,
                                          c.code.length >= 2
                                              ? 2
                                              : 1,
                                        ),
                                      ),
                                    ),
                                    title: Text(c.name),
                                    subtitle: Text(
                                      '${c.code} ${c.symbol}',
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        favorites.contains(c.code)
                                            ? Icons.star
                                            : Icons.star_border,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          if (favorites
                                              .contains(c.code)) {
                                            favorites.remove(c.code);
                                          } else {
                                            favorites.add(c.code);
                                          }
                                        });

                                        setSheetState(() {});
                                      },
                                    ),
                                    onTap: () {
                                      Navigator.pop(context, c);
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
      selectedCurrency = selected;
    });

    convert();
  }

  void saveHistory() {
    if (selectedCurrency == null || result == null) return;

    final amount = double.tryParse(
      amountController.text.replaceAll(',', ''),
    );

    if (amount == null) return;

    setState(() {
      history.insert(
        0,
        '${amount.toString()} AFN = '
        '${result!.toStringAsFixed(2)} '
        '${selectedCurrency!.code}',
      );

      if (history.length > 30) {
        history.removeLast();
      }
    });
  }

  void showHistory() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SizedBox(
            height: 450,
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
        );
      },
    );
  }

  String currencyName(String code) {
    const names = {
      'AFN': 'افغانۍ',
      'USD': 'امریکايي ډالر',
      'EUR': 'یورو',
      'PKR': 'پاکستانۍ روپۍ',
      'INR': 'هندي روپۍ',
      'IRR': 'ایراني ریال',
      'CNY': 'چینایي یوان',
      'AED': 'اماراتي درهم',
      'SAR': 'سعودي ریال',
      'GBP': 'برتانوي پونډ',
      'TRY': 'ترکي لیره',
      'RUB': 'روسي روبل',
      'JPY': 'جاپاني ین',
      'CAD': 'کاناډايي ډالر',
      'AUD': 'اسټرالیايي ډالر',
      'CHF': 'سویس فرانک',
      'NZD': 'نیوزیلنډ ډالر',
      'QAR': 'قطري ریال',
      'KWD': 'کویتي دینار',
      'OMR': 'عماني ریال',
      'BHD': 'بحریني دینار',
      'KZT': 'قزاقستان ټینګه',
      'UZS': 'ازبکستان سوم',
      'TJS': 'تاجکستان سوموني',
      'NOK': 'ناروې کرونا',
      'SEK': 'سویډني کرونا',
      'DKK': 'ډنمارکي کرونا',
      'BRL': 'برازیلي ریال',
      'ZAR': 'جنوبي افریقا رینډ',
      'MYR': 'مالیزیا رینګټ',
      'IDR': 'اندونیزیا روپیه',
      'THB': 'تایلنډ باهت',
      'VND': 'ویتنام ډانګ',
      'KRW': 'جنوبي کوریا وان',
    };

    return names[code] ?? code;
  }

  String currencySymbol(String code) {
    const symbols = {
      'AFN': '؋',
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'INR': '₹',
      'PKR': '₨',
      'CNY': '¥',
      'JPY': '¥',
      'RUB': '₽',
      'TRY': '₺',
      'SAR': '﷼',
      'AED': 'د.إ',
    };

    return symbols[code] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'افغانۍ ↔ د نړۍ اسعار',
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
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.currency_exchange,
                              size: 60,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'افغانۍ له نړۍ سره تبدیل کړئ',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
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
                      onChanged: (_) => convert(),
                      decoration: const InputDecoration(
                        labelText: 'افغانۍ',
                        hintText: 'لکه 100',
                        prefixIcon: Icon(Icons.payments),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.green,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        children: [
                          CircleAvatar(
                            child: Text('؋'),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'افغانۍ (AFN)',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            'اصلي اسعار',
                            style: TextStyle(
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    Center(
                      child: FloatingActionButton.small(
                        heroTag: 'swap',
                        onPressed: () {},
                        child: const Icon(Icons.swap_vert),
                      ),
                    ),

                    const SizedBox(height: 12),

                    InkWell(
                      onTap: chooseCurrency,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.public),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'ته اسعارو',
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    selectedCurrency == null
                                        ? 'اسعار وټاکئ'
                                        : '${selectedCurrency!.name} '
                                          '(${selectedCurrency!.code})',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      height: 55,
                      child: FilledButton.icon(
                        onPressed: converting
                            ? null
                            : () {
                                convert();
                                saveHistory();
                              },
                        icon: const Icon(
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
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            children: [
                              const Text(
                                'نتیجه',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${result!.toStringAsFixed(2)} '
                                '${selectedCurrency!.code}',
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '1 AFN = '
                                '${selectedCurrency!.rateFromAfn} '
                                '${selectedCurrency!.code}',
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
                              ? 'هیڅ اسعار نه دي خوښ شوي'
                              : favorites.join(', '),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Card(
                      child: ListTile(
                        leading: Icon(Icons.update),
                        title: Text('نرخونه تازه کېږي'),
                        subtitle: Text(
                          'اپ هره دقیقه نرخونه بیا ترلاسه کوي',
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
