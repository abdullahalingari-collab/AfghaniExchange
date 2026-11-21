import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String workerUrl =
    'https://afghani-exchange-api.abdullah-alingari.workers.dev/api/rates';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AfghaniExchangeApp());
}

const Map<String, String> flags = {
  'AFN': '🇦🇫', 'USD': '🇺🇸', 'EUR': '🇪🇺', 'GBP': '🇬🇧',
  'PKR': '🇵🇰', 'INR': '🇮🇳', 'IRR': '🇮🇷', 'CNY': '🇨🇳',
  'TRY': '🇹🇷', 'AED': '🇦🇪', 'SAR': '🇸🇦', 'QAR': '🇶🇦',
  'KWD': '🇰🇼', 'CAD': '🇨🇦', 'AUD': '🇦🇺', 'JPY': '🇯🇵',
  'CHF': '🇨🇭', 'RUB': '🇷🇺', 'SEK': '🇸🇪', 'NOK': '🇳🇴',
  'DKK': '🇩🇰', 'NZD': '🇳🇿', 'SGD': '🇸🇬', 'MYR': '🇲🇾',
  'THB': '🇹🇭', 'BDT': '🇧🇩', 'LKR': '🇱🇰', 'NPR': '🇳🇵',
  'IQD': '🇮🇶', 'OMR': '🇴🇲', 'BHD': '🇧🇭', 'EGP': '🇪🇬',
  'ZAR': '🇿🇦', 'BRL': '🇧🇷', 'KRW': '🇰🇷', 'HKD': '🇭🇰',
  'PLN': '🇵🇱', 'CZK': '🇨🇿', 'HUF': '🇭🇺', 'UAH': '🇺🇦',
  'GEL': '🇬🇪', 'AZN': '🇦🇿', 'KZT': '🇰🇿', 'UZS': '🇺🇿',
  'TJS': '🇹🇯', 'TMT': '🇹🇲', 'KGS': '🇰🇬', 'MNT': '🇲🇳',
  'IDR': '🇮🇩', 'PHP': '🇵🇭', 'VND': '🇻🇳', 'MMK': '🇲🇲',
  'KHR': '🇰🇭', 'LAK': '🇱🇦', 'ARS': '🇦🇷', 'MXN': '🇲🇽',
  'CLP': '🇨🇱', 'COP': '🇨🇴', 'PEN': '🇵🇪', 'NGN': '🇳🇬',
  'KES': '🇰🇪', 'GHS': '🇬🇭', 'MAD': '🇲🇦', 'TND': '🇹🇳',
  'DZD': '🇩🇿', 'ETB': '🇪🇹', 'XAF': '🌍', 'XOF': '🌍',
  'ILS': '🇮🇱', 'JOD': '🇯🇴', 'LBP': '🇱🇧', 'SYP': '🇸🇾',
  'YER': '🇾🇪', 'RON': '🇷🇴', 'BGN': '🇧🇬', 'HRK': '🇭🇷',
  'RSD': '🇷🇸', 'ISK': '🇮🇸', 'ALL': '🇦🇱', 'MDL': '🇲🇩',
};

const Map<String, Map<String, String>> currencyNames = {
  'ps': {
    'AFN': 'افغانۍ', 'USD': 'امریکایي ډالر', 'EUR': 'یورو',
    'GBP': 'برتانوي پونډ', 'PKR': 'پاکستانۍ روپۍ',
    'INR': 'هندي روپۍ', 'IRR': 'ایراني ریال', 'CNY': 'چینایي یوان',
    'TRY': 'ترکي لیره', 'AED': 'اماراتي درهم', 'SAR': 'سعودي ریال',
    'QAR': 'قطري ریال', 'KWD': 'کویتي دینار', 'CAD': 'کاناډایي ډالر',
    'AUD': 'اسټرالیایي ډالر', 'JPY': 'جاپاني ین',
    'CHF': 'سویسي فرانک', 'RUB': 'روسي روبل',
  },
  'fa': {
    'AFN': 'افغانی', 'USD': 'دالر آمریکایی', 'EUR': 'یورو',
    'GBP': 'پوند انگلیس', 'PKR': 'روپیه پاکستانی',
    'INR': 'روپیه هندی', 'IRR': 'ریال ایرانی', 'CNY': 'یوان چین',
    'TRY': 'لیره ترکیه', 'AED': 'درهم امارات', 'SAR': 'ریال سعودی',
    'QAR': 'ریال قطر', 'KWD': 'دینار کویت', 'CAD': 'دالر کانادا',
    'AUD': 'دالر آسترالیا', 'JPY': 'ین جاپان',
    'CHF': 'فرانک سویس', 'RUB': 'روبل روسیه',
  },
  'en': {
    'AFN': 'Afghan Afghani', 'USD': 'US Dollar', 'EUR': 'Euro',
    'GBP': 'British Pound', 'PKR': 'Pakistani Rupee',
    'INR': 'Indian Rupee', 'IRR': 'Iranian Rial', 'CNY': 'Chinese Yuan',
    'TRY': 'Turkish Lira', 'AED': 'UAE Dirham', 'SAR': 'Saudi Riyal',
    'QAR': 'Qatari Riyal', 'KWD': 'Kuwaiti Dinar',
    'CAD': 'Canadian Dollar', 'AUD': 'Australian Dollar',
    'JPY': 'Japanese Yen', 'CHF': 'Swiss Franc', 'RUB': 'Russian Ruble',
  },
};

String money(dynamic value) {
  final n = double.tryParse('$value');
  if (n == null || !n.isFinite) return '—';
  return n.toStringAsFixed(2);
}

double? toNumber(dynamic value) {
  if (value == null) return null;
  return double.tryParse(
    value.toString().replaceAll(',', '').replaceAll(' ', ''),
  );
}

String currencyName(String code, String lang) {
  return currencyNames[lang]?[code] ?? code;
}

class AfghaniExchangeApp extends StatefulWidget {
  const AfghaniExchangeApp({super.key});

  @override
  State<AfghaniExchangeApp> createState() => _AfghaniExchangeAppState();
}

class _AfghaniExchangeAppState extends State<AfghaniExchangeApp> {
  String language = 'ps';
  bool darkMode = false;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      language = p.getString('language') ?? 'ps';
      darkMode = p.getBool('darkMode') ?? false;
    });
  }

  Future<void> setLanguage(String value) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('language', value);
    if (mounted) setState(() => language = value);
  }

  Future<void> setTheme(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('darkMode', value);
    if (mounted) setState(() => darkMode = value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afghani Exchange',
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff07834f),
        ),
        scaffoldBackgroundColor: const Color(0xfff4f6fa),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xff087d50),
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff087d50),
          brightness: Brightness.dark,
        ),
      ),
      home: HomePage(
        language: language,
        darkMode: darkMode,
        onLanguage: setLanguage,
        onTheme: setTheme,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String language;
  final bool darkMode;
  final ValueChanged<String> onLanguage;
  final ValueChanged<bool> onTheme;

  const HomePage({
    super.key,
    required this.language,
    required this.darkMode,
    required this.onLanguage,
    required this.onTheme,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int page = 0;
  bool loading = false;
  String error = '';
  String selectedMarket = 'bank';
  String updatedAt = '';
  Map<String, dynamic> markets = {};
  List<dynamic> world = [];
  String? photoPath;

  final picker = ImagePicker();
  final amountController = TextEditingController(text: '1');
  final fromController = TextEditingController(text: 'USD');
  final toController = TextEditingController(text: 'AFN');

  String get lang => widget.language;

  String tr(String ps, String fa, String en) {
    if (lang == 'fa') return fa;
    if (lang == 'en') return en;
    return ps;
  }

  final Map<String, Map<String, String>> marketLabels = {
    'bank': {
      'ps': 'د افغانستان بانک',
      'fa': 'بانک افغانستان',
      'en': 'Da Afghanistan Bank',
    },
    'sarai': {
      'ps': 'سرای شهزاده',
      'fa': 'سرای شهزاده',
      'en': 'Sarai Shahzada',
    },
    'khorasan': {
      'ps': 'خراسان مارکیټ (هرات)',
      'fa': 'بازار خراسان (هرات)',
      'en': 'Khorasan Market (Herat)',
    },
    'kandahar': {
      'ps': 'کندهار مارکیټ',
      'fa': 'بازار قندهار',
      'en': 'Kandahar Market',
    },
    'nangarhar': {
      'ps': 'ننګرهار صرافۍ (جلال‌اباد)',
      'fa': 'صرافی ننگرهار (جلال‌آباد)',
      'en': 'Nangarhar Exchange (Jalalabad)',
    },
  };

  @override
  void initState() {
    super.initState();
    loadPhoto();
    fetchRates();
  }

  @override
  void dispose() {
    amountController.dispose();
    fromController.dispose();
    toController.dispose();
    super.dispose();
  }

  Future<void> loadPhoto() async {
    final p = await SharedPreferences.getInstance();
    final path = p.getString('developerPhoto');
    if (path != null && File(path).existsSync() && mounted) {
      setState(() => photoPath = path);
    }
  }

  Future<void> changePhoto() async {
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final saved = await File(image.path).copy(
      '${dir.path}/developer_photo.jpg',
    );
    final p = await SharedPreferences.getInstance();
    await p.setString('developerPhoto', saved.path);

    if (mounted) setState(() => photoPath = saved.path);
  }

  Future<void> fetchRates() async {
    setState(() {
      loading = true;
      error = '';
    });

    try {
      final response = await http
          .get(Uri.parse(workerUrl))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      if (data is! Map) throw Exception('Invalid API response');

      final receivedMarkets = data['markets'];
      final receivedWorld = data['world'];

      if (!mounted) return;
      setState(() {
        markets = receivedMarkets is Map
            ? Map<String, dynamic>.from(receivedMarkets)
            : {};
        world = receivedWorld is List ? receivedWorld : [];
        updatedAt = '${data['updatedAt'] ?? ''}';
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  List<Map<String, dynamic>> get selectedRows {
    final market = markets[selectedMarket];
    if (market is! Map || market['rows'] is! List) return [];

    return (market['rows'] as List)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  double? rateFor(String code) {
    for (final row in selectedRows) {
      final label = '${row['label'] ?? ''}'.toUpperCase();
      if (RegExp(r'\b' + RegExp.escape(code) + r'\b').hasMatch(label) ||
          label.startsWith('$code/')) {
        return toNumber(row['buy']) ?? toNumber(row['sell']);
      }
    }

    for (final item in world) {
      if (item is Map &&
          '${item['code'] ?? ''}'.toUpperCase() == code.toUpperCase()) {
        return toNumber(item['afnPerUnit']) ?? toNumber(item['rate']);
      }
    }
    return null;
  }

  double? get conversionResult {
    final amount = toNumber(amountController.text);
    if (amount == null) return null;

    final from = fromController.text.trim().toUpperCase();
    final to = toController.text.trim().toUpperCase();

    if (from == to) return amount;

    final fromRate = rateFor(from);
    final toRate = rateFor(to);

    if (fromRate == null || toRate == null || toRate == 0) return null;
    return amount * fromRate / toRate;
  }

  Widget marketSelector() {
    return SizedBox(
      height: 112,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        children: marketLabels.entries.map((entry) {
          final active = selectedMarket == entry.key;
          final colors = {
            'bank': const Color(0xff07834f),
            'sarai': const Color(0xff0785c4),
            'khorasan': const Color(0xffe17b09),
            'kandahar': const Color(0xff7944ad),
            'nangarhar': const Color(0xffd83f78),
          };

          return GestureDetector(
            onTap: () => setState(() => selectedMarket = entry.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 150,
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colors[entry.key],
                borderRadius: BorderRadius.circular(16),
                border: active
                    ? Border.all(color: Colors.white, width: 3)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: (colors[entry.key] ?? Colors.green).withOpacity(.2),
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_balance, color: Colors.white, size: 25),
                  const SizedBox(height: 7),
                  Text(
                    entry.value[lang] ?? entry.value['en']!,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget marketTable() {
    final rows = selectedRows;
    final label = marketLabels[selectedMarket]?[lang] ?? selectedMarket;
    final market = markets[selectedMarket];
    final rateType = market is Map ? '${market['rateType'] ?? ''}' : '';

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            color: Color(0xff087d50),
            borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
          ),
          child: Row(
            children: [
              const Icon(Icons.currency_exchange, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (rateType.isNotEmpty)
                Text(
                  rateType,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          color: const Color(0xffeaf0f7),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text(tr('اسعار', 'ارز', 'Currency'))),
              Expanded(child: Text(tr('پېر', 'خرید', 'Buy'), textAlign: TextAlign.center)),
              Expanded(child: Text(tr('پلور', 'فروش', 'Sell'), textAlign: TextAlign.center)),
            ],
          ),
        ),
        if (rows.isEmpty)
          Card(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Text(
                loading
                    ? tr('معلومات ترلاسه کېږي...', 'در حال دریافت معلومات...', 'Loading rates...')
                    : tr('د دې بازار نرخونه اوس نشته', 'نرخ این بازار موجود نیست', 'No rates available for this market'),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ...List.generate(rows.length, (index) {
          final row = rows[index];
          final title = '${row['label'] ?? ''}';
          final codeMatch = RegExp(r'([A-Z]{3})').firstMatch(title.toUpperCase());
          final code = codeMatch?.group(1) ?? '';
          final flag = flags[code] ?? '🌐';

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
            decoration: BoxDecoration(
              color: index.isEven
                  ? Theme.of(context).cardColor
                  : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(.35),
              border: const Border(
                bottom: BorderSide(color: Color(0xffe5e9ef)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Text(flag, style: const TextStyle(fontSize: 26)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              currencyName(code, lang),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Theme.of(context).hintColor,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    money(row['buy']),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    money(row['sell']),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xff1598c7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget marketsPage() {
    return RefreshIndicator(
      onRefresh: fetchRates,
      child: ListView(
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff087d50), Color(0xff0754a5)],
              ),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Row(
              children: [
                const Text('🇦🇫', style: TextStyle(fontSize: 38)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Afghani Exchange',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        tr('د اسعارو نرخونه', 'نرخ اسعار', 'Currency exchange rates'),
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: fetchRates,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                ),
              ],
            ),
          ),
          if (updatedAt.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                '${tr('وروستی تازه کول', 'آخرین بروزرسانی', 'Last update')}: $updatedAt',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
          marketSelector(),
          if (error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(error, style: const TextStyle(color: Colors.red)),
            ),
          marketTable(),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(18),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget worldPage() {
    final items = world.whereType<Map>().toList()
      ..sort((a, b) => '${a['code']}'.compareTo('${b['code']}'));

    return RefreshIndicator(
      onRefresh: fetchRates,
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              tr('د نړۍ ټول اسعار', 'تمام ارزهای جهان', 'World currencies'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                tr('اوس مهال معلومات نشته', 'معلومات موجود نیست', 'No data available'),
              ),
            ),
          ...items.map((item) {
            final code = '${item['code'] ?? ''}'.toUpperCase();
            final rate = item['afnPerUnit'] ?? item['rate'];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              child: ListTile(
                leading: Text(flags[code] ?? '🌐', style: const TextStyle(fontSize: 28)),
                title: Text(
                  '$code/AFN',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(currencyName(code, lang)),
                trailing: Text(
                  money(rate),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xff1598c7),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget converterPage() {
    final result = conversionResult;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          tr('د اسعارو تبدیلول', 'تبدیل اسعار', 'Currency converter'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
        ),
        const SizedBox(height: 15),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: tr('مقدار', 'مقدار', 'Amount'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.payments),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: fromController,
                  decoration: InputDecoration(
                    labelText: tr('له کوم اسعارو', 'از کدام ارز', 'From currency'),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 15),
                IconButton.filled(
                  onPressed: () {
                    final old = fromController.text;
                    fromController.text = toController.text;
                    toController.text = old;
                    setState(() {});
                  },
                  icon: const Icon(Icons.swap_vert),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: toController,
                  decoration: InputDecoration(
                    labelText: tr('کوم اسعارو ته', 'به کدام ارز', 'To currency'),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xff07834f), Color(0xff13a66a)],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Text(
                        tr('پایله', 'نتیجه', 'Result'),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        result == null
                            ? '—'
                            : '${money(result)} ${toController.text.toUpperCase()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  tr(
                    'تبدیل د ټاکل شوي بازار د موجود نرخ پر بنسټ کېږي.',
                    'تبدیل بر اساس نرخ موجود بازار انتخاب‌شده انجام می‌شود.',
                    'Conversion uses the available rate from the selected market.',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget settingsPage() {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            tr('تنظیمات', 'تنظیمات', 'Settings'),
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.dark_mode),
          title: Text(tr('تیاره بڼه', 'حالت تاریک', 'Dark mode')),
          value: widget.darkMode,
          onChanged: widget.onTheme,
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(tr('ژبه', 'زبان', 'Language')),
          subtitle: Text(
            lang == 'ps' ? 'پښتو' : lang == 'fa' ? 'دری' : 'English',
          ),
        ),
        RadioListTile<String>(
          value: 'ps',
          groupValue: lang,
          title: const Text('🇦🇫 پښتو'),
          onChanged: (v) {
            if (v != null) widget.onLanguage(v);
          },
        ),
        RadioListTile<String>(
          value: 'fa',
          groupValue: lang,
          title: const Text('🇦🇫 دری'),
          onChanged: (v) {
            if (v != null) widget.onLanguage(v);
          },
        ),
        RadioListTile<String>(
          value: 'en',
          groupValue: lang,
          title: const Text('🇬🇧 English'),
          onChanged: (v) {
            if (v != null) widget.onLanguage(v);
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.refresh),
          title: Text(tr('نرخونه تازه کړه', 'بروزرسانی نرخ‌ها', 'Refresh rates')),
          onTap: fetchRates,
        ),
      ],
    );
  }

  Widget aboutPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 15),
        Center(
          child: GestureDetector(
            onTap: changePhoto,
            child: CircleAvatar(
              radius: 58,
              backgroundColor: Colors.green,
              backgroundImage:
                  photoPath != null ? FileImage(File(photoPath!)) : null,
              child: photoPath == null
                  ? const Icon(Icons.person, size: 60, color: Colors.white)
                  : null,
            ),
          ),
        ),
        Center(
          child: TextButton.icon(
            onPressed: changePhoto,
            icon: const Icon(Icons.camera_alt),
            label: Text(tr('عکس بدل کړئ', 'تغییر عکس', 'Change photo')),
          ),
        ),
        const Center(
          child: Text(
            'Abdullah Eman',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        Center(
          child: Text(
            tr('د اپلیکیشن جوړوونکی', 'سازنده اپلیکیشن', 'App Developer'),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('د افغانۍ تاریخ', 'تاریخ افغانی', 'History of the Afghani'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  tr(
                    'افغانۍ د افغانستان ملي پیسه ده. په ۱۳۰۴ لمریز کال کې د افغانستان د رسمي پیسو په توګه معرفي شوه او د پخوانۍ افغانۍ روپۍ ځای یې ونیو. افغانۍ زموږ د اقتصادي خپلواکۍ او ملي هویت یوه مهمه نښه ده.',
                    'افغانی پول ملی افغانستان است. در سال ۱۳۰۴ خورشیدی به عنوان پول رسمی افغانستان معرفی شد و جای روپیهٔ افغانی را گرفت. افغانی نماد مهم هویت ملی و استقلال اقتصادی ما است.',
                    'The Afghani is the national currency of Afghanistan. It was introduced in 1925 as the country’s official currency, replacing the Afghan rupee. It is an important symbol of our national identity and economic independence.',
                  ),
                  style: const TextStyle(height: 1.7),
                ),
              ],
            ),
          ),
        ),
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                const Text('🇦🇫', style: TextStyle(fontSize: 38)),
                const SizedBox(height: 8),
                Text(
                  tr(
                    'افغانۍ زموږ ملي هویت دی!',
                    'افغانی هویت ملی ماست!',
                    'The Afghani is our national identity!',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  tr(
                    'راکړه ورکړه په خپله ملي افغانۍ وکړو او د خپل هېواد له اقتصاد څخه ملاتړ وکړو.',
                    'معاملات خود را با پول ملی افغانی انجام دهیم و از اقتصاد کشور خود حمایت کنیم.',
                    'Let us make our transactions in our national currency, the Afghani, and support our country’s economy.',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(height: 1.6),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            'Afghani Exchange',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      marketsPage(),
      worldPage(),
      converterPage(),
      settingsPage(),
      aboutPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          '🇦🇫 Afghani Exchange',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: fetchRates,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: IndexedStack(
        index: page,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: page,
        onDestinationSelected: (index) => setState(() => page = index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.store),
            label: tr('بازارونه', 'بازارها', 'Markets'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.public),
            label: tr('نړۍ', 'جهان', 'World'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.currency_exchange),
            label: tr('تبدیل', 'تبدیل', 'Convert'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings),
            label: tr('تنظیمات', 'تنظیمات', 'Settings'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.info_outline),
            label: tr('About', 'About', 'About'),
          ),
        ],
      ),
    );
  }
}
