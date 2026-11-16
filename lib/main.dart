import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

void main() => runApp(const AfghaniExchangeApp());

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
        scaffoldBackgroundColor: const Color(0xFFF3F7F7),
      ),
      home: const ExchangeHome(),
    );
  }
}

const Map<String, String> currencyNames = {
  'AFN': 'Afghan Afghani',
  'USD': 'US Dollar',
  'EUR': 'Euro',
  'GBP': 'British Pound',
  'PKR': 'Pakistani Rupee',
  'INR': 'Indian Rupee',
  'AED': 'UAE Dirham',
  'SAR': 'Saudi Riyal',
  'TRY': 'Turkish Lira',
  'CNY': 'Chinese Yuan',
  'JPY': 'Japanese Yen',
  'CAD': 'Canadian Dollar',
  'AUD': 'Australian Dollar',
  'CHF': 'Swiss Franc',
  'RUB': 'Russian Ruble',
  'IRR': 'Iranian Rial',
  'BDT': 'Bangladeshi Taka',
  'KWD': 'Kuwaiti Dinar',
  'QAR': 'Qatari Riyal',
  'OMR': 'Omani Rial',
  'MYR': 'Malaysian Ringgit',
  'SGD': 'Singapore Dollar',
  'THB': 'Thai Baht',
  'KRW': 'South Korean Won',
  'BRL': 'Brazilian Real',
  'ZAR': 'South African Rand',
  'EGP': 'Egyptian Pound',
  'NPR': 'Nepalese Rupee',
  'LKR': 'Sri Lankan Rupee',
  'SEK': 'Swedish Krona',
  'NOK': 'Norwegian Krone',
  'DKK': 'Danish Krone',
  'NZD': 'New Zealand Dollar',
  'MXN': 'Mexican Peso',
  'HKD': 'Hong Kong Dollar',
  'IDR': 'Indonesian Rupiah',
  'IQD': 'Iraqi Dinar',
  'BHD': 'Bahraini Dinar',
  'JOD': 'Jordanian Dinar',
};

const Map<String, String> flags = {
  'AFN': '🇦🇫', 'USD': '🇺🇸', 'EUR': '🇪🇺',
  'GBP': '🇬🇧', 'PKR': '🇵🇰', 'INR': '🇮🇳',
  'AED': '🇦🇪', 'SAR': '🇸🇦', 'TRY': '🇹🇷',
  'CNY': '🇨🇳', 'JPY': '🇯🇵', 'CAD': '🇨🇦',
  'AUD': '🇦🇺', 'CHF': '🇨🇭', 'RUB': '🇷🇺',
  'IRR': '🇮🇷', 'BDT': '🇧🇩', 'KWD': '🇰🇼',
  'QAR': '🇶🇦', 'OMR': '🇴🇲', 'MYR': '🇲🇾',
  'SGD': '🇸🇬', 'THB': '🇹🇭', 'KRW': '🇰🇷',
  'BRL': '🇧🇷', 'ZAR': '🇿🇦', 'EGP': '🇪🇬',
  'NPR': '🇳🇵', 'LKR': '🇱🇰', 'SEK': '🇸🇪',
  'NOK': '🇳🇴', 'DKK': '🇩🇰', 'NZD': '🇳🇿',
  'MXN': '🇲🇽', 'HKD': '🇭🇰', 'IDR': '🇮🇩',
  'IQD': '🇮🇶', 'BHD': '🇧🇭', 'JOD': '🇯🇴',
};

const Map<String, Map<String, String>> translations = {
  'ps': {
    'title': 'افغاني اېکسچېنج',
    'subtitle': 'د نړۍ د اسعارو نرخونه',
    'one': 'د یوې افغانۍ ارزښت',
    'list': 'د ټولو اسعارو نرخونه',
    'search': 'اسعار ولټوئ...',
    'loading': 'نرخونه ترلاسه کېږي...',
    'refresh': 'نرخونه تازه کړئ',
    'updated': 'وروستی تازه شوی وخت',
    'history': 'د افغانستان تاریخ',
    'world': 'د نړۍ تاریخ',
    'creator': 'د اپ جوړوونکی',
    'home': 'کور',
    'info': 'تاریخ او معلومات',
    'error': 'د نرخونو په ترلاسه کولو کې ستونزه ده',
    'noRates': 'تر اوسه نرخونه نشته',
    'afghanText':
        'افغانستان یو لرغونی تاریخ لري. کابل، بلخ، هرات، غزني او کندهار د دې خاورې له مهمو تاریخي ښارونو څخه دي. افغانستان د ورېښمو لارې او د بېلابېلو تمدنونو د تېرېدو مهمه سیمه وه.',
    'worldText':
        'د نړۍ تاریخ د لرغونو تمدنونو، علمي پرمختګونو، سوداګرۍ او د ملتونو د اړیکو کیسې رانغاړي. د مصر، یونان، روم، چین او هند تمدنونو د نړۍ په تاریخ کې مهم رول لوبولی دی.',
    'source': 'د نرخونو سرچینه: ExchangeRate-API',
  },
  'fa': {
    'title': 'افغانی اکسچنج',
    'subtitle': 'نرخ ارزهای جهان',
    'one': 'ارزش یک افغانی',
    'list': 'نرخ تمام ارزها',
    'search': 'جستجوی ارز...',
    'loading': 'دریافت نرخ‌ها...',
    'refresh': 'تازه کردن نرخ‌ها',
    'updated': 'آخرین بروزرسانی',
    'history': 'تاریخ افغانستان',
    'world': 'تاریخ جهان',
    'creator': 'سازنده برنامه',
    'home': 'خانه',
    'info': 'تاریخ و معلومات',
    'error': 'مشکل در دریافت نرخ‌ها',
    'noRates': 'هنوز نرخی موجود نیست',
    'afghanText':
        'افغانستان دارای تاریخ کهن است. کابل، بلخ، هرات، غزنی و قندهار از شهرهای تاریخی مهم این سرزمین هستند. افغانستان منطقه مهمی در مسیر جاده ابریشم و رفت‌وآمد تمدن‌های گوناگون بوده است.',
    'worldText':
        'تاریخ جهان داستان تمدن‌های باستانی، پیشرفت علمی، تجارت و روابط ملت‌ها را در بر می‌گیرد. تمدن‌های مصر، یونان، روم، چین و هند نقش مهمی در تاریخ جهان داشته‌اند.',
    'source': 'منبع نرخ‌ها: ExchangeRate-API',
  },
  'en': {
    'title': 'Afghani Exchange',
    'subtitle': 'World currency exchange rates',
    'one': 'Value of one Afghani',
    'list': 'All currency rates',
    'search': 'Search currencies...',
    'loading': 'Loading rates...',
    'refresh': 'Refresh rates',
    'updated': 'Last updated',
    'history': 'Afghanistan History',
    'world': 'World History',
    'creator': 'App Creator',
    'home': 'Home',
    'info': 'History & Information',
    'error': 'Problem getting rates',
    'noRates': 'No rates available yet',
    'afghanText':
        'Afghanistan has a long history. Kabul, Balkh, Herat, Ghazni and Kandahar are among its important historic cities. Afghanistan was an important region along the Silk Road and a meeting place for different civilizations.',
    'worldText':
        'World history includes ancient civilizations, scientific progress, trade and relationships between nations. The civilizations of Egypt, Greece, Rome, China and India played important roles in world history.',
    'source': 'Rate source: ExchangeRate-API',
  },
};

class ExchangeHome extends StatefulWidget {
  const ExchangeHome({super.key});

  @override
  State<ExchangeHome> createState() => _ExchangeHomeState();
}

class _ExchangeHomeState extends State<ExchangeHome> {
  String language = 'ps';
  String search = '';
  int page = 0;

  Map<String, double> rates = {};
  bool loading = false;
  String error = '';
  DateTime? updated;
  Timer? timer;

  String t(String key) => translations[language]![key]!;

  @override
  void initState() {
    super.initState();
    loadRates();
    timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => loadRates(),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> loadRates() async {
    if (loading) return;

    setState(() {
      loading = true;
      error = '';
    });

    HttpClient? client;

    try {
      client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 20);

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
        if (entry.value is num && (entry.value as num) > 0) {
          newRates[entry.key] = (entry.value as num).toDouble();
        }
      }

      if (!mounted) return;

      setState(() {
        rates = newRates;
        updated = DateTime.now();
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = t('error');
      });
    } finally {
      client?.close(force: true);
    }
  }

  String getFlag(String code) => flags[code] ?? '🌐';

  String getName(String code) => currencyNames[code] ?? code;

  String getRateText(double rate) {
    if (rate == 0) return '0';
    if (rate.abs() < 0.0001) return rate.toStringAsPrecision(5);
    if (rate.abs() < 1) return rate.toStringAsFixed(6);
    return rate.toStringAsFixed(4);
  }

  List<String> get filteredCodes {
    final codes = rates.keys.toList()..sort();

    if (search.trim().isEmpty) return codes;

    return codes.where((code) {
      return code.toLowerCase().contains(search.toLowerCase()) ||
          getName(code).toLowerCase().contains(search.toLowerCase());
    }).toList();
  }

  Widget rateRow(String code) {
    final rate = rates[code] ?? 0;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 13,
        ),
        child: Row(
          children: [
            Text(getFlag(code), style: const TextStyle(fontSize: 27)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    code,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    getName(code),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  getRateText(rate),
                  style: const TextStyle(
                    color: Color(0xFF087E70),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  '1 AFN =',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget homePage() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF075D55), Color(0xFF13A58E)],
            ),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t('title'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                t('subtitle'),
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.language, color: Colors.white),
                  const SizedBox(width: 8),
                  const Spacer(),
                  DropdownButton<String>(
                    value: language,
                    dropdownColor: Colors.white,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: 'ps',
                        child: Text('پښتو'),
                      ),
                      DropdownMenuItem(
                        value: 'fa',
                        child: Text('دری'),
                      ),
                      DropdownMenuItem(
                        value: 'en',
                        child: Text('English'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => language = value);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 5),
          child: Card(
            elevation: 0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green.shade100,
                child: Icon(
                  loading ? Icons.sync : Icons.currency_exchange,
                  color: Colors.green.shade800,
                ),
              ),
              title: Text(
                loading ? t('loading') : t('one'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                updated == null
                    ? (error.isNotEmpty ? error : t('noRates'))
                    : '${t('updated')}: ${updated!.toLocal().toString().substring(0, 16)}',
              ),
              trailing: IconButton(
                onPressed: loading ? null : loadRates,
                icon: const Icon(Icons.refresh),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 5, 14, 10),
          child: TextField(
            onChanged: (value) => setState(() => search = value),
            decoration: InputDecoration(
              hintText: t('search'),
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  t('list'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${filteredCodes.length}',
                style: const TextStyle(
                  color: Color(0xFF087E70),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: loading && rates.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : filteredCodes.isEmpty
                  ? Center(child: Text(t('noRates')))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(14, 5, 14, 15),
                      itemCount: filteredCodes.length,
                      itemBuilder: (context, index) {
                        return rateRow(filteredCodes[index]);
                      },
                    ),
        ),
      ],
    );
  }

  Widget historyCard(String title, String text, IconData icon) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF087E70), size: 27),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              text,
              style: const TextStyle(fontSize: 16, height: 1.8),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        historyCard(
          t('history'),
          t('afghanText'),
          Icons.account_balance,
        ),
        historyCard(
          t('world'),
          t('worldText'),
          Icons.public,
        ),
        Card(
          elevation: 0,
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text(t('creator')),
            subtitle: const Text(
              'Abdullah ALOKOZAI',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            t('source'),
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          page == 0 ? t('title') : t('info'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: page == 0 ? homePage() : infoPage(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: page,
        onDestinationSelected: (value) {
          setState(() => page = value);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.currency_exchange),
            label: t('home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_edu),
            label: t('info'),
          ),
        ],
      ),
    );
  }
}
