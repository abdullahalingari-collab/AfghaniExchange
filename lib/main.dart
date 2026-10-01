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
        scaffoldBackgroundColor: const Color(0xfff5f7f6),
        fontFamily: 'Arial',
      ),
      home: const CurrencyHome(),
    );
  }
}

class CurrencyInfo {
  final String code;
  final String name;
  final double rate;

  const CurrencyInfo({
    required this.code,
    required this.name,
    required this.rate,
  });
}

class CurrencyHome extends StatefulWidget {
  const CurrencyHome({super.key});

  @override
  State<CurrencyHome> createState() => _CurrencyHomeState();
}

class _CurrencyHomeState extends State<CurrencyHome> {
  final TextEditingController amountController =
      TextEditingController(text: '1000');

  Timer? timer;

  List<CurrencyInfo> currencies = [];
  List<CurrencyInfo> filteredCurrencies = [];

  String selectedCode = 'USD';
  double selectedRate = 0;

  bool loading = true;
  String? errorMessage;
  String lastUpdate = '';

  double result = 0;

  final Map<String, String> names = {
    'AFN': 'افغانۍ',
    'USD': 'امریکایي ډالر',
    'EUR': 'یورو',
    'GBP': 'برتانوي پونډ',
    'PKR': 'پاکستانۍ روپۍ',
    'INR': 'هندي روپۍ',
    'AED': 'اماراتي درهم',
    'SAR': 'سعودي ریال',
    'TRY': 'ترکي لیره',
    'CNY': 'چینایي یوان',
    'IRR': 'ایراني ریال',
    'CAD': 'کاناډایي ډالر',
    'AUD': 'اسټرالیايي ډالر',
    'JPY': 'جاپاني ین',
    'CHF': 'سویسي فرانک',
    'QAR': 'قطري ریال',
    'KWD': 'کویتي دینار',
    'BHD': 'بحریني دینار',
    'OMR': 'عماني ریال',
    'MYR': 'مالیزیایي رینګټ',
    'RUB': 'روسي روبل',
  };

  @override
  void initState() {
    super.initState();

    loadRates();

    timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => loadRates(silent: true),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    amountController.dispose();
    super.dispose();
  }

  Future<void> loadRates({bool silent = false}) async {
    if (!silent) {
      setState(() {
        loading = true;
        errorMessage = null;
      });
    }

    try {
      final url = Uri.parse(
        'https://open.er-api.com/v6/latest/AFN',
      );

      final response = await http.get(url).timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode != 200) {
        throw Exception('سرور ځواب نه راکوي');
      }

      final data = jsonDecode(response.body);

      if (data['result'] != 'success') {
        throw Exception('د اسعارو معلومات ترلاسه نه شول');
      }

      final Map<String, dynamic> rates =
          Map<String, dynamic>.from(data['rates']);

      final List<CurrencyInfo> list = [];

      rates.forEach((code, value) {
        final rate = (value as num).toDouble();

        list.add(
          CurrencyInfo(
            code: code,
            name: names[code] ?? code,
            rate: rate,
          ),
        );
      });

      list.sort((a, b) => a.code.compareTo(b.code));

      final selected = list.where((e) => e.code == selectedCode);

      setState(() {
        currencies = list;
        filteredCurrencies = list;

        if (selected.isNotEmpty) {
          selectedRate = selected.first.rate;
        } else if (list.isNotEmpty) {
          selectedCode = list.first.code;
          selectedRate = list.first.rate;
        }

        lastUpdate =
            data['time_last_update_utc']?.toString() ?? '';

        loading = false;
        errorMessage = null;
      });

      convert();
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage =
            'د اسعارو معلومات ترلاسه نه شول.\nانټرنېټ وګوره او بیا هڅه وکړه.';
      });
    }
  }

  void convert() {
    final amount =
        double.tryParse(amountController.text.replaceAll(',', '')) ?? 0;

    setState(() {
      result = amount * selectedRate;
    });
  }

  void searchCurrency(String value) {
    final query = value.toLowerCase();

    setState(() {
      filteredCurrencies = currencies.where((currency) {
        return currency.code.toLowerCase().contains(query) ||
            currency.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  void selectCurrency(CurrencyInfo currency) {
    setState(() {
      selectedCode = currency.code;
      selectedRate = currency.rate;
    });

    convert();
    Navigator.pop(context);
  }

  void openCurrencyPicker() {
    final searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final results = currencies.where((currency) {
              final q = searchController.text.toLowerCase();

              return currency.code.toLowerCase().contains(q) ||
                  currency.name.toLowerCase().contains(q);
            }).toList();

            return Directionality(
              textDirection: TextDirection.rtl,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * .85,
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'اسعار وټاکئ',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: searchController,
                        onChanged: (_) {
                          setSheetState(() {});
                        },
                        decoration: InputDecoration(
                          hintText: 'د اسعارو لټون...',
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
                      child: results.isEmpty
                          ? const Center(
                              child: Text(
                                'اسعار ونه موندل شول',
                                style: TextStyle(fontSize: 17),
                              ),
                            )
                          : ListView.builder(
                              itemCount: results.length,
                              itemBuilder: (context, index) {
                                final currency = results[index];

                                return ListTile(
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 4,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        Colors.green.shade50,
                                    child: Text(
                                      currency.code
                                          .substring(
                                            0,
                                            currency.code.length > 2
                                                ? 2
                                                : currency.code.length,
                                          ),
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    currency.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(currency.code),
                                  trailing: Text(
                                    currency.rate
                                        .toStringAsFixed(6),
                                  ),
                                  onTap: () {
                                    selectCurrency(currency);
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          title: const Row(
            children: [
              Icon(Icons.currency_exchange),
              SizedBox(width: 10),
              Text(
                'افغاني ایکسچینج',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () => loadRates(),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),

        body: RefreshIndicator(
          onRefresh: loadRates,
          child: loading
              ? ListView(
                  children: const [
                    SizedBox(height: 250),
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: Text(
                        'د اسعارو معلومات راټولېږي...',
                      ),
                    ),
                  ],
                )
              : errorMessage != null
                  ? ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        const SizedBox(height: 130),
                        Icon(
                          Icons.wifi_off_rounded,
                          size: 70,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 17,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 25),
                        FilledButton.icon(
                          onPressed: () => loadRates(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('بیا هڅه وکړه'),
                        ),
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xff087f23),
                                Color(0xff22a447),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                '🇦🇫 افغانۍ → نړیوال اسعار',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${currencies.length} اسعار موجود دي',
                                style: const TextStyle(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        const Text(
                          'د تبدیلولو اندازه',
                          style: TextStyle(
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
                          onChanged: (_) => convert(),
                          decoration: InputDecoration(
                            hintText: 'مقدار ولیکئ',
                            suffixText: 'AFN',
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon:
                                const Icon(Icons.payments_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        const Text(
                          'د نړۍ اسعار',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        InkWell(
                          onTap: openCurrencyPicker,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.green.shade100,
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      Colors.green.shade50,
                                  child: const Icon(
                                    Icons.public,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        names[selectedCode] ??
                                            selectedCode,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        selectedCode,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.06),
                                blurRadius: 15,
                                offset: const Offset(0, 7),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'پایله',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                result.toStringAsFixed(2),
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                selectedCode,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '1 AFN = ${selectedRate.toStringAsFixed(6)} $selectedCode',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        Text(
                          lastUpdate.isEmpty
                              ? 'د نرخ تازه کېدل: نامعلوم'
                              : 'وروستی تازه کېدل: $lastUpdate',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          'Rates By Exchange Rate API',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
