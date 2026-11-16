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
        scaffoldBackgroundColor: const Color(0xFFF4F7F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF4F7F8),
          elevation: 0,
        ),
      ),
      home: const ExchangePage(),
    );
  }
}

const Map<String, String> names = {
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
  'ALL': 'Albanian Lek',
  'AMD': 'Armenian Dram',
  'ARS': 'Argentine Peso',
  'AZN': 'Azerbaijani Manat',
  'BAM': 'Bosnia Mark',
  'BGN': 'Bulgarian Lev',
  'BWP': 'Botswana Pula',
  'CLP': 'Chilean Peso',
  'COP': 'Colombian Peso',
  'CZK': 'Czech Koruna',
  'DZD': 'Algerian Dinar',
  'GEL': 'Georgian Lari',
  'GHS': 'Ghanaian Cedi',
  'HUF': 'Hungarian Forint',
  'KES': 'Kenyan Shilling',
  'KZT': 'Kazakhstani Tenge',
  'MAD': 'Moroccan Dirham',
  'MMK': 'Myanmar Kyat',
  'MNT': 'Mongolian Tugrik',
  'NGN': 'Nigerian Naira',
  'PHP': 'Philippine Peso',
  'PLN': 'Polish Zloty',
  'RON': 'Romanian Leu',
  'RSD': 'Serbian Dinar',
  'TWD': 'Taiwan Dollar',
  'TZS': 'Tanzanian Shilling',
  'UAH': 'Ukrainian Hryvnia',
  'UGX': 'Ugandan Shilling',
  'UYU': 'Uruguayan Peso',
  'VND': 'Vietnamese Dong',
  'XAF': 'Central African CFA Franc',
  'XOF': 'West African CFA Franc',
  'XPF': 'CFP Franc',
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
  'ALL': '🇦🇱', 'AMD': '🇦🇲', 'ARS': '🇦🇷',
  'AZN': '🇦🇿', 'BAM': '🇧🇦', 'BGN': '🇧🇬',
  'CLP': '🇨🇱', 'COP': '🇨🇴', 'CZK': '🇨🇿',
  'DZD': '🇩🇿', 'GEL': '🇬🇪', 'GHS': '🇬🇭',
  'HUF': '🇭🇺', 'KES': '🇰🇪', 'KZT': '🇰🇿',
  'MAD': '🇲🇦', 'MMK': '🇲🇲', 'MNT': '🇲🇳',
  'NGN': '🇳🇬', 'PHP': '🇵🇭', 'PLN': '🇵🇱',
  'RON': '🇷🇴', 'RSD': '🇷🇸', 'TWD': '🇹🇼',
  'TZS': '🇹🇿', 'UAH': '🇺🇦', 'UGX': '🇺🇬',
  'UYU': '🇺🇾', 'VND': '🇻🇳',
};

const Map<String, Map<String, String>> words = {
  'ps': {
    'title': 'افغاني اېکسچېنج',
    'home': 'کور',
    'history': 'تاریخ',
    'about': 'زموږ په اړه',
    'convert': 'د پیسو تبدیلول',
    'amount': 'د پیسو اندازه ولیکئ',
    'from': 'له کوم اسعارو',
    'to': 'کوم اسعارو ته',
    'result': 'د تبدیل پایله',
    'rates': 'د ټولو اسعارو نرخونه',
    'search': 'اسعار ولټوئ...',
    'refresh': 'نرخونه تازه کړئ',
    'loading': 'نرخونه ترلاسه کېږي...',
    'updated': 'وروستی تازه شوی وخت',
    'afghanHistory': 'د افغانستان تاریخ',
    'worldHistory': 'د نړۍ تاریخ',
    'creator': 'د اپ جوړوونکی',
    'quote': 'افغانستان زموږ ویاړ، تاریخ زموږ هویت او راتلونکی زموږ په لاس کې دی.',
    'afghanText': 'افغانستان د لرغوني تاریخ، بډایه کلتور او ښکلو طبیعي سیمو لرونکی هېواد دی. کابل، بلخ، هرات، غزني او کندهار د دې خاورې له مشهورو تاریخي ښارونو څخه دي. افغانستان د ورېښمو لارې پر مهمه برخه پروت و او د بېلابېلو تمدنونو د تګ راتګ مرکز پاتې شوی دی.',
    'worldText': 'د نړۍ تاریخ د لرغونو تمدنونو، علمي پرمختګونو، سوداګرۍ او د ملتونو د اړیکو کیسې رانغاړي. د مصر، یونان، روم، چین او هند تمدنونو د نړۍ په کلتور، علم او ټولنیز ژوند کې مهم رول لوبولی دی.',
    'source': 'د نرخونو سرچینه: ExchangeRate-API',
    'error': 'د نرخونو په ترلاسه کولو کې ستونزه ده',
    'noRates': 'نرخونه پیدا نه شول',
    'swap': 'بدلول',
    'calculate': 'حساب کړه',
    'saved': 'د تبدیل تاریخچه',
  },
  'fa': {
    'title': 'افغانی اکسچنج',
    'home': 'خانه',
    'history': 'تاریخ',
    'about': 'درباره ما',
    'convert': 'تبدیل پول',
    'amount': 'مقدار پول را وارد کنید',
    'from': 'از کدام ارز',
    'to': 'به کدام ارز',
    'result': 'نتیجه تبدیل',
    'rates': 'نرخ تمام ارزها',
    'search': 'جستجوی ارز...',
    'refresh': 'تازه کردن نرخ‌ها',
    'loading': 'دریافت نرخ‌ها...',
    'updated': 'آخرین بروزرسانی',
    'afghanHistory': 'تاریخ افغانستان',
    'worldHistory': 'تاریخ جهان',
    'creator': 'سازنده برنامه',
    'quote': 'افغانستان افتخار ما، تاریخ هویت ما و آینده در دستان ماست.',
    'afghanText': 'افغانستان کشوری با تاریخ کهن، فرهنگ غنی و طبیعت زیبا است. کابل، بلخ، هرات، غزنی و قندهار از شهرهای تاریخی مشهور این سرزمین هستند. افغانستان در مسیر مهم جاده ابریشم قرار داشت و مرکز رفت‌وآمد تمدن‌های گوناگون بوده است.',
    'worldText': 'تاریخ جهان داستان تمدن‌های باستانی، پیشرفت علمی، تجارت و روابط ملت‌ها را در بر می‌گیرد. تمدن‌های مصر، یونان، روم، چین و هند نقش مهمی در فرهنگ، دانش و زندگی اجتماعی جهان داشته‌اند.',
    'source': 'منبع نرخ‌ها: ExchangeRate-API',
    'error': 'مشکل در دریافت نرخ‌ها',
    'noRates': 'نرخی پیدا نشد',
    'swap': 'تعویض',
    'calculate': 'محاسبه',
    'saved': 'تاریخچه تبدیل',
  },
  'en': {
    'title': 'Afghani Exchange',
    'home': 'Home',
    'history': 'History',
    'about': 'About',
    'convert': 'Currency Converter',
    'amount': 'Enter amount',
    'from': 'From currency',
    'to': 'To currency',
    'result': 'Conversion result',
    'rates': 'All currency rates',
    'search': 'Search currencies...',
    'refresh': 'Refresh rates',
    'loading': 'Loading rates...',
    'updated': 'Last updated',
    'afghanHistory': 'History of Afghanistan',
    'worldHistory': 'World History',
    'creator': 'App Creator',
    'quote': 'Afghanistan is our pride, history is our identity, and the future is in our hands.',
    'afghanText': 'Afghanistan is a country with an ancient history, rich culture and beautiful landscapes. Kabul, Balkh, Herat, Ghazni and Kandahar are among its famous historic cities. Afghanistan stood along an important part of the Silk Road and connected many civilizations.',
    'worldText': 'World history includes ancient civilizations, scientific progress, trade and relationships between nations. The civilizations of Egypt, Greece, Rome, China and India played important roles in world culture, knowledge and social life.',
    'source': 'Rate source: ExchangeRate-API',
    'error': 'Problem getting exchange rates',
    'noRates': 'No rates found',
    'swap': 'Swap',
    'calculate': 'Calculate',
    'saved': 'Conversion history',
  },
};

class ExchangePage extends StatefulWidget {
  const ExchangePage({super.key});

  @override
  State<ExchangePage> createState() => _ExchangePageState();
}

class _ExchangePageState extends State<ExchangePage> {
  final amountController = TextEditingController(text: '100');
  final searchController = TextEditingController();

  String language = 'ps';
  String fromCode = 'USD';
  String toCode = 'AFN';
  String search = '';
  int page = 0;

  Map<String, double> rates = {};
  bool loading = false;
  String error = '';
  DateTime? updated;
  Timer? timer;
  final List<String> historyItems = [];

  String tr(String key) => words[language]![key]!;

  @override
  void initState() {
    super.initState();
    loadRates();
    // د وړیا API نرخونه عموماً ورځ کې یو ځل تازه کېږي.
    timer = Timer.periodic(
      const Duration(hours: 12),
      (_) => loadRates(),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    amountController.dispose();
    searchController.dispose();
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
        throw Exception('API error');
      }

      final rawRates = data['rates'] as Map<String, dynamic>;
      final result = <String, double>{'AFN': 1};

      for (final item in rawRates.entries) {
        if (item.value is num && (item.value as num) > 0) {
          result[item.key] = (item.value as num).toDouble();
        }
      }

      if (!mounted) return;

      setState(() {
        rates = result;
        updated = DateTime.now();
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = tr('error');
      });
    } finally {
      client?.close(force: true);
    }
  }

  String flag(String code) => flags[code] ?? '🌐';
  String currencyName(String code) => names[code] ?? code;

  String formatNumber(double value) {
    if (!value.isFinite) return '0';
    if (value.abs() < 0.000001 && value != 0) {
      return value.toStringAsPrecision(5);
    }
    if (value.abs() < 1) return value.toStringAsFixed(5);
    return value.toStringAsFixed(2);
  }

  double get result {
    final amount = double.tryParse(amountController.text) ?? 0;
    final fromRate = rates[fromCode];
    final toRate = rates[toCode];

    if (fromRate == null || toRate == null || fromRate == 0) {
      return 0;
    }

    return amount / fromRate * toRate;
  }

  List<String> get currencyCodes {
    final codes = rates.keys.toList()..sort();

    if (search.trim().isEmpty) return codes;

    return codes.where((code) {
      return code.toLowerCase().contains(search.toLowerCase()) ||
          currencyName(code).toLowerCase().contains(search.toLowerCase());
    }).toList();
  }

  void swap() {
    setState(() {
      final old = fromCode;
      fromCode = toCode;
      toCode = old;
    });
  }

  void saveConversion() {
    final amount = double.tryParse(amountController.text) ?? 0;

    if (amount <= 0 || !rates.containsKey(fromCode) ||
        !rates.containsKey(toCode)) {
      return;
    }

    setState(() {
      historyItems.insert(
        0,
        '${formatNumber(amount)} $fromCode = ${formatNumber(result)} $toCode',
      );
      if (historyItems.length > 50) historyItems.removeLast();
    });
  }

  Future<void> selectCurrency(bool isFrom) async {
    search = '';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            final codes = rates.keys.where((code) {
              return code.toLowerCase().contains(search.toLowerCase()) ||
                  currencyName(code).toLowerCase().contains(search.toLowerCase());
            }).toList()
              ..sort();

            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.78,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: TextField(
                        autofocus: true,
                        onChanged: (value) {
                          modalSetState(() => search = value);
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
                        itemCount: codes.length,
                        itemBuilder: (context, index) {
                          final code = codes[index];
                          return ListTile(
                            leading: Text(
                              flag(code),
                              style: const TextStyle(fontSize: 27),
                            ),
                            title: Text(
                              currencyName(code),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(code),
                            onTap: () {
                              setState(() {
                                if (isFrom) {
                                  fromCode = code;
                                } else {
                                  toCode = code;
                                }
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

  Widget currencySelector(String code, bool isFrom) {
    return InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: () => selectCurrency(isFrom),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F6F5),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            Text(flag(code), style: const TextStyle(fontSize: 27)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    code,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    currencyName(code),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
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
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('convert'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Text(tr('amount')),
          const SizedBox(height: 7),
          TextField(
            controller: amountController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '100',
              prefixIcon: const Icon(Icons.payments_outlined),
              filled: true,
              fillColor: const Color(0xFFF7F9F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(tr('from')),
          const SizedBox(height: 6),
          currencySelector(fromCode, true),
          Center(
            child: IconButton.filled(
              onPressed: swap,
              icon: const Icon(Icons.swap_vert),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF087E70),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          Text(tr('to')),
          const SizedBox(height: 6),
          currencySelector(toCode, false),
          const SizedBox(height: 17),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF075D55), Color(0xFF13A58E)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Text(
                  tr('result'),
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  '${formatNumber(result)} $toCode',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: saveConversion,
              icon: const Icon(Icons.calculate),
              label: Text(tr('calculate')),
            ),
          ),
        ],
      ),
    );
  }

  Widget quickCurrency(String code) {
    return ActionChip(
      avatar: Text(flag(code)),
      label: Text(code),
      onPressed: () {
        setState(() {
          fromCode = code;
          toCode = 'AFN';
        });
      },
    );
  }

  Widget rateRow(String code) {
    final value = rates[code] ?? 0;
    final oneUnitInAFN = code == 'AFN' ? 1.0 : 1 / value;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() {
            fromCode = code;
            toCode = 'AFN';
            page = 0;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
          child: Row(
            children: [
              Text(flag(code), style: const TextStyle(fontSize: 29)),
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
                      currencyName(code),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${formatNumber(oneUnitInAFN)} AFN',
                    style: const TextStyle(
                      color: Color(0xFF087E70),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '1 $code =',
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
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
              colors: [Color(0xFF064C46), Color(0xFF119B83)],
            ),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(27),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.currency_exchange,
                      color: Color(0xFF087E70),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('title'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        Text(
                          tr('rates'),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  DropdownButton<String>(
                    value: language,
                    dropdownColor: Colors.white,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'ps', child: Text('پښتو')),
                      DropdownMenuItem(value: 'fa', child: Text('دری')),
                      DropdownMenuItem(value: 'en', child: Text('English')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => language = value);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.white70, size: 17),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      updated == null
                          ? (loading ? tr('loading') : error)
                          : '${tr('updated')}: ${updated!.toLocal().toString().substring(0, 16)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: loading ? null : loadRates,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(15),
            children: [
              converterCard(),
              const SizedBox(height: 17),
              Text(
                tr('rates'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 7,
                children: [
                  quickCurrency('USD'),
                  quickCurrency('GBP'),
                  quickCurrency('EUR'),
                  quickCurrency('SAR'),
                  quickCurrency('PKR'),
                  quickCurrency('AED'),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                onChanged: (value) => setState(() => search = value),
                decoration: InputDecoration(
                  hintText: tr('search'),
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (loading && rates.isEmpty)
                const Center(child: CircularProgressIndicator())
              else if (currencyCodes.isEmpty)
                Center(child: Text(error.isNotEmpty ? error : tr('noRates')))
              else
                ...currencyCodes.map(rateRow),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  tr('source'),
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget historyPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          tr('history'),
          style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (historyItems.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('No conversions saved yet.'),
            ),
          ),
        ...historyItems.map(
          (item) => Card(
            elevation: 0,
            child: ListTile(
              leading: const Icon(
                Icons.currency_exchange,
                color: Color(0xFF087E70),
              ),
              title: Text(item),
            ),
          ),
        ),
        if (historyItems.isNotEmpty)
          TextButton.icon(
            onPressed: () => setState(() => historyItems.clear()),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Clear history'),
          ),
      ],
    );
  }

  Widget historyInfoCard(String title, String description, IconData icon) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF087E70), size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(fontSize: 16, height: 1.8),
            ),
          ],
        ),
      ),
    );
  }

  Widget aboutPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        historyInfoCard(
          tr('afghanHistory'),
          tr('afghanText'),
          Icons.account_balance,
        ),
        historyInfoCard(
          tr('worldHistory'),
          tr('worldText'),
          Icons.public,
        ),
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 31,
                  backgroundColor: Color(0xFF087E70),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  tr('creator'),
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Abdullah ALOKOZAI',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 21,
                    color: Color(0xFF087E70),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  tr('quote'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.7,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final rtl = language != 'en';

    return Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            tr('title'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: page == 0
            ? homePage()
            : page == 1
                ? historyPage()
                : aboutPage(),
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
              icon: const Icon(Icons.info_outline),
              label: tr('about'),
            ),
          ],
        ),
      ),
    );
  }
}
