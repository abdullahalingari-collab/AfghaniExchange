import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const AfghaniExchange());
}

class Currency {
  final String code;
  final String name;

  const Currency(this.code, this.name);
}

class AfghaniExchange extends StatefulWidget {
  const AfghaniExchange({super.key});

  @override
  State<AfghaniExchange> createState() => _AfghaniExchangeState();
}

class _AfghaniExchangeState extends State<AfghaniExchange> {
  String language = 'ps';

  final TextEditingController amountController =
      TextEditingController(text: '1000');

  final Map<String, Map<String, String>> text = {
    'ps': {
      'title': 'افغاني ایکسچینج',
      'from': 'له',
      'to': 'ته',
      'amount': 'مقدار',
      'result': 'پایله',
      'search': 'د اسعارو لټون',
      'favorites': 'خوښ اسعار',
      'history': 'تاریخچه',
      'refresh': 'تازه کول',
      'retry': 'بیا هڅه',
      'loading': 'د اسعارو معلومات راټولېږي...',
      'error': 'د اسعارو معلومات ترلاسه نه شول',
      'available': 'اسعار موجود دي',
      'lastUpdate': 'وروستی تازه کېدل',
      'language': 'ژبه',
      'noFavorites': 'تر اوسه کوم اسعار خوښ شوي نه دي',
      'noHistory': 'تر اوسه تاریخچه نشته',
    },
    'fa': {
      'title': 'صرافی افغانی',
      'from': 'از',
      'to': 'به',
      'amount': 'مقدار',
      'result': 'نتیجه',
      'search': 'جستجوی اسعار',
      'favorites': 'اسعار مورد علاقه',
      'history': 'تاریخچه',
      'refresh': 'تازه کردن',
      'retry': 'تلاش دوباره',
      'loading': 'معلومات اسعار دریافت می‌شود...',
      'error': 'معلومات اسعار دریافت نشد',
      'available': 'اسعار موجود',
      'lastUpdate': 'آخرین بروزرسانی',
      'language': 'زبان',
      'noFavorites': 'هنوز اسعاری انتخاب نشده است',
      'noHistory': 'هنوز تاریخچه‌ای وجود ندارد',
    },
    'en': {
      'title': 'Afghani Exchange',
      'from': 'From',
      'to': 'To',
      'amount': 'Amount',
      'result': 'Result',
      'search': 'Search currencies',
      'favorites': 'Favorites',
      'history': 'History',
      'refresh': 'Refresh',
      'retry': 'Retry',
      'loading': 'Loading currency rates...',
      'error': 'Could not load currency rates',
      'available': 'currencies available',
      'lastUpdate': 'Last update',
      'language': 'Language',
      'noFavorites': 'No favorite currencies yet',
      'noHistory': 'No conversion history yet',
    },
  };

  String t(String key) => text[language]![key]!;

  final Map<String, String> currencyNames = {
    'AFN': 'Afghan Afghani',
    'USD': 'US Dollar',
    'EUR': 'Euro',
    'GBP': 'British Pound',
    'PKR': 'Pakistani Rupee',
    'INR': 'Indian Rupee',
    'AED': 'UAE Dirham',
    'SAR': 'Saudi Riyal',
    'QAR': 'Qatari Riyal',
    'TRY': 'Turkish Lira',
    'CNY': 'Chinese Yuan',
    'JPY': 'Japanese Yen',
    'CAD': 'Canadian Dollar',
    'AUD': 'Australian Dollar',
    'CHF': 'Swiss Franc',
    'RUB': 'Russian Ruble',
    'IRR': 'Iranian Rial',
    'KWD': 'Kuwaiti Dinar',
    'BHD': 'Bahraini Dinar',
    'OMR': 'Omani Rial',
    'MYR': 'Malaysian Ringgit',
    'THB': 'Thai Baht',
    'SGD': 'Singapore Dollar',
    'HKD': 'Hong Kong Dollar',
    'NZD': 'New Zealand Dollar',
    'SEK': 'Swedish Krona',
    'NOK': 'Norwegian Krone',
    'DKK': 'Danish Krone',
    'ZAR': 'South African Rand',
    'BRL': 'Brazilian Real',
    'MXN': 'Mexican Peso',
  };

  final Map<String, double> rates = {};
  final List<String> favorites = [];
  final List<String> history = [];

  String selectedCurrency = 'USD';
  double selectedRate = 0;
  bool loading = true;
  String? error;
  String lastUpdate = '';

  @override
  void initState() {
    super.initState();
    loadRates();
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<void> loadRates() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final response = await http
          .get(Uri.parse('https://open.er-api.com/v6/latest/AFN'))
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception();
      }

      final data = jsonDecode(response.body);

      if (data['result'] != 'success') {
        throw Exception();
      }

      final Map<String, dynamic> apiRates =
          Map<String, dynamic>.from(data['rates']);

      rates.clear();

      apiRates.forEach((key, value) {
        rates[key] = (value as num).toDouble();
      });

      selectedRate = rates[selectedCurrency] ?? 0;

      setState(() {
        lastUpdate =
            data['time_last_update_utc']?.toString() ?? '';
        loading = false;
      });
    } catch (_) {
      setState(() {
        loading = false;
        error = t('error');
      });
    }
  }

  String displayName(String code) {
    if (language == 'ps') {
      final ps = {
        'AFN': 'افغانۍ',
        'USD': 'امریکایي ډالر',
        'EUR': 'یورو',
        'GBP': 'برتانوي پونډ',
        'PKR': 'پاکستانۍ روپۍ',
        'INR': 'هندي روپۍ',
        'AED': 'اماراتي درهم',
        'SAR': 'سعودي ریال',
        'QAR': 'قطري ریال',
        'CNY': 'چینایي یوان',
        'JPY': 'جاپاني ین',
        'TRY': 'ترکي لیره',
        'IRR': 'ایراني ریال',
        'RUB': 'روسي روبل',
      };
      return ps[code] ?? currencyNames[code] ?? code;
    }

    if (language == 'fa') {
      final fa = {
        'AFN': 'افغانی',
        'USD': 'دالر امریکایی',
        'EUR': 'یورو',
        'GBP': 'پوند انگلیس',
        'PKR': 'روپیه پاکستان',
        'INR': 'روپیه هند',
        'AED': 'درهم امارات',
        'SAR': 'ریال سعودی',
        'QAR': 'ریال قطر',
        'CNY': 'یوان چین',
        'JPY': 'ین جاپان',
        'TRY': 'لیر ترکیه',
        'IRR': 'ریال ایران',
        'RUB': 'روبل روسیه',
      };
      return fa[code] ?? currencyNames[code] ?? code;
    }

    return currencyNames[code] ?? code;
  }

  double get result {
    final amount =
        double.tryParse(amountController.text.replaceAll(',', '')) ?? 0;
    return amount * selectedRate;
  }

  void selectCurrency(String code) {
    setState(() {
      selectedCurrency = code;
      selectedRate = rates[code] ?? 0;
    });
  }

  void addHistory() {
    final amount =
        double.tryParse(amountController.text.replaceAll(',', '')) ?? 0;

    if (amount <= 0) return;

    final item =
        '${amount.toStringAsFixed(2)} AFN → ${result.toStringAsFixed(2)} $selectedCurrency';

    setState(() {
      history.insert(0, item);
      if (history.length > 20) {
        history.removeLast();
      }
    });
  }

  void toggleFavorite(String code) {
    setState(() {
      if (favorites.contains(code)) {
        favorites.remove(code);
      } else {
        favorites.add(code);
      }
    });
  }

  void chooseLanguage() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('پښتو'),
              onTap: () {
                setState(() => language = 'ps');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('دری'),
              onTap: () {
                setState(() => language = 'fa');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('English'),
              onTap: () {
                setState(() => language = 'en');
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void chooseCurrency() {
    final search = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, sheetSetState) {
            final query = search.text.toLowerCase();

            final codes = rates.keys.where((code) {
              return code.toLowerCase().contains(query) ||
                  displayName(code).toLowerCase().contains(query);
            }).toList()
              ..sort();

            return Directionality(
              textDirection:
                  language == 'en' ? TextDirection.ltr : TextDirection.rtl,
              child: Container(
                height: MediaQuery.of(context).size.height * .85,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: TextField(
                        controller: search,
                        onChanged: (_) => sheetSetState(() {}),
                        decoration: InputDecoration(
                          hintText: t('search'),
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: codes.length,
                        itemBuilder: (_, index) {
                          final code = codes[index];

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green.shade50,
                              child: Text(
                                code.substring(0, 2),
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              displayName(code),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(code),
                            trailing: IconButton(
                              icon: Icon(
                                favorites.contains(code)
                                    ? Icons.star
                                    : Icons.star_border,
                                color: favorites.contains(code)
                                    ? Colors.amber
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                toggleFavorite(code);
                                sheetSetState(() {});
                              },
                            ),
                            onTap: () {
                              selectCurrency(code);
                              Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    final rtl = language != 'en';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        fontFamily: 'Arial',
      ),
      home: Directionality(
        textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: const Color(0xfff4f7f5),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            title: Text(
              t('title'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                onPressed: chooseLanguage,
                icon: const Icon(Icons.language),
              ),
              IconButton(
                onPressed: loadRates,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: loading
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      Text(t('loading')),
                    ],
                  ),
                )
              : error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(25),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_off,
                              size: 70,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 15),
                            Text(
                              error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 20),
                            FilledButton.icon(
                              onPressed: loadRates,
                              icon: const Icon(Icons.refresh),
                              label: Text(t('retry')),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: loadRates,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xff087f23),
                                  Color(0xff31b957),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    '؋',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t('title'),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 23,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        '${rates.length} ${t('available')}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 22),

                          Text(
                            t('amount'),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          TextField(
                            controller: amountController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              prefixIcon:
                                  const Icon(Icons.account_balance_wallet),
                              suffixText: 'AFN',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          Row(
                            children: [
                              Expanded(
                                child: _currencyCard(
                                  'AFN',
                                  'افغانۍ',
                                  Icons.flag,
                                  false,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    final old = selectedCurrency;
                                    selectCurrency('AFN');
                                    setState(() {
                                      selectedCurrency = old;
                                      selectedRate =
                                          rates[old] ?? selectedRate;
                                    });
                                  },
                                  color: Colors.white,
                                  icon: const Icon(Icons.swap_horiz),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _currencyCard(
                                  selectedCurrency,
                                  displayName(selectedCurrency),
                                  Icons.public,
                                  true,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          Container(
                            padding: const EdgeInsets.all(25),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(26),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(.06),
                                  blurRadius: 18,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  t('result'),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  result.toStringAsFixed(2),
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 38,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  selectedCurrency,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  '1 AFN = ${selectedRate.toStringAsFixed(6)} $selectedCurrency',
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 15),

                          FilledButton.icon(
                            onPressed: addHistory,
                            icon: const Icon(Icons.save),
                            label: Text(
                              language == 'ps'
                                  ? 'تاریخچه کې وساته'
                                  : language == 'fa'
                                      ? 'در تاریخچه ذخیره کن'
                                      : 'Save to history',
                            ),
                          ),

                          const SizedBox(height: 20),

                          if (favorites.isNotEmpty)
                            _section(
                              Icons.star,
                              t('favorites'),
                              favorites,
                            ),

                          if (history.isNotEmpty)
                            _historySection(),

                          const SizedBox(height: 20),

                          Text(
                            '${t('lastUpdate')}: $lastUpdate',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Rates By Exchange Rate API',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _currencyCard(
    String code,
    String name,
    IconData icon,
    bool selectable,
  ) {
    return InkWell(
      onTap: selectable ? chooseCurrency : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green.shade100),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.green),
            const SizedBox(height: 7),
            Text(
              code,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(
    IconData icon,
    String title,
    List<String> items,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: items.map((code) {
              return ActionChip(
                label: Text(code),
                onPressed: () => selectCurrency(code),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _historySection() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                t('history'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...history.map(
            (item) => ListTile(
              dense: true,
              leading: const Icon(Icons.swap_horiz),
              title: Text(item),
            ),
          ),
        ],
      ),
    );
  }
}
