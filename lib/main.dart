import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AfghaniExchangeApp());
}

class Currency {
  final String code;
  final String flag;
  final String name;

  const Currency(this.code, this.flag, this.name);
}

const Map<String, Currency> currencies = {
  'AFN': Currency('AFN', '🇦🇫', 'Afghan Afghani'),
  'USD': Currency('USD', '🇺🇸', 'US Dollar'),
  'EUR': Currency('EUR', '🇪🇺', 'Euro'),
  'GBP': Currency('GBP', '🇬🇧', 'British Pound'),
  'PKR': Currency('PKR', '🇵🇰', 'Pakistani Rupee'),
  'INR': Currency('INR', '🇮🇳', 'Indian Rupee'),
  'IRR': Currency('IRR', '🇮🇷', 'Iranian Rial'),
  'AED': Currency('AED', '🇦🇪', 'UAE Dirham'),
  'SAR': Currency('SAR', '🇸🇦', 'Saudi Riyal'),
  'TRY': Currency('TRY', '🇹🇷', 'Turkish Lira'),
  'CNY': Currency('CNY', '🇨🇳', 'Chinese Yuan'),
  'JPY': Currency('JPY', '🇯🇵', 'Japanese Yen'),
  'CAD': Currency('CAD', '🇨🇦', 'Canadian Dollar'),
  'AUD': Currency('AUD', '🇦🇺', 'Australian Dollar'),
  'CHF': Currency('CHF', '🇨🇭', 'Swiss Franc'),
  'RUB': Currency('RUB', '🇷🇺', 'Russian Ruble'),
  'BDT': Currency('BDT', '🇧🇩', 'Bangladeshi Taka'),
  'QAR': Currency('QAR', '🇶🇦', 'Qatari Riyal'),
  'KWD': Currency('KWD', '🇰🇼', 'Kuwaiti Dinar'),
  'OMR': Currency('OMR', '🇴🇲', 'Omani Rial'),
  'BHD': Currency('BHD', '🇧🇭', 'Bahraini Dinar'),
  'MYR': Currency('MYR', '🇲🇾', 'Malaysian Ringgit'),
  'IDR': Currency('IDR', '🇮🇩', 'Indonesian Rupiah'),
  'SGD': Currency('SGD', '🇸🇬', 'Singapore Dollar'),
  'THB': Currency('THB', '🇹🇭', 'Thai Baht'),
  'KRW': Currency('KRW', '🇰🇷', 'South Korean Won'),
  'HKD': Currency('HKD', '🇭🇰', 'Hong Kong Dollar'),
  'NZD': Currency('NZD', '🇳🇿', 'New Zealand Dollar'),
  'NPR': Currency('NPR', '🇳🇵', 'Nepalese Rupee'),
  'LKR': Currency('LKR', '🇱🇰', 'Sri Lankan Rupee'),
  'IQD': Currency('IQD', '🇮🇶', 'Iraqi Dinar'),
  'EGP': Currency('EGP', '🇪🇬', 'Egyptian Pound'),
  'ZAR': Currency('ZAR', '🇿🇦', 'South African Rand'),
  'BRL': Currency('BRL', '🇧🇷', 'Brazilian Real'),
  'MXN': Currency('MXN', '🇲🇽', 'Mexican Peso'),
  'ARS': Currency('ARS', '🇦🇷', 'Argentine Peso'),
  'SEK': Currency('SEK', '🇸🇪', 'Swedish Krona'),
  'NOK': Currency('NOK', '🇳🇴', 'Norwegian Krone'),
  'DKK': Currency('DKK', '🇩🇰', 'Danish Krone'),
  'PLN': Currency('PLN', '🇵🇱', 'Polish Zloty'),
  'CZK': Currency('CZK', '🇨🇿', 'Czech Koruna'),
  'HUF': Currency('HUF', '🇭🇺', 'Hungarian Forint'),
  'RON': Currency('RON', '🇷🇴', 'Romanian Leu'),
  'UAH': Currency('UAH', '🇺🇦', 'Ukrainian Hryvnia'),
  'GEL': Currency('GEL', '🇬🇪', 'Georgian Lari'),
  'KZT': Currency('KZT', '🇰🇿', 'Kazakhstani Tenge'),
  'UZS': Currency('UZS', '🇺🇿', 'Uzbekistani Som'),
  'TJS': Currency('TJS', '🇹🇯', 'Tajikistani Somoni'),
  'KGS': Currency('KGS', '🇰🇬', 'Kyrgyzstani Som'),
  'MNT': Currency('MNT', '🇲🇳', 'Mongolian Tugrik'),
  'VND': Currency('VND', '🇻🇳', 'Vietnamese Dong'),
  'PHP': Currency('PHP', '🇵🇭', 'Philippine Peso'),
  'ILS': Currency('ILS', '🇮🇱', 'Israeli Shekel'),
  'JOD': Currency('JOD', '🇯🇴', 'Jordanian Dinar'),
  'LBP': Currency('LBP', '🇱🇧', 'Lebanese Pound'),
  'DZD': Currency('DZD', '🇩🇿', 'Algerian Dinar'),
  'MAD': Currency('MAD', '🇲🇦', 'Moroccan Dirham'),
  'TND': Currency('TND', '🇹🇳', 'Tunisian Dinar'),
  'NGN': Currency('NGN', '🇳🇬', 'Nigerian Naira'),
  'KES': Currency('KES', '🇰🇪', 'Kenyan Shilling'),
  'GHS': Currency('GHS', '🇬🇭', 'Ghanaian Cedi'),
  'ETB': Currency('ETB', '🇪🇹', 'Ethiopian Birr'),
  'XOF': Currency('XOF', '🌍', 'West African CFA Franc'),
  'XAF': Currency('XAF', '🌍', 'Central African CFA Franc'),
  'XPF': Currency('XPF', '🌊', 'CFP Franc'),
  'CLP': Currency('CLP', '🇨🇱', 'Chilean Peso'),
  'COP': Currency('COP', '🇨🇴', 'Colombian Peso'),
  'PEN': Currency('PEN', '🇵🇪', 'Peruvian Sol'),
  'UYU': Currency('UYU', '🇺🇾', 'Uruguayan Peso'),
  'ISK': Currency('ISK', '🇮🇸', 'Icelandic Krona'),
  'BGN': Currency('BGN', '🇧🇬', 'Bulgarian Lev'),
  'RSD': Currency('RSD', '🇷🇸', 'Serbian Dinar'),
  'ALL': Currency('ALL', '🇦🇱', 'Albanian Lek'),
  'AMD': Currency('AMD', '🇦🇲', 'Armenian Dram'),
  'AZN': Currency('AZN', '🇦🇿', 'Azerbaijani Manat'),
  'BYN': Currency('BYN', '🇧🇾', 'Belarusian Ruble'),
  'MDL': Currency('MDL', '🇲🇩', 'Moldovan Leu'),
  'MKD': Currency('MKD', '🇲🇰', 'Macedonian Denar'),
  'BAM': Currency('BAM', '🇧🇦', 'Convertible Mark'),
  'HRK': Currency('HRK', '🇭🇷', 'Croatian Kuna'),
  'JMD': Currency('JMD', '🇯🇲', 'Jamaican Dollar'),
  'TTD': Currency('TTD', '🇹🇹', 'Trinidad Dollar'),
  'DOP': Currency('DOP', '🇩🇴', 'Dominican Peso'),
  'CRC': Currency('CRC', '🇨🇷', 'Costa Rican Colon'),
  'GTQ': Currency('GTQ', '🇬🇹', 'Guatemalan Quetzal'),
  'BWP': Currency('BWP', '🇧🇼', 'Botswana Pula'),
  'MUR': Currency('MUR', '🇲🇺', 'Mauritian Rupee'),
  'NAD': Currency('NAD', '🇳🇦', 'Namibian Dollar'),
  'ZMW': Currency('ZMW', '🇿🇲', 'Zambian Kwacha'),
  'TZS': Currency('TZS', '🇹🇿', 'Tanzanian Shilling'),
  'UGX': Currency('UGX', '🇺🇬', 'Ugandan Shilling'),
  'RWF': Currency('RWF', '🇷🇼', 'Rwandan Franc'),
  'XCD': Currency('XCD', '🇰🇳', 'East Caribbean Dollar'),
  'FJD': Currency('FJD', '🇫🇯', 'Fiji Dollar'),
  'PGK': Currency('PGK', '🇵🇬', 'Papua New Guinea Kina'),
  'BND': Currency('BND', '🇧🇳', 'Brunei Dollar'),
  'MMK': Currency('MMK', '🇲🇲', 'Myanmar Kyat'),
  'KHR': Currency('KHR', '🇰🇭', 'Cambodian Riel'),
  'LAK': Currency('LAK', '🇱🇦', 'Lao Kip'),
  'MVR': Currency('MVR', '🇲🇻', 'Maldivian Rufiyaa'),
  'MOP': Currency('MOP', '🇲🇴', 'Macanese Pataca'),
  'TWD': Currency('TWD', '🇹🇼', 'Taiwan Dollar'),
  'KPW': Currency('KPW', '🇰🇵', 'North Korean Won'),
  'SYP': Currency('SYP', '🇸🇾', 'Syrian Pound'),
  'YER': Currency('YER', '🇾🇪', 'Yemeni Rial'),
  'SDG': Currency('SDG', '🇸🇩', 'Sudanese Pound'),
  'SOS': Currency('SOS', '🇸🇴', 'Somali Shilling'),
  'LYD': Currency('LYD', '🇱🇾', 'Libyan Dinar'),
  'ERN': Currency('ERN', '🇪🇷', 'Eritrean Nakfa'),
  'MZN': Currency('MZN', '🇲🇿', 'Mozambican Metical'),
  'AOA': Currency('AOA', '🇦🇴', 'Angolan Kwanza'),
  'BIF': Currency('BIF', '🇧🇮', 'Burundi Franc'),
  'CDF': Currency('CDF', '🇨🇩', 'Congolese Franc'),
  'DJF': Currency('DJF', '🇩🇯', 'Djiboutian Franc'),
  'GMD': Currency('GMD', '🇬🇲', 'Gambian Dalasi'),
  'GNF': Currency('GNF', '🇬🇳', 'Guinean Franc'),
  'LRD': Currency('LRD', '🇱🇷', 'Liberian Dollar'),
  'SLL': Currency('SLL', '🇸🇱', 'Sierra Leonean Leone'),
  'MGA': Currency('MGA', '🇲🇬', 'Malagasy Ariary'),
  'MWK': Currency('MWK', '🇲🇼', 'Malawian Kwacha'),
  'SZL': Currency('SZL', '🇸🇿', 'Swazi Lilangeni'),
  'LSL': Currency('LSL', '🇱🇸', 'Lesotho Loti'),
  'CVE': Currency('CVE', '🇨🇻', 'Cape Verde Escudo'),
  'STN': Currency('STN', '🇸🇹', 'Sao Tome Dobra'),
  'SCR': Currency('SCR', '🇸🇨', 'Seychellois Rupee'),
  'KMF': Currency('KMF', '🇰🇲', 'Comorian Franc'),
  'MRU': Currency('MRU', '🇲🇷', 'Mauritanian Ouguiya'),
  'TOP': Currency('TOP', '🇹🇴', 'Tongan Paanga'),
  'WST': Currency('WST', '🇼🇸', 'Samoan Tala'),
  'VUV': Currency('VUV', '🇻🇺', 'Vanuatu Vatu'),
  'SBD': Currency('SBD', '🇸🇧', 'Solomon Islands Dollar'),
  'KID': Currency('KID', '🇰🇮', 'Kiribati Dollar'),
  'BTN': Currency('BTN', '🇧🇹', 'Bhutanese Ngultrum'),
  'GYD': Currency('GY', '🇬🇾', 'Guyanese Dollar'),
  'SRD': Currency('SRD', '🇸🇷', 'Surinamese Dollar'),
  'BZD': Currency('BZD', '🇧🇿', 'Belize Dollar'),
  'PAB': Currency('PAB', '🇵🇦', 'Panamanian Balboa'),
  'NIO': Currency('NIO', '🇳🇮', 'Nicaraguan Cordoba'),
  'HNL': Currency('HNL', '🇭🇳', 'Honduran Lempira'),
  'SVC': Currency('SVC', '🇸🇻', 'Salvadoran Colon'),
  'PYG': Currency('PYG', '🇵🇾', 'Paraguayan Guarani'),
  'BOB': Currency('BOB', '🇧🇴', 'Bolivian Boliviano'),
  'VES': Currency('VES', '🇻🇪', 'Venezuelan Bolivar'),
  'BSD': Currency('BSD', '🇧🇸', 'Bahamian Dollar'),
  'BBD': Currency('BBD', '🇧🇧', 'Barbadian Dollar'),
  'XAU': Currency('XAU', '🥇', 'Gold Ounce'),
  'XAG': Currency('XAG', '🥈', 'Silver Ounce'),
};

class AfghaniExchangeApp extends StatelessWidget {
  const AfghaniExchangeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afghani Exchange',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF081525),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF12C99A),
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

  String from = 'AFN';
  String to = 'USD';
  String language = 'ps';

  Map<String, double> rates = {};
  DateTime? updatedAt;
  Timer? refreshTimer;
  bool loading = true;
  String error = '';

  final Map<String, Map<String, String>> words = {
    'ps': {
      'title': 'افغاني اېکسچېنج',
      'subtitle': 'د نړۍ د اسعارو تبادله',
      'convert': 'د اسعارو تبادله',
      'amount': 'مقدار ولیکئ',
      'from': 'له دې څخه',
      'to': 'دې ته',
      'swap': 'اسعار بدل کړئ',
      'result': 'د تبادلې پایله',
      'refresh': 'نرخونه تازه کړئ',
      'updated': 'وروستی تازه کېدل',
      'loading': 'نرخونه ترلاسه کېږي...',
      'error': 'د نرخونو په ترلاسه کولو کې ستونزه ده',
      'search': 'اسعار ولټوئ',
      'creator': 'جوړونکی: Abdullah ALOKOZAI',
      'rates': 'د تبادلې نرخونه',
    },
    'fa': {
      'title': 'افغانی اکسچنج',
      'subtitle': 'تبدیل ارزهای جهان',
      'convert': 'تبدیل ارز',
      'amount': 'مقدار را وارد کنید',
      'from': 'از',
      'to': 'به',
      'swap': 'تغییر ارزها',
      'result': 'نتیجه تبدیل',
      'refresh': 'تازه کردن نرخ‌ها',
      'updated': 'آخرین به‌روزرسانی',
      'loading': 'در حال دریافت نرخ‌ها...',
      'error': 'دریافت نرخ‌ها با مشکل مواجه شد',
      'search': 'جستجوی ارز',
      'creator': 'سازنده: Abdullah ALOKOZAI',
      'rates': 'نرخ ارزها',
    },
    'en': {
      'title': 'Afghani Exchange',
      'subtitle': 'World Currency Converter',
      'convert': 'Currency Converter',
      'amount': 'Enter amount',
      'from': 'From',
      'to': 'To',
      'swap': 'Swap currencies',
      'result': 'Conversion result',
      'refresh': 'Refresh rates',
      'updated': 'Last updated',
      'loading': 'Loading exchange rates...',
      'error': 'Unable to load exchange rates',
      'search': 'Search currencies',
      'creator': 'Created by: Abdullah ALOKOZAI',
      'rates': 'Exchange rates',
    },
  };

  String t(String key) => words[language]![key] ?? key;

  @override
  void initState() {
    super.initState();
    loadRates();
    refreshTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => loadRates(),
    );
  }

  Future<void> loadRates() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      error = '';
    });

    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 15);

      try {
        final request = await client.getUrl(
          Uri.parse('https://open.er-api.com/v6/latest/AFN'),
        );

        request.headers.set('Accept', 'application/json');
        final response = await request.close();

        if (response.statusCode != 200) {
          throw Exception('HTTP ${response.statusCode}');
        }

        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body);

        if (data['result'] != 'success') {
          throw Exception('API request failed');
        }

        final Map<String, double> newRates = {};
        final rawRates = data['rates'] as Map<String, dynamic>;

        newRates['AFN'] = 1.0;

        rawRates.forEach((key, value) {
          if (value is num && value > 0) {
            newRates[key] = value.toDouble();
          }
        });

        if (!mounted) return;

        setState(() {
          rates = newRates;
          updatedAt = DateTime.now();
          loading = false;
        });
      } finally {
        client.close(force: true);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = t('error');
      });
    }
  }

  double get convertedAmount {
    final amount = double.tryParse(amountController.text) ?? 0;
    final sourceRate = rates[from];
    final targetRate = rates[to];

    if (sourceRate == null || targetRate == null || sourceRate == 0) {
      return 0;
    }

    return amount / sourceRate * targetRate;
  }

  String format(double value) {
    return value.toStringAsFixed(4);
  }

  void swapCurrencies() {
    setState(() {
      final old = from;
      from = to;
      to = old;
    });
  }

  Future<void> selectCurrency(bool isFrom) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF14263B),
      isScrollControlled: true,
      builder: (context) {
        String search = '';

        return StatefulBuilder(
          builder: (context, setModalState) {
            final items = rates.keys.where((code) {
              final c = currencies[code];
              final text = '${code} ${c?.name ?? code}';
              return text.toLowerCase().contains(search.toLowerCase());
            }).toList()..sort();

            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: t('search'),
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: const Color(0xFF20354D),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onChanged: (value) {
                          setModalState(() => search = value);
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final code = items[index];
                          final c = currencies[code];

                          return ListTile(
                            leading: Text(
                              c?.flag ?? '🌐',
                              style: const TextStyle(fontSize: 28),
                            ),
                            title: Text(c?.name ?? code),
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

  Widget currencyCard(String title, String code, bool isFrom) {
    final c = currencies[code];

    return Expanded(
      child: InkWell(
        onTap: () => selectCurrency(isFrom),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF172A40),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white60)),
              const SizedBox(height: 12),
              Text(
                '${c?.flag ?? '🌐'}  $code',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              const Row(
                children: [
                  Text('Tap to select'),
                  Icon(Icons.keyboard_arrow_down),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = convertedAmount;
    final source = currencies[from];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF081525),
        title: Row(
          children: [
            const Icon(Icons.currency_exchange,
                color: Color(0xFF12C99A), size: 28),
            const SizedBox(width: 10),
            Text(
              t('title'),
              style: const TextStyle(fontWeight: FontWeight.bold),
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
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF087F70), Color(0xFF123D59)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t('subtitle'),
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 12),
                  const Text(
                    '🌍  150+ Currencies',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loading ? t('loading') : t('updated'),
                    style: const TextStyle(color: Colors.white70),
                  ),
                  if (updatedAt != null)
                    Text(
                      '${updatedAt!.hour.toString().padLeft(2, '0')}:'
                      '${updatedAt!.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(t('convert'),
                style: const TextStyle(
                    fontSize: 21, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: t('amount'),
                prefixIcon: const Icon(Icons.calculate),
                filled: true,
                fillColor: const Color(0xFF172A40),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                currencyCard(t('from'), from, true),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: IconButton.filled(
                    onPressed: swapCurrencies,
                    icon: const Icon(Icons.swap_horiz),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF12C99A),
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
                currencyCard(t('to'), to, false),
              ],
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF14263B),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFF12C99A)),
              ),
              child: Column(
                children: [
                  Text(t('result'),
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 12),
                  Text(
                    '${currencies[to]?.flag ?? '🌐'}  ${format(result)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF12C99A),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(to, style: const TextStyle(color: Colors.white60)),
                  const Divider(height: 30),
                  Text(
                    '1 $from = ${rates[from] == null || rates[to] == null ? '--' : format(rates[to]! / rates[from]!)} $to',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (error.isNotEmpty)
              Text(error, style: const TextStyle(color: Colors.redAccent)),
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
            const SizedBox(height: 28),
            Text(
              t('rates'),
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...['USD', 'EUR', 'PKR', 'INR', 'GBP', 'IRR', 'AED', 'SAR']
                .where((code) => rates.containsKey(code))
                .map((code) {
              final c = currencies[code];
              return Card(
                color: const Color(0xFF172A40),
                child: ListTile(
                  leading: Text(c?.flag ?? '🌐',
                      style: const TextStyle(fontSize: 25)),
                  title: Text(c?.name ?? code),
                  subtitle: Text('1 AFN = ${format(rates[code]!)} $code'),
                  trailing: Text(code),
                ),
              );
            }),
            const SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  const Icon(Icons.currency_exchange,
                      color: Color(0xFF12C99A), size: 35),
                  const SizedBox(height: 8),
                  Text(
                    t('creator'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF12C99A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Afghani Exchange © 2026',
                    style: TextStyle(color: Colors.white38),
                  ),
                ],
              ),
            ),
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
