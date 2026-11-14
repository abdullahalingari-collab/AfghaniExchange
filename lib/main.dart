import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AfghaniExchange());
}

const green = Color(0xFF10C99A);
const dark = Color(0xFF081525);
const panel = Color(0xFF172A40);

const flags = <String, String>{
  'AFN':'🇦🇫','USD':'🇺🇸','EUR':'🇪🇺','GBP':'🇬🇧',
  'PKR':'🇵🇰','INR':'🇮🇳','IRR':'🇮🇷','AED':'🇦🇪',
  'SAR':'🇸🇦','TRY':'🇹🇷','CNY':'🇨🇳','JPY':'🇯🇵',
  'CAD':'🇨🇦','AUD':'🇦🇺','CHF':'🇨🇭','RUB':'🇷🇺',
  'BDT':'🇧🇩','QAR':'🇶🇦','KWD':'🇰🇼','OMR':'🇴🇲',
  'BHD':'🇧🇭','MYR':'🇲🇾','IDR':'🇮🇩','SGD':'🇸🇬',
  'THB':'🇹🇭','KRW':'🇰🇷','HKD':'🇭🇰','NZD':'🇳🇿',
  'NPR':'🇳🇵','LKR':'🇱🇰','IQD':'🇮🇶','EGP':'🇪🇬',
  'ZAR':'🇿🇦','BRL':'🇧🇷','MXN':'🇲🇽','ARS':'🇦🇷',
  'SEK':'🇸🇪','NOK':'🇳🇴','DKK':'🇩🇰','PLN':'🇵🇱',
  'CZK':'🇨🇿','HUF':'🇭🇺','RON':'🇷🇴','UAH':'🇺🇦',
  'GEL':'🇬🇪','KZT':'🇰🇿','UZS':'🇺🇿','TJS':'🇹🇯',
  'KGS':'🇰🇬','MNT':'🇲🇳','VND':'🇻🇳','PHP':'🇵🇭',
  'ILS':'🇮🇱','JOD':'🇯🇴','LBP':'🇱🇧','DZD':'🇩🇿',
  'MAD':'🇲🇦','TND':'🇹🇳','NGN':'🇳🇬','KES':'🇰🇪',
  'GHS':'🇬🇭','ETB':'🇪🇹','CLP':'🇨🇱','COP':'🇨🇴',
  'PEN':'🇵🇪','UYU':'🇺🇾','ISK':'🇮🇸','BGN':'🇧🇬',
  'RSD':'🇷🇸','ALL':'🇦🇱','AMD':'🇦🇲','AZN':'🇦🇿',
  'BYN':'🇧🇾','MDL':'🇲🇩','MKD':'🇲🇰','BAM':'🇧🇦',
  'JMD':'🇯🇲','TTD':'🇹🇹','DOP':'🇩🇴','CRC':'🇨🇷',
  'GTQ':'🇬🇹','BWP':'🇧🇼','MUR':'🇲🇺','NAD':'🇳🇦',
  'ZMW':'🇿🇲','TZS':'🇹🇿','UGX':'🇺🇬','RWF':'🇷🇼',
  'FJD':'🇫🇯','PGK':'🇵🇬','BND':'🇧🇳','MMK':'🇲🇲',
  'KHR':'🇰🇭','LAK':'🇱🇦','MVR':'🇲🇻','MOP':'🇲🇴',
  'TWD':'🇹🇼','KPW':'🇰🇵','SYP':'🇸🇾','YER':'🇾🇪',
  'SDG':'🇸🇩','SOS':'🇸🇴','LYD':'🇱🇾','ERN':'🇪🇷',
  'MZN':'🇲🇿','AOA':'🇦🇴','BIF':'🇧🇮','CDF':'🇨🇩',
  'DJF':'🇩🇯','GMD':'🇬🇲','GNF':'🇬🇳','LRD':'🇱🇷',
  'MGA':'🇲🇬','MWK':'🇲🇼','SZL':'🇸🇿','LSL':'🇱🇸',
  'CVE':'🇨🇻','STN':'🇸🇹','SCR':'🇸🇨','KMF':'🇰🇲',
  'MRU':'🇲🇷','TOP':'🇹🇴','WST':'🇼🇸','VUV':'🇻🇺',
  'SBD':'🇸🇧','BTN':'🇧🇹','GYD':'🇬🇾','SRD':'🇸🇷',
  'BZD':'🇧🇿','PAB':'🇵🇦','NIO':'🇳🇮','HNL':'🇭🇳',
  'PYG':'🇵🇾','BOB':'🇧🇴','VES':'🇻🇪','BSD':'🇧🇸',
  'BBD':'🇧🇧','XOF':'🌍','XAF':'🌍','XPF':'🌊',
};

const names = <String, String>{
  'AFN':'Afghan Afghani',
  'USD':'US Dollar','EUR':'Euro','GBP':'British Pound',
  'PKR':'Pakistani Rupee','INR':'Indian Rupee',
  'IRR':'Iranian Rial','AED':'UAE Dirham',
  'SAR':'Saudi Riyal','TRY':'Turkish Lira',
  'CNY':'Chinese Yuan','JPY':'Japanese Yen',
  'CAD':'Canadian Dollar','AUD':'Australian Dollar',
  'CHF':'Swiss Franc','RUB':'Russian Ruble',
  'BDT':'Bangladeshi Taka','QAR':'Qatari Riyal',
  'KWD':'Kuwaiti Dinar','OMR':'Omani Rial',
  'BHD':'Bahraini Dinar','MYR':'Malaysian Ringgit',
  'IDR':'Indonesian Rupiah','SGD':'Singapore Dollar',
  'THB':'Thai Baht','KRW':'South Korean Won',
  'HKD':'Hong Kong Dollar','NZD':'New Zealand Dollar',
  'NPR':'Nepalese Rupee','LKR':'Sri Lankan Rupee',
  'IQD':'Iraqi Dinar','EGP':'Egyptian Pound',
  'ZAR':'South African Rand','BRL':'Brazilian Real',
  'MXN':'Mexican Peso','ARS':'Argentine Peso',
  'SEK':'Swedish Krona','NOK':'Norwegian Krone',
  'DKK':'Danish Krone','PLN':'Polish Zloty',
  'CZK':'Czech Koruna','HUF':'Hungarian Forint',
  'RON':'Romanian Leu','UAH':'Ukrainian Hryvnia',
  'GEL':'Georgian Lari','KZT':'Kazakhstani Tenge',
  'UZS':'Uzbekistani Som','TJS':'Tajikistani Somoni',
  'KGS':'Kyrgyzstani Som','MNT':'Mongolian Tugrik',
  'VND':'Vietnamese Dong','PHP':'Philippine Peso',
  'ILS':'Israeli Shekel','JOD':'Jordanian Dinar',
  'LBP':'Lebanese Pound','DZD':'Algerian Dinar',
  'MAD':'Moroccan Dirham','TND':'Tunisian Dinar',
  'NGN':'Nigerian Naira','KES':'Kenyan Shilling',
  'GHS':'Ghanaian Cedi','ETB':'Ethiopian Birr',
  'XOF':'West African CFA Franc',
  'XAF':'Central African CFA Franc',
  'XPF':'CFP Franc',
};

const translations = {
  'ps': {
    'title':'افغاني اېکسچېنج',
    'subtitle':'د نړۍ د اسعارو تبادله',
    'amount':'مقدار ولیکئ',
    'from':'له دې څخه','to':'دې ته',
    'result':'د تبادلې پایله',
    'refresh':'نرخونه تازه کړئ',
    'search':'اسعار ولټوئ',
    'rates':'د اسعارو نرخونه',
    'favorites':'زما خوښې',
    'history':'تاریخچه',
    'updated':'د معلوماتو وخت',
    'loading':'نرخونه ترلاسه کېږي...',
    'error':'د نرخونو په ترلاسه کولو کې ستونزه',
    'swap':'اسعار بدل کړئ',
    'creator':'جوړونکی: Abdullah ALOKOZAI',
    'credit':'Rates by Exchangerate.dev',
    'noRates':'نرخونه نشته',
  },
  'fa': {
    'title':'افغانی اکسچنج',
    'subtitle':'تبدیل ارزهای جهان',
    'amount':'مقدار را وارد کنید',
    'from':'از','to':'به',
    'result':'نتیجه تبدیل',
    'refresh':'تازه کردن نرخ‌ها',
    'search':'جستجوی ارز',
    'rates':'نرخ ارزها',
    'favorites':'علاقه‌مندی‌ها',
    'history':'تاریخچه',
    'updated':'زمان اطلاعات',
    'loading':'در حال دریافت نرخ‌ها...',
    'error':'دریافت نرخ‌ها با مشکل مواجه شد',
    'swap':'تغییر ارزها',
    'creator':'سازنده: Abdullah ALOKOZAI',
    'credit':'نرخ‌ها از Exchangerate.dev',
    'noRates':'نرخی موجود نیست',
  },
  'en': {
    'title':'Afghani Exchange',
    'subtitle':'World Currency Exchange',
    'amount':'Enter amount',
    'from':'From','to':'To',
    'result':'Conversion result',
    'refresh':'Refresh rates',
    'search':'Search currencies',
    'rates':'Exchange rates',
    'favorites':'Favorites',
    'history':'History',
    'updated':'Data updated',
    'loading':'Loading rates...',
    'error':'Unable to load rates',
    'swap':'Swap currencies',
    'creator':'Created by: Abdullah ALOKOZAI',
    'credit':'Rates by Exchangerate.dev',
    'noRates':'No rates available',
  },
};

class AfghaniExchange extends StatelessWidget {
  const AfghaniExchange({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afghani Exchange',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: green,
          brightness: Brightness.dark,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final amountController = TextEditingController(text: '1');

  Map<String, double> rates = {};
  Set<String> favorites = {'USD','EUR','PKR'};
  List<String> history = [];

  String from = 'AFN';
  String to = 'USD';
  String language = 'ps';
  String source = '';
  String marketSession = '';
  String? dataUpdatedAt;
  String error = '';

  bool loading = false;
  DateTime? lastRequest;
  Timer? refreshTimer;

  String t(String key) =>
      translations[language]?[key] ?? key;

  @override
  void initState() {
    super.initState();
    loadRates();

    // Free API rates are delayed by 15 minutes.
    refreshTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => loadRates(),
    );
  }

  Future<void> loadRates() async {
    if (!mounted || loading) return;

    setState(() {
      loading = true;
      error = '';
    });

    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);

    try {
      final uri = Uri.parse(
        'https://api.exchangerate.dev/v1/latest/AFN',
      );

      final request = await client.getUrl(uri);
      request.headers.set('Accept', 'application/json');
      request.headers.set('User-Agent', 'AfghaniExchange/1.0');

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final data = jsonDecode(body);

      if (data['result'] != 'success') {
        throw Exception(data['message'] ?? 'API error');
      }

      final raw = data['rates'] as Map<String, dynamic>;
      final Map<String, double> updatedRates = {'AFN': 1.0};

      raw.forEach((code, value) {
        if (value is num && value > 0) {
          updatedRates[code] = value.toDouble();
        }
      });

      if (!updatedRates.containsKey('AFN')) {
        updatedRates['AFN'] = 1.0;
      }

      if (!mounted) return;

      setState(() {
        rates = updatedRates;
        source = data['source']?.toString() ?? '';
        marketSession =
            data['market_session']?.toString() ?? '';
        dataUpdatedAt =
            data['data_updated_at']?.toString();
        lastRequest = DateTime.now();
        loading = false;
        error = '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = t('error');
      });
    } finally {
      client.close(force: true);
    }
  }

  double get converted {
    final amount = double.tryParse(amountController.text) ?? 0;
    final a = rates[from];
    final b = rates[to];

    if (a == null || b == null || a == 0) return 0;
    return amount * b / a;
  }

  String number(double value) {
    if (!value.isFinite) return '--';
    return value.toStringAsFixed(4);
  }

  String flag(String code) => flags[code] ?? '🌐';

  String currencyName(String code) =>
      names[code] ?? code;

  Future<void> chooseCurrency(bool isFrom) async {
    final controller = TextEditingController();

    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: panel,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final codes = rates.keys.where((code) {
              final query = controller.text.toLowerCase();
              return code.toLowerCase().contains(query) ||
                  currencyName(code).toLowerCase().contains(query);
            }).toList()..sort();

            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * .8,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: t('search'),
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onChanged: (_) => setSheetState(() {}),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: codes.length,
                        itemBuilder: (context, index) {
                          final code = codes[index];
                          return ListTile(
                            leading: Text(
                              flag(code),
                              style: const TextStyle(fontSize: 27),
                            ),
                            title: Text(currencyName(code)),
                            subtitle: Text(code),
                            onTap: () => Navigator.pop(context, code),
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

    controller.dispose();

    if (selected != null && mounted) {
      setState(() {
        if (isFrom) {
          from = selected;
        } else {
          to = selected;
        }
      });
    }
  }

  void swap() {
    setState(() {
      final old = from;
      from = to;
      to = old;
    });
  }

  void saveHistory() {
    final amount = double.tryParse(amountController.text) ?? 0;
    if (amount <= 0 || !rates.containsKey(from) ||
        !rates.containsKey(to)) return;

    final entry =
        '${number(amount)} $from = ${number(converted)} $to';

    setState(() {
      history.insert(0, entry);
      if (history.length > 30) history.removeLast();
    });
  }

  Widget currencySelector(String label, String code, bool isFrom) {
    return Expanded(
      child: InkWell(
        onTap: () => chooseCurrency(isFrom),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: panel,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white60)),
              const SizedBox(height: 12),
              Text(
                '${flag(code)}  $code',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                currencyName(code),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
              const SizedBox(height: 5),
              const Icon(Icons.keyboard_arrow_down, color: green),
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: green),
          const SizedBox(width: 9),
          Text(text, style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          )),
        ],
      ),
    );
  }

  Widget rateTile(String code) {
    final rate = rates[code];
    if (rate == null) return const SizedBox.shrink();

    final value = from == 'AFN'
        ? rate
        : rate / (rates[from] ?? 1);

    return Card(
      color: panel,
      child: ListTile(
        leading: Text(flag(code), style: const TextStyle(fontSize: 27)),
        title: Text(currencyName(code)),
        subtitle: Text('1 AFN = ${number(rate)} $code'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(code, style: const TextStyle(color: green)),
            IconButton(
              onPressed: () {
                setState(() {
                  if (favorites.contains(code)) {
                    favorites.remove(code);
                  } else {
                    favorites.add(code);
                  }
                });
              },
              icon: Icon(
                favorites.contains(code)
                    ? Icons.star
                    : Icons.star_border,
                color: Colors.amber,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> openCredit() async {
    final uri = Uri.parse('https://exchangerate.dev/');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final sortedCodes = rates.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: dark,
        title: Row(
          children: [
            const Icon(Icons.currency_exchange, color: green),
            const SizedBox(width: 9),
            Expanded(
              child: Text(t('title'),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (value) => setState(() => language = value),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'ps', child: Text('پښتو')),
              PopupMenuItem(value: 'fa', child: Text('دری')),
              PopupMenuItem(value: 'en', child: Text('English')),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadRates,
        child: ListView(
          padding: const EdgeInsets.all(17),
          children: [
            Container(
              padding: const EdgeInsets.all(23),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF087F70), Color(0xFF123D59)],
                ),
                borderRadius: BorderRadius.circular(23),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t('subtitle'),
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 12),
                  const Text('🌍  144+ Currency Pairs',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.cloud_done, color: Colors.white70),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          loading ? t('loading') :
                          source.isEmpty ? t('noRates') :
                          'Source: $source | $marketSession',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            sectionTitle(t('result'), Icons.currency_exchange),

            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: t('amount'),
                filled: true,
                fillColor: panel,
                prefixIcon: const Icon(Icons.calculate, color: green),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                currencySelector(t('from'), from, true),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: IconButton.filled(
                    onPressed: swap,
                    icon: const Icon(Icons.swap_horiz),
                    style: IconButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
                currencySelector(t('to'), to, false),
              ],
            ),

            const SizedBox(height: 17),

            Container(
              padding: const EdgeInsets.all(23),
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: green),
              ),
              child: Column(
                children: [
                  Text(t('result'),
                      style: const TextStyle(color: Colors.white60)),
                  const SizedBox(height: 12),
                  Text(
                    '${flag(to)} ${number(converted)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 31,
                      color: green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(to, style: const TextStyle(color: Colors.white60)),
                  const SizedBox(height: 12),
                  Text(
                    '1 $from = ${rates[from] == null || rates[to] == null ? '--' : number(rates[to]! / rates[from]!)} $to',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: saveHistory,
                    icon: const Icon(Icons.save),
                    label: Text(t('history')),
                  ),
                ],
              ),
            ),

            if (error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(error,
                    style: const TextStyle(color: Colors.redAccent)),
              ),

            const SizedBox(height: 12),

            FilledButton.icon(
              onPressed: loading ? null : loadRates,
              icon: const Icon(Icons.refresh),
              label: Text(t('refresh')),
            ),

            if (loading)
              const Padding(
                padding: EdgeInsets.all(15),
                child: Center(child: CircularProgressIndicator()),
              ),

            if (dataUpdatedAt != null) ...[
              const SizedBox(height: 12),
              Text(
                '${t('updated')}: $dataUpdatedAt',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],

            sectionTitle(t('favorites'), Icons.star),
            if (rates.isNotEmpty)
              ...favorites.toList()..sort()
            .map((code) => rateTile(code)),

            sectionTitle(t('rates'), Icons.public),
            if (rates.isNotEmpty)
              ...sortedCodes
                  .where((code) => code != 'AFN')
                  .map((code) => rateTile(code)),

            sectionTitle(t('history'), Icons.history),
            if (history.isEmpty)
              const Text('No conversions yet.',
                  style: TextStyle(color: Colors.white54)),
            ...history.map((item) => Card(
              color: panel,
              child: ListTile(
                leading: const Icon(Icons.history, color: green),
                title: Text(item),
              ),
            )),

            const SizedBox(height: 24),

            Center(
              child: Column(
                children: [
                  const Icon(Icons.currency_exchange,
                      color: green, size: 36),
                  const SizedBox(height: 9),
                  Text(t('creator'),
                      style: const TextStyle(
                        color: green,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: openCredit,
                    child: Text(
                      t('credit'),
                      style: const TextStyle(
                        color: Colors.lightBlueAccent,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Afghani Exchange © 2026',
                    style: TextStyle(color: Colors.white38),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    amountController.dispose();
    super.dispose();
  }
}
