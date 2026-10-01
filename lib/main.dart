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
      home: const HomePage(),
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController amountController =
      TextEditingController(text: '100');

  List<Currency> currencies = [];
  List<Currency> filteredCurrencies = [];

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
      (_) {
        loadCurrencies(silent: true);
      },
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
      // AFN د ټولو موجودو اسعارو لپاره بنسټیز اسعار دی.
      final response = await http.get(
        Uri.parse(
          'https://api.frankfurter.dev/v2/rates?base=AFN',
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Rates error');
      }

      final List data = jsonDecode(response.body);

      final List<Currency> list = [];

      // افغانۍ خپله هم اضافه کوو.
      list.add(
        const Currency(
          code: 'AFN',
          name: 'افغانۍ',
          symbol: '؋',
          rateFromAfn: 1,
        ),
      );

      for (final item in data) {
        if (item is Map<String, dynamic>) {
          final code = item['quote']?.toString() ?? '';
          final rate =
              (item['rate'] as num?)?.toDouble() ?? 0;

          if (code.isNotEmpty && rate > 0 && code != 'AFN') {
            list.add(
              Currency(
                code: code,
                name: currencyName(code),
                symbol: currencySymbol(code),
                rateFromAfn: rate,
              ),
            );
          }
        }
      }

      list.sort((a, b) {
        if (a.code == 'AFN') return -1;
        if (b.code == 'AFN') return 1;
        return a.name.compareTo(b.name);
      });

      if (!mounted) return;

      Currency? oldSelected;

      if (selectedCurrency != null) {
        for (final c in list) {
          if (c.code == selectedCurrency!.code) {
            oldSelected = c;
            break;
          }
        }
      }

      setState(() {
        currencies = list;
        filteredCurrencies = list;
        selectedCurrency = oldSelected ??
            list.firstWhere(
              (c) => c.code == 'USD',
              orElse: () => list.first,
            );
        loading = false;
      });

      if (amountController.text.isNotEmpty) {
        convert();
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'د اسعارو نرخونه ترلاسه نه شول. انټرنېټ وګورئ.',
            ),
          ),
        );
      }
    }
  }

  String currencyName(String code) {
    const names = {
      'AED': 'متحده عربي امارات درهم',
      'AFN': 'افغانۍ',
      'ALL': 'البانیا لیک',
      'AMD': 'ارمنستان درام',
      'ANG': 'نتیلالنډي ګیلډر',
      'AOA': 'انګولا کوانزا',
      'ARS': 'ارجنټاین پیسو',
      'AUD': 'اسټرالیايي ډالر',
      'AWG': 'اروبا فلورین',
      'AZN': 'اذربایجان منات',
      'BAM': 'بوسنیا مارک',
      'BBD': 'باربادوس ډالر',
      'BDT': 'بنګله دېش ټاکا',
      'BGN': 'بلغاریا لیو',
      'BHD': 'بحرین دینار',
      'BIF': 'برونډي فرانک',
      'BMD': 'برمودا ډالر',
      'BND': 'برونای ډالر',
      'BOB': 'بولیویا بولیویانو',
      'BRL': 'برازیل ریال',
      'BSD': 'باهاماس ډالر',
      'BTN': 'بوتان نګولټرم',
      'BWP': 'بوتسوانا پولا',
      'BYN': 'بلاروس روبل',
      'BZD': 'بلیز ډالر',
      'CAD': 'کاناډايي ډالر',
      'CDF': 'کانګو فرانک',
      'CHF': 'سویس فرانک',
      'CLP': 'چیلي پیسو',
      'CNY': 'چین یوان',
      'COP': 'کولمبیا پیسو',
      'CRC': 'کوسټاریکا کولون',
      'CUP': 'کیوبا پیسو',
      'CVE': 'کیپ ورد ایسکوډو',
      'CZK': 'چک کرونا',
      'DJF': 'جیبوتي فرانک',
      'DKK': 'ډنمارکي کرونا',
      'DOP': 'ډومینیکن پیسو',
      'DZD': 'الجزایر دینار',
      'EGP': 'مصر پونډ',
      'ERN': 'اریټریا ناکفا',
      'ETB': 'ایتوپیا بیر',
      'EUR': 'یورو',
      'FJD': 'فیجي ډالر',
      'GBP': 'برتانوي پونډ',
      'GEL': 'جورجیا لاري',
      'GHS': 'ګانا سېدي',
      'GMD': 'ګامبیا دلاسي',
      'GNF': 'ګیني فرانک',
      'GTQ': 'ګواتیمالا کویتزال',
      'HKD': 'هانګ کانګ ډالر',
      'HNL': 'هندوراس لمپیرا',
      'HRK': 'کرویشیا کونا',
      'HTG': 'هایټي ګورد',
      'HUF': 'هنګري فورینټ',
      'IDR': 'اندونیزیا روپیه',
      'ILS': 'اسراییلي شیکل',
      'INR': 'هندي روپۍ',
      'IQD': 'عراقي دینار',
      'IRR': 'ایراني ریال',
      'ISK': 'آیسلنډ کرونا',
      'JMD': 'جمیکا ډالر',
      'JOD': 'اردن دینار',
      'JPY': 'جاپاني ین',
      'KES': 'کینیا شیلینګ',
      'KGS': 'قرغزستان سوم',
      'KHR': 'کمبودیا رییل',
      'KMF': 'کوموروس فرانک',
      'KRW': 'جنوبي کوریا وان',
      'KWD': 'کویټ دینار',
      'KZT': 'قزاقستان ټینګه',
      'LAK': 'لاوس کیپ',
      'LBP': 'لبنان پونډ',
      'LKR': 'سریلانکا روپۍ',
      'LRD': 'لایبریا ډالر',
      'LSL': 'لیسوتو لوټي',
      'LYD': 'لیبیا دینار',
      'MAD': 'مراکش درهم',
      'MDL': 'مولدووا لیو',
      'MGA': 'مدغاسکر اریاري',
      'MKD': 'مقدونیه دینار',
      'MMK': 'میانمار کیات',
      'MNT': 'مغولستان توګریک',
      'MOP': 'مکاو پټاکا',
      'MRU': 'موریتانیا اوګیویا',
      'MUR': 'موریس روپۍ',
      'MVR': 'مالدیف روفیا',
      'MWK': 'مالاوي کوایچا',
      'MXN': 'مکسیکو پیسو',
      'MYR': 'مالیزیا رینګټ',
      'MZN': 'موزمبیق متیکال',
      'NAD': 'نامیبیا ډالر',
      'NGN': 'نایجیریا نایرا',
      'NIO': 'نیکاراګوا کوردوبا',
      'NOK': 'ناروې کرونا',
      'NPR': 'نیپال روپۍ',
      'NZD': 'نیوزیلنډ ډالر',
      'OMR': 'عمان ریال',
      'PAB': 'پاناما بالبوا',
      'PEN': 'پیرو سول',
      'PGK': 'پاپوا نیو ګیني کینا',
      'PHP': 'فلپین پیسو',
      'PKR': 'پاکستانۍ روپۍ',
      'PLN': 'پولنډ زلوټي',
      'PYG': 'پاراګوای ګواراني',
      'QAR': 'قطر ریال',
      'RON': 'رومانیا لیو',
      'RSD': 'سربیا دینار',
      'RUB': 'روسي روبل',
      'RWF': 'رواندا فرانک',
      'SAR': 'سعودي ریال',
      'SBD': 'سلیمان ټاپو ډالر',
      'SCR': 'سیشل روپۍ',
      'SDG': 'سوډان پونډ',
      'SEK': 'سویډني کرونا',
      'SGD': 'سنګاپور ډالر',
      'SLE': 'سیرا لیون لیون',
      'SOS': 'سومالیا شیلینګ',
      'SRD': 'سورینام ډالر',
      'SSP': 'جنوبي سوډان پونډ',
      'STN': 'ساو تومه دوبرا',
      'SVC': 'السلوادور کولون',
      'SYP': 'سوریه پونډ',
      'SZL': 'اسواتیني لېلانجیني',
      'THB': 'تایلنډ باهت',
      'TJS': 'تاجکستان سوموني',
      'TMT': 'ترکمنستان منات',
      'TND': 'تونس دینار',
      'TOP': 'تونګا پانګا',
      'TRY': 'ترکي لیره',
      'TTD': 'ترینیداد ډالر',
      'TWD': 'تایوان ډالر',
      'TZS': 'تنزانیا شیلینګ',
      'UAH': 'اوکراین هریونیا',
      'UGX': 'یوګانډا شیلینګ',
      'USD': 'امریکايي ډالر',
      'UYU': 'یوروګوای پیسو',
      'UZS': 'ازبکستان سوم',
      'VES': 'وینزویلا بولیوار',
      'VND': 'ویتنام ډانګ',
      'VUV': 'وانواتو واتو',
      'WST': 'ساموا تالا',
      'XAF': 'مرکزي افریقا فرانک',
      'XCD': 'ختیځ کارابین ډالر',
      'XOF': 'لویدیځ افریقا فرانک',
      'XPF': 'پسیفیک فرانک',
      'YER': 'یمن ریال',
      'ZAR': 'جنوبي افریقا رینډ',
      'ZMW': 'زیمبیا کوانچا',
      'ZWL': 'زیمبابوې ډالر',
    };

    return names[code] ?? code;
  }

  String currencySymbol(String code) {
    const symbols = {
      'AFN': '؋',
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'PKR': '₨',
      'INR': '₹',
      'CNY': '¥',
      'JPY': '¥',
      'SAR': '﷼',
      'AED': 'د.إ',
      'TRY': '₺',
      'RUB': '₽',
      'CAD': 'C\$',
      'AUD': 'A\$',
    };

    return symbols[code] ?? code;
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
    });

    // rateFromAfn = 1 AFN په څو ټاکل شوي اسعارو بدلېږي.
    final converted = amount * selectedCurrency!.rateFromAfn;

    setState(() {
      result = converted;
      converting = false;
    });
  }

  void addHistory() {
    if (selectedCurrency == null || result == null) return;

    final amount = double.tryParse(
      amountController.text.replaceAll(',', ''),
    );

    if (amount == null) return;

    final text =
        '$amount AFN = ${result!.toStringAsFixed(2)} '
        '${selectedCurrency!.code}';

    setState(() {
      history.insert(0, text);

      if (history.length > 30) {
        history.removeLast();
      }
    });
  }

  Future<void> selectCurrency() async {
    String search = '';

    final selected = await showModalBottomSheet<Currency>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            filteredCurrencies = currencies.where((currency) {
              final text =
                  '${currency.name} ${currency.code}'
                      .toLowerCase();

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
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'د هېواد یا اسعارو نوم ولټوئ',
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
                          itemCount: filteredCurrencies.length,
                          itemBuilder: (context, index) {
                            final currency =
                                filteredCurrencies[index];

                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  currency.code.substring(
                                    0,
                                    currency.code.length >= 2
                                        ? 2
                                        : 1,
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
                                  setState(() {
                                    if (favorites.contains(
                                      currency.code,
                                    )) {
                                      favorites.remove(
                                        currency.code,
                                      );
                                    } else {
                                      favorites.add(currency.code);
                                    }
                                  });

                                  setSheetState(() {});
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
      selectedCurrency = selected;
      result = null;
    });

    if (amountController.text.isNotEmpty) {
      convert();
    }
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

  void showFavorites() {
    final favoriteCurrencies = currencies
        .where((c) => favorites.contains(c.code))
        .toList();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: SizedBox(
              height: 400,
              child: favoriteCurrencies.isEmpty
                  ? const Center(
                      child: Text('تر اوسه کوم اسعار خوښ شوي نه دي'),
                    )
                  : ListView.builder(
                      itemCount: favoriteCurrencies.length,
                      itemBuilder: (context, index) {
                        final c = favoriteCurrencies[index];

                        return ListTile(
                          leading: const Icon(Icons.star),
                          title: Text(c.name),
                          subtitle: Text(c.code),
                          onTap: () {
                            Navigator.pop(context);

                            setState(() {
                              selectedCurrency = c;
                            });

                            convert();
                          },
                        );
                      },
                    ),
            ),
          ),
        );
      },
    );
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
                      onChanged: (_) {
                        convert();
                      },
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
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            child: Text('؋'),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'افغانۍ (AFN)',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Text(
                            'اصلي اسعار',
                            style: TextStyle(
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    Center(
                      child: FloatingActionButton.small(
                        heroTag: 'swap',
                        onPressed: () {},
                        child: const Icon(Icons.swap_vert),
                      ),
                    ),

                    const SizedBox(height: 10),

                    InkWell(
                      onTap: selectCurrency,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outline,
                          ),
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
                                    'د نړۍ اسعار',
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
                            const Icon(Icons.arrow_drop_down),
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
                                addHistory();
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
                                '${selectedCurrency!.rateFromAfn}'
                                ' ${selectedCurrency!.code}',
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
                        onTap: showFavorites,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Card(
                      child: const ListTile(
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
