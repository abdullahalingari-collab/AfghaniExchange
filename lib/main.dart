import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

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
        colorSchemeSeed: const Color(0xFF087E70),
        scaffoldBackgroundColor: const Color(0xFFF4F7F8),
        fontFamily: 'Roboto',
      ),
      home: const HomePage(),
    );
  }
}

class Currency {
  final String code;
  final String name;
  final String flag;
  const Currency(this.code, this.name, this.flag);
}

const currencies = <Currency>[
  Currency('AFN', 'Afghan Afghani', '🇦🇫'),
  Currency('USD', 'US Dollar', '🇺🇸'),
  Currency('EUR', 'Euro', '🇪🇺'),
  Currency('GBP', 'British Pound', '🇬🇧'),
  Currency('PKR', 'Pakistani Rupee', '🇵🇰'),
  Currency('INR', 'Indian Rupee', '🇮🇳'),
  Currency('AED', 'UAE Dirham', '🇦🇪'),
  Currency('SAR', 'Saudi Riyal', '🇸🇦'),
  Currency('TRY', 'Turkish Lira', '🇹🇷'),
  Currency('CNY', 'Chinese Yuan', '🇨🇳'),
  Currency('JPY', 'Japanese Yen', '🇯🇵'),
  Currency('CAD', 'Canadian Dollar', '🇨🇦'),
  Currency('AUD', 'Australian Dollar', '🇦🇺'),
  Currency('CHF', 'Swiss Franc', '🇨🇭'),
  Currency('RUB', 'Russian Ruble', '🇷🇺'),
  Currency('IRR', 'Iranian Rial', '🇮🇷'),
  Currency('BDT', 'Bangladeshi Taka', '🇧🇩'),
  Currency('KWD', 'Kuwaiti Dinar', '🇰🇼'),
  Currency('QAR', 'Qatari Riyal', '🇶🇦'),
  Currency('OMR', 'Omani Rial', '🇴🇲'),
  Currency('MYR', 'Malaysian Ringgit', '🇲🇾'),
  Currency('SGD', 'Singapore Dollar', '🇸🇬'),
  Currency('THB', 'Thai Baht', '🇹🇭'),
  Currency('KRW', 'South Korean Won', '🇰🇷'),
  Currency('BRL', 'Brazilian Real', '🇧🇷'),
  Currency('ZAR', 'South African Rand', '🇿🇦'),
  Currency('EGP', 'Egyptian Pound', '🇪🇬'),
  Currency('NPR', 'Nepalese Rupee', '🇳🇵'),
  Currency('LKR', 'Sri Lankan Rupee', '🇱🇰'),
  Currency('SEK', 'Swedish Krona', '🇸🇪'),
  Currency('NOK', 'Norwegian Krone', '🇳🇴'),
  Currency('DKK', 'Danish Krone', '🇩🇰'),
  Currency('NZD', 'New Zealand Dollar', '🇳🇿'),
  Currency('MXN', 'Mexican Peso', '🇲🇽'),
  Currency('HKD', 'Hong Kong Dollar', '🇭🇰'),
  Currency('IDR', 'Indonesian Rupiah', '🇮🇩'),
  Currency('IQD', 'Iraqi Dinar', '🇮🇶'),
  Currency('BHD', 'Bahraini Dinar', '🇧🇭'),
  Currency('JOD', 'Jordanian Dinar', '🇯🇴'),
  Currency('AFN', 'Afghan Afghani', '🇦🇫'),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final amountController = TextEditingController(text: '1');
  final searchController = TextEditingController();

  String fromCode = 'AFN';
  String toCode = 'USD';
  String language = 'ps';
  String search = '';

  Map<String, double> rates = {'AFN': 1};
  bool loading = false;
  String error = '';
  DateTime? updated;
  Timer? refreshTimer;

  final Set<String> favorites = {'USD', 'EUR', 'PKR'};
  final List<String> history = [];

  final Map<String, Map<String, String>> translations = {
    'ps': {
      'title': 'افغاني اېکسچېنج',
      'convert': 'د اسعارو تبدیلول',
      'amount': 'مقدار ولیکئ',
      'from': 'له',
      'to': 'ته',
      'refresh': 'نرخونه تازه کړئ',
      'favorites': 'زما خوښې',
      'history': 'د تبدیل تاریخچه',
      'home': 'کور',
      'info': 'معلومات',
      'updated': 'وروستی تازه کېدل',
      'search': 'اسعار ولټوئ',
      'result': 'د تبدیل پایله',
      'loading': 'نرخونه ترلاسه کېږي...',
      'error': 'د نرخونو په ترلاسه کولو کې ستونزه ده',
      'afghan': 'د افغانستان تاریخ',
      'world': 'نړیوال تاریخ',
      'creator': 'جوړوونکی',
    },
    'fa': {
      'title': 'افغانی اکسچنج',
      'convert': 'تبدیل ارز',
      'amount': 'مقدار را وارد کنید',
      'from': 'از',
      'to': 'به',
      'refresh': 'تازه کردن نرخ‌ها',
      'favorites': 'علاقه‌مندی‌ها',
      'history': 'تاریخچه تبدیل',
      'home': 'خانه',
      'info': 'معلومات',
      'updated': 'آخرین بروزرسانی',
      'search': 'جستجوی ارز',
      'result': 'نتیجه تبدیل',
      'loading': 'دریافت نرخ‌ها...',
      'error': 'مشکل در دریافت نرخ‌ها',
      'afghan': 'تاریخ افغانستان',
      'world': 'تاریخ جهان',
      'creator': 'سازنده',
    },
    'en': {
      'title': 'Afghani Exchange',
      'convert': 'Currency Converter',
      'amount': 'Enter amount',
      'from': 'From',
      'to': 'To',
      'refresh': 'Refresh rates',
      'favorites': 'Favorites',
      'history': 'Conversion history',
      'home': 'Home',
      'info': 'Information',
      'updated': 'Last updated',
      'search': 'Search currencies',
      'result': 'Conversion result',
      'loading': 'Getting rates...',
      'error': 'Problem getting rates',
      'afghan': 'Afghanistan History',
      'world': 'World History',
      'creator': 'Creator',
    },
  };

  String tr(String key) => translations[language]?[key] ?? key;

  @override
  void initState() {
    super.initState();
    fetchRates();
    refreshTimer = Timer.periodic(
      const Duration(minutes: 1),
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

    HttpClient? client;
    try {
      client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 15);

      final request = await client.getUrl(
        Uri.parse('https://open.er-api.com/v6/latest/AFN'),
      );
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final data = jsonDecode(body) as Map<String, dynamic>;
      if (data['result'] != 'success') {
        throw Exception('Rate service unavailable');
      }

      final rawRates = data['rates'] as Map<String, dynamic>;
      final newRates = <String, double>{'AFN': 1};

      for (final entry in rawRates.entries) {
        final value = entry.value;
        if (value is num && value > 0) {
          newRates[entry.key] = value.toDouble();
        }
      }

      if (!mounted) return;
      setState(() {
        rates = newRates;
        updated = DateTime.now();
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = tr('error');
      });
    } finally {
      client?.close(force: true);
    }
  }

  Currency currency(String code) {
    return currencies.firstWhere(
      (c) => c.code == code,
      orElse: () => Currency(code, code, '🌐'),
    );
  }

  double get convertedAmount {
    final amount = double.tryParse(amountController.text) ?? 0;
    final fromRate = rates[fromCode];
    final toRate = rates[toCode];

    if (fromRate == null || toRate == null || fromRate == 0) return 0;
    return amount / fromRate * toRate;
  }

  String money(double value) {
    return value.toStringAsFixed(value.abs() < 1 ? 6 : 2);
  }

  void swapCurrencies() {
    setState(() {
      final old = fromCode;
      fromCode = toCode;
      toCode = old;
    });
  }

  void addHistory() {
    final text =
        '${amountController.text} $fromCode = ${money(convertedAmount)} $toCode';
    setState(() {
      history.insert(0, text);
      if (history.length > 30) history.removeLast();
    });
  }

  void chooseCurrency(bool isFrom) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            final filtered = currencies
                .where((c) =>
                    c.code.toLowerCase().contains(search.toLowerCase()) ||
                    c.name.toLowerCase().contains(search.toLowerCase()))
                .toList();

            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        onChanged: (v) {
                          modalSetState(() => search = v);
                        },
                        decoration: InputDecoration(
                          hintText: tr('search'),
                          prefixIcon: const Icon(Icons.search),
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
                          return ListTile(
                            leading: Text(c.flag,
                                style: const TextStyle(fontSize: 25)),
                            title: Text(c.name),
                            subtitle: Text(c.code),
                            trailing: IconButton(
                              icon: Icon(
                                favorites.contains(c.code)
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.orange,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (!favorites.add(c.code)) {
                                    favorites.remove(c.code);
                                  }
                                });
                                modalSetState(() {});
                              },
                            ),
                            onTap: () {
                              setState(() {
                                if (isFrom) {
                                  fromCode = c.code;
                                } else {
                                  toCode = c.code;
                                }
                                search = '';
                              });
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

  Widget currencyButton(String code, bool isFrom) {
    final c = currency(code);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => chooseCurrency(isFrom),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F5F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            Text(c.flag, style: const TextStyle(fontSize: 27)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.code,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17)),
                  Text(c.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }

  Widget converterCard() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr('convert'),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 18),
            Text(tr('amount')),
            const SizedBox(height: 7),
            TextField(
              controller: amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.payments_outlined),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 18),
            Text(tr('from')),
            const SizedBox(height: 7),
            currencyButton(fromCode, true),
            Center(
              child: IconButton.filled(
                onPressed: swapCurrencies,
                icon: const Icon(Icons.swap_vert),
                tooltip: 'Swap',
              ),
            ),
            Text(tr('to')),
            const SizedBox(height: 7),
            currencyButton(toCode, false),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF087E70), Color(0xFF13A58E)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Text(tr('result'),
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 7),
                  Text(
                    '${money(convertedAmount)} $toCode',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: addHistory,
                icon: const Icon(Icons.save_outlined),
                label: Text(tr('history')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget rateStatus() {
    return Card(
      elevation: 0,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: loading ? Colors.orange.shade100 : Colors.green.shade100,
          child: Icon(
            loading ? Icons.sync : Icons.check_circle,
            color: loading ? Colors.orange : Colors.green,
          ),
        ),
        title: Text(loading ? tr('loading') : tr('refresh')),
        subtitle: Text(
          updated == null
              ? (error.isNotEmpty ? error : '—')
              : '${tr('updated')}: ${updated!.toLocal().toString().substring(0, 16)}',
        ),
        trailing: IconButton(
          onPressed: loading ? null : fetchRates,
          icon: const Icon(Icons.refresh),
        ),
      ),
    );
  }

  Widget favoritesCard() {
    final list = favorites.toList()..sort();
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr('favorites'),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: list.map((code) {
                final c = currency(code);
                return ActionChip(
                  avatar: Text(c.flag),
                  label: Text(code),
                  onPressed: () {
                    setState(() {
                      toCode = code;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget historyPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(tr('history'),
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (history.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('No conversion history yet.'),
            ),
          ),
        ...history.map((item) => Card(
              child: ListTile(
                leading: const Icon(Icons.history),
                title: Text(item),
              ),
            )),
        TextButton.icon(
          onPressed: () => setState(() => history.clear()),
          icon: const Icon(Icons.delete_outline),
          label: const Text('Clear history'),
        ),
      ],
    );
  }

  Widget infoPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(tr('afghan'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'افغانستان اوږد او لرغونی تاریخ لري. د دې خاورې ښارونه، کلتورونه او تاریخي سیمې د سیمې په تاریخ کې مهم ځای لري. کابل، بلخ، هرات، غزني او کندهار د افغانستان له مشهورو تاریخي ښارونو څخه دي.',
              style: TextStyle(fontSize: 16, height: 1.7),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(tr('world'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'د نړۍ تاریخ د لرغونو تمدنونو، علمي پرمختګونو، سوداګرۍ او د بېلابېلو ملتونو د اړیکو کیسې رانغاړي. د مصر، یونان، روم، چین او هند تمدنونو د نړۍ په تاریخ کې مهم رول لوبولی دی.',
              style: TextStyle(fontSize: 16, height: 1.7),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: ListTile(
            leading: const Icon(Icons.person, color: Color(0xFF087E70)),
            title: Text(tr('creator')),
            subtitle: const Text(
              'Abdullah ALOKOZAI',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  int page = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF075D55), Color(0xFF13A58E)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr('title'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 7),
                const Text(
                  'AFN  •  WORLD CURRENCIES',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.language, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text('Language',
                        style: TextStyle(color: Colors.white)),
                    const Spacer(),
                    DropdownButton<String>(
                      value: language,
                      dropdownColor: Colors.white,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'ps', child: Text('پښتو')),
                        DropdownMenuItem(value: 'fa', child: Text('دری')),
                        DropdownMenuItem(value: 'en', child: Text('English')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => language = v);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          rateStatus(),
          const SizedBox(height: 14),
          converterCard(),
          const SizedBox(height: 14),
          favoritesCard(),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Abdullah ALOKOZAI',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
      historyPage(),
      infoPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('title'),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: pages[page],
      bottomNavigationBar: NavigationBar(
        selectedIndex: page,
        onDestinationSelected: (value) => setState(() => page = value),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.currency_exchange),
            label: tr('home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.history),
            label: tr('history'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.public),
            label: tr('info'),
          ),
        ],
      ),
    );
  }
}
