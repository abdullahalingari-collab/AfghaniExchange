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

// د اعشاري نرخونو د دقیق ښکاره کولو لپاره
String fmt(dynamic value) {
  if (value == null) return '-';

  if (value is num) {
    if (!value.isFinite) return '-';

    String result = value.toString();

    // که عدد په علمي بڼه وي، عادي اعشاري بڼه ته یې اړوي.
    if (result.contains('e') || result.contains('E')) {
      result = value.toStringAsFixed(10);
    }

    if (result.contains('.')) {
      result = result.replaceFirst(RegExp(r'0+$'), '');
      result = result.replaceFirst(RegExp(r'\.$'), '');
    }

    if (!result.contains('.')) return '$result.00';

    final decimals = result.split('.').last.length;
    if (decimals == 1) return '${result}0';

    return result;
  }

  final text = value.toString().trim();
  return text.isEmpty ? '-' : text;
}

String codeFromLabel(String label) {
  final s = label.toUpperCase();

  if (s.contains('USD')) return 'USD';
  if (s.contains('EURO') || s.contains('EUR')) return 'EUR';
  if (s.contains('POUND') || s.contains('GBP')) return 'GBP';
  if (s.contains('SWISS') || s.contains('CHF')) return 'CHF';
  if (s.contains('INDIAN') || s.contains('INR')) return 'INR';
  if (s.contains('PAKISTAN') || s.contains('PKR')) return 'PKR';
  if (s.contains('IRAN') || s.contains('IRR')) return 'IRR';
  if (s.contains('CNY') || s.contains('CHINESE')) return 'CNY';
  if (s.contains('DIRHAM') || s.contains('AED')) return 'AED';
  if (s.contains('SAUDI') || s.contains('SAR')) return 'SAR';
  if (s.contains('AUD')) return 'AUD';
  if (s.contains('CAD')) return 'CAD';
  if (s.contains('RUB')) return 'RUB';
  if (s.contains('DKK')) return 'DKK';
  if (s.contains('SEK')) return 'SEK';
  if (s.contains('NOK')) return 'NOK';
  if (s.contains('TRY')) return 'TRY';
  if (s.contains('KWD')) return 'KWD';
  if (s.contains('QAR')) return 'QAR';
  if (s.contains('BHD')) return 'BHD';
  if (s.contains('JPY')) return 'JPY';
  if (s.contains('AFN')) return 'AFN';

  return '';
}

const Map<String, String> flags = {
  'AFN': '🇦🇫',
  'USD': '🇺🇸',
  'EUR': '🇪🇺',
  'GBP': '🇬🇧',
  'INR': '🇮🇳',
  'PKR': '🇵🇰',
  'IRR': '🇮🇷',
  'CNY': '🇨🇳',
  'AED': '🇦🇪',
  'SAR': '🇸🇦',
  'CHF': '🇨🇭',
  'AUD': '🇦🇺',
  'CAD': '🇨🇦',
  'RUB': '🇷🇺',
  'DKK': '🇩🇰',
  'SEK': '🇸🇪',
  'NOK': '🇳🇴',
  'TRY': '🇹🇷',
  'KWD': '🇰🇼',
  'QAR': '🇶🇦',
  'BHD': '🇧🇭',
  'JPY': '🇯🇵',
  'NZD': '🇳🇿',
  'SGD': '🇸🇬',
  'MYR': '🇲🇾',
  'THB': '🇹🇭',
  'KRW': '🇰🇷',
  'IDR': '🇮🇩',
  'BRL': '🇧🇷',
  'ZAR': '🇿🇦',
  'EGP': '🇪🇬',
  'OMR': '🇴🇲',
  'JOD': '🇯🇴',
  'IQD': '🇮🇶',
  'LKR': '🇱🇰',
  'BDT': '🇧🇩',
  'NPR': '🇳🇵',
  'PHP': '🇵🇭',
  'MXN': '🇲🇽',
  'TWD': '🇹🇼',
  'HKD': '🇭🇰',
  'MOP': '🇲🇴',
  'VND': '🇻🇳',
  'KHR': '🇰🇭',
  'MMK': '🇲🇲',
  'LAK': '🇱🇦',
  'UZS': '🇺🇿',
  'KZT': '🇰🇿',
  'KGS': '🇰🇬',
  'TJS': '🇹🇯',
  'GEL': '🇬🇪',
  'AMD': '🇦🇲',
  'AZN': '🇦🇿',
  'ILS': '🇮🇱',
  'LBP': '🇱🇧',
  'DZD': '🇩🇿',
  'MAD': '🇲🇦',
  'TND': '🇹🇳',
  'NGN': '🇳🇬',
  'KES': '🇰🇪',
  'GHS': '🇬🇭',
  'ETB': '🇪🇹',
  'TZS': '🇹🇿',
  'UGX': '🇺🇬',
  'XOF': '🌍',
  'XAF': '🌍',
  'PLN': '🇵🇱',
  'CZK': '🇨🇿',
  'HUF': '🇭🇺',
  'RON': '🇷🇴',
  'BGN': '🇧🇬',
  'UAH': '🇺🇦',
  'ISK': '🇮🇸',
  'HRK': '🇭🇷',
  'CLP': '🇨🇱',
  'COP': '🇨🇴',
  'ARS': '🇦🇷',
  'PEN': '🇵🇪',
};

const Map<String, Map<String, String>> names = {
  'ps': {
    'USD': 'امریکایي ډالر',
    'EUR': 'یورو',
    'GBP': 'برتانوي پونډ',
    'INR': 'هندي روپۍ',
    'PKR': 'پاکستانۍ روپۍ',
    'IRR': 'ایراني ریال',
    'CNY': 'چینایي یوان',
    'AED': 'اماراتي درهم',
    'SAR': 'سعودي ریال',
    'CHF': 'سویسي فرانک',
    'AUD': 'اسټرالیا ډالر',
    'CAD': 'کاناډایي ډالر',
    'RUB': 'روسي روبل',
    'JPY': 'جاپاني ین',
    'AFN': 'افغانۍ',
  },
  'fa': {
    'USD': 'دالر آمریکایی',
    'EUR': 'یورو',
    'GBP': 'پوند انگلیس',
    'INR': 'روپیه هند',
    'PKR': 'روپیه پاکستان',
    'IRR': 'ریال ایران',
    'CNY': 'یوان چین',
    'AED': 'درهم امارات',
    'SAR': 'ریال سعودی',
    'CHF': 'فرانک سویس',
    'AUD': 'دالر استرالیا',
    'CAD': 'دالر کانادا',
    'RUB': 'روبل روسیه',
    'JPY': 'ین جاپان',
    'AFN': 'افغانی',
  },
  'en': {
    'USD': 'US Dollar',
    'EUR': 'Euro',
    'GBP': 'British Pound',
    'INR': 'Indian Rupee',
    'PKR': 'Pakistani Rupee',
    'IRR': 'Iranian Rial',
    'CNY': 'Chinese Yuan',
    'AED': 'UAE Dirham',
    'SAR': 'Saudi Riyal',
    'CHF': 'Swiss Franc',
    'AUD': 'Australian Dollar',
    'CAD': 'Canadian Dollar',
    'RUB': 'Russian Ruble',
    'JPY': 'Japanese Yen',
    'AFN': 'Afghan Afghani',
  },
};

class AfghaniExchangeApp extends StatefulWidget {
  const AfghaniExchangeApp({super.key});

  @override
  State<AfghaniExchangeApp> createState() => _AfghaniExchangeAppState();
}

class _AfghaniExchangeAppState extends State<AfghaniExchangeApp> {
  bool dark = false;
  String language = 'ps';

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = dark
        ? const ColorScheme.dark(
            primary: Colors.white,
            secondary: Colors.white,
            surface: Color(0xFF171717),
          )
        : const ColorScheme.light(
            primary: Color(0xFF00843D),
            secondary: Color(0xFFCE2028),
            surface: Colors.white,
          );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afghani Exchange',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor:
            dark ? const Color(0xFF090909) : const Color(0xFFF5F5F5),
        appBarTheme: AppBarTheme(
          backgroundColor: dark ? Colors.black : Colors.white,
          foregroundColor: dark ? Colors.white : Colors.black,
          elevation: 0,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: dark ? Colors.black : Colors.white,
          indicatorColor:
              dark ? Colors.white24 : const Color(0xFF00843D).withOpacity(.15),
        ),
      ),
      home: HomePage(
        dark: dark,
        language: language,
        onDarkChanged: (v) => setState(() => dark = v),
        onLanguageChanged: (v) => setState(() => language = v),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final bool dark;
  final String language;
  final ValueChanged<bool> onDarkChanged;
  final ValueChanged<String> onLanguageChanged;

  const HomePage({
    super.key,
    required this.dark,
    required this.language,
    required this.onDarkChanged,
    required this.onLanguageChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int page = 0;
  int selectedMarketIndex = 0;

  bool loading = true;
  String? error;
  DateTime? updatedAt;

  Map<String, dynamic> markets = {};
  List<Map<String, dynamic>> worldRates = [];

  String? photoPath;

  final TextEditingController amountController =
      TextEditingController(text: '1');

  String fromCode = 'USD';
  String toCode = 'AFN';
  String selectedMarket = 'sarai';
  String conversionSide = 'buy';

  String tr(String ps, String fa, String en) {
    if (widget.language == 'fa') return fa;
    if (widget.language == 'en') return en;
    return ps;
  }

  @override
  void initState() {
    super.initState();
    loadPhoto();
    fetchRates();
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<void> loadPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('developer_photo');

    if (mounted) {
      setState(() => photoPath = path);
    }
  }

  Future<void> choosePhoto() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked == null) return;

    final directory = await getApplicationDocumentsDirectory();

    final saved = await File(picked.path).copy(
      '${directory.path}/developer_photo.jpg',
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('developer_photo', saved.path);

    if (mounted) {
      setState(() => photoPath = saved.path);
    }
  }

  Future<List<Map<String, dynamic>>> fetchWorld() async {
    final response = await http
        .get(Uri.parse('https://open.er-api.com/v6/latest/USD'))
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('World rates unavailable');
    }

    final data = jsonDecode(response.body);

    if (data['result'] != 'success') {
      throw Exception('World rates unavailable');
    }

    final rates = Map<String, dynamic>.from(data['rates']);
    final usdToAfn = (rates['AFN'] as num).toDouble();

    final result = <Map<String, dynamic>>[];

    for (final entry in rates.entries) {
      if (entry.key == 'USD') continue;
      if (entry.value is! num) continue;

      final foreignPerUsd = (entry.value as num).toDouble();

      if (foreignPerUsd <= 0) continue;

      final afnRate = usdToAfn / foreignPerUsd;

      result.add({
        'code': entry.key,
        'rate': afnRate,
        'buy': afnRate,
        'sell': afnRate,
      });
    }

    result.add({
      'code': 'USD',
      'rate': usdToAfn,
      'buy': usdToAfn,
      'sell': usdToAfn,
    });

    result.sort(
      (a, b) => (a['code'] as String).compareTo(b['code'] as String),
    );

    return result;
  }

  Future<void> fetchRates() async {
    if (mounted) {
      setState(() {
        loading = true;
        error = null;
      });
    }

    try {
      final response = await http
          .get(Uri.parse(workerUrl))
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception('Market API error: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      final newMarkets = Map<String, dynamic>.from(data['markets'] ?? {});

      List<Map<String, dynamic>> newWorld = [];

      try {
        newWorld = await fetchWorld();
      } catch (_) {
        final oldWorld = data['world'];

        if (oldWorld is List) {
          newWorld = oldWorld
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .map((item) {
                final rate = item['rate'] ?? item['afnPerUnit'];

                return {
                  ...item,
                  'rate': rate,
                  'buy': item['buy'] ?? rate,
                  'sell': item['sell'] ?? rate,
                };
              })
              .toList();
        }
      }

      if (!mounted) return;

      setState(() {
        markets = newMarkets;
        worldRates = newWorld;
        updatedAt = DateTime.tryParse(data['updatedAt'] ?? '');
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

  List<dynamic> marketRows(String key) {
    final market = markets[key];

    if (market is Map && market['rows'] is List) {
      return market['rows'] as List;
    }

    return [];
  }

  String flag(String code) => flags[code] ?? '🌐';

  String currencyName(String code) {
    return names[widget.language]?[code] ?? code;
  }

  Map<String, double> conversionRates() {
    final result = <String, double>{'AFN': 1};

    for (final row in marketRows(selectedMarket)) {
      if (row is! Map) continue;

      final label = row['label']?.toString() ?? '';
      final code = codeFromLabel(label);

      if (code.isEmpty || code == 'AFN') continue;

      final value = row[conversionSide];

      if (value is! num) continue;

      double rate = value.toDouble();

      if (label.toUpperCase().contains('1K')) {
        rate = rate / 1000;
      }

      if (rate > 0 && !result.containsKey(code)) {
        result[code] = rate;
      }
    }

    for (final item in worldRates) {
      final code = item['code']?.toString() ?? '';
      final rate = item['rate'];

      if (code.isNotEmpty && rate is num && rate > 0) {
        result.putIfAbsent(code, () => rate.toDouble());
      }
    }

    return result;
  }

  String get convertedAmount {
    final amount = double.tryParse(amountController.text) ?? 0;
    final rates = conversionRates();

    final fromRate = rates[fromCode];
    final toRate = rates[toCode];

    if (fromRate == null || toRate == null || toRate == 0) {
      return '-';
    }

    return (amount * fromRate / toRate).toStringAsFixed(4);
  }

  Widget marketCard(String key, String title, String subtitle) {
    final rows = marketRows(key);
    final isDark = widget.dark;

    return Card(
      color: isDark ? const Color(0xFF171717) : Colors.white,
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text('🇦🇫', style: TextStyle(fontSize: 25)),
              ],
            ),
            const Divider(height: 25),
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    tr('اسعار', 'ارز', 'Currency'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    tr('پېر', 'خرید', 'Buy'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF00843D),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    tr('پلور', 'فروش', 'Sell'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFCE2028),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            if (rows.isEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  tr('نرخونه نشته', 'نرخ موجود نیست', 'No rates'),
                ),
              ),
            ...rows.map((row) {
              if (row is! Map) return const SizedBox.shrink();

              final label = row['label']?.toString() ?? '';
              final code = codeFromLabel(label);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Row(
                        children: [
                          Text(
                            flag(code),
                            style: const TextStyle(fontSize: 19),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              label,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        fmt(row['buy']),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF00843D),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        fmt(row['sell']),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFCE2028),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // د درې باوري بازارونو پاڼه
  Widget marketsPage() {
    final marketKeys = ['bank', 'sarai', 'khorasan'];

    final marketTitles = [
      tr('د افغانستان بانک', 'بانک افغانستان', 'Da Afghanistan Bank'),
      tr('سرای شهزاده', 'سرای شهزاده', 'Sarai Shahzada'),
      tr('خراسان مارکیټ', 'بازار خراسان', 'Khorasan Market'),
    ];

    final marketSubtitles = [
      tr('رسمي بانکي نرخونه', 'نرخ رسمی بانکی', 'Official bank rates'),
      tr('د صرافۍ بازار', 'بازار صرافی', 'Exchange market'),
      tr('د خراسان بازار نرخونه', 'نرخ بازار خراسان', 'Khorasan market rates'),
    ];

    return RefreshIndicator(
      onRefresh: fetchRates,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.dark ? Colors.white10 : const Color(0xFF00843D),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text('🇦🇫', style: TextStyle(fontSize: 34)),
                Text(
                  tr(
                    'افغانۍ د اسعارو نرخونه',
                    'نرخ اسعار افغانی',
                    'Afghani Exchange Rates',
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  updatedAt == null
                      ? tr(
                          'د تازه کېدو وخت نامعلوم',
                          'زمان بروزرسانی نامعلوم',
                          'Update time unavailable',
                        )
                      : '${tr('وروستی تازه کېدل:', 'آخرین بروزرسانی:', 'Last updated:')} ${updatedAt!.toLocal()}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          if (loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            ),
          if (error != null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.error_outline, color: Colors.red),
                title: Text(error!),
                trailing: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: fetchRates,
                ),
              ),
            ),
          SegmentedButton<int>(
            segments: [
              ButtonSegment<int>(
                value: 0,
                label: Text(tr('بانک', 'بانک', 'Bank')),
              ),
              ButtonSegment<int>(
                value: 1,
                label: Text(tr('سرای', 'سرای', 'Sarai')),
              ),
              ButtonSegment<int>(
                value: 2,
                label: Text(tr('خراسان', 'خراسان', 'Khorasan')),
              ),
            ],
            selected: {selectedMarketIndex},
            onSelectionChanged: (value) {
              setState(() {
                selectedMarketIndex = value.first;
              });
            },
          ),
          const SizedBox(height: 15),
          marketCard(
            marketKeys[selectedMarketIndex],
            marketTitles[selectedMarketIndex],
            marketSubtitles[selectedMarketIndex],
          ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  // نړیوال اسعار: پېر او پلور دواړه د مرجع نرخ دي
  Widget worldPage() {
    final items = worldRates;

    return RefreshIndicator(
      onRefresh: fetchRates,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text(
            tr('د نړۍ اسعار', 'ارزهای جهان', 'World Currencies'),
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            tr(
              'د هر اسعارو مرجع نرخ په افغانیو کې',
              'نرخ مرجع هر ارز به افغانی',
              'Reference rate of each currency in Afghanis',
            ),
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: widget.dark ? Colors.white10 : Colors.amber.withOpacity(.13),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tr(
                      'دا نړیوال مرجع نرخونه دي؛ د صرافۍ جلا پېر او پلور نرخونه نه دي.',
                      'این نرخ‌ها مرجع جهانی هستند؛ نرخ جداگانه خرید و فروش صرافی نیستند.',
                      'These are global reference rates, not separate exchange buy and sell rates.',
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const Icon(Icons.cloud_off, size: 45),
                  const SizedBox(height: 10),
                  Text(
                    tr(
                      'د نړۍ نرخونه نه دي ترلاسه شوي',
                      'نرخ ارزهای جهان دریافت نشد',
                      'World rates could not be loaded',
                    ),
                  ),
                  TextButton.icon(
                    onPressed: fetchRates,
                    icon: const Icon(Icons.refresh),
                    label: Text(tr('بیا هڅه', 'تلاش دوباره', 'Retry')),
                  ),
                ],
              ),
            ),
          if (items.isNotEmpty)
            Card(
              color: widget.dark ? const Color(0xFF171717) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(
                            tr('اسعار', 'ارز', 'Currency'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            tr('پېر', 'خرید', 'Buy'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF00843D),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            tr('پلور', 'فروش', 'Sell'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFCE2028),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    ...items.map((item) {
                      final code = item['code']?.toString() ?? '';
                      final buy = item['buy'] ?? item['rate'] ?? item['afnPerUnit'];
                      final sell = item['sell'] ?? item['rate'] ?? item['afnPerUnit'];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: Row(
                                children: [
                                  Text(
                                    flag(code),
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 7),
                                  Expanded(
                                    child: Text(
                                      '$code - ${currencyName(code)}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                fmt(buy),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF00843D),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                fmt(sell),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFFCE2028),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget converterPage() {
    final rates = conversionRates();
    final codes = rates.keys.toList()..sort();

    if (!codes.contains(fromCode)) fromCode = 'USD';
    if (!codes.contains(toCode)) toCode = 'AFN';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          tr('د اسعارو تبدیلول', 'تبدیل ارز', 'Currency Converter'),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr('د بازار انتخاب', 'انتخاب بازار', 'Select market')),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedMarket,
                  items: [
                    DropdownMenuItem(
                      value: 'bank',
                      child: Text(
                        tr(
                          'افغانستان بانک',
                          'بانک افغانستان',
                          'Da Afghanistan Bank',
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'sarai',
                      child: Text(
                        tr('سرای شهزاده', 'سرای شهزاده', 'Sarai Shahzada'),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'khorasan',
                      child: Text(
                        tr('خراسان مارکیټ', 'بازار خراسان', 'Khorasan Market'),
                      ),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => selectedMarket = v);
                    }
                  },
                ),
                const SizedBox(height: 15),
                Text(tr('د نرخ ډول', 'نوع نرخ', 'Rate type')),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'buy',
                      label: Text(tr('پېر', 'خرید', 'Buy')),
                    ),
                    ButtonSegment(
                      value: 'sell',
                      label: Text(tr('پلور', 'فروش', 'Sell')),
                    ),
                  ],
                  selected: {conversionSide},
                  onSelectionChanged: (v) {
                    setState(() => conversionSide = v.first);
                  },
                ),
                const SizedBox(height: 18),
                Text(tr('اندازه', 'مقدار', 'Amount')),
                TextField(
                  controller: amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '1',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 15),
                Text(tr('له کوم اسعارو', 'از کدام ارز', 'From currency')),
                DropdownButtonFormField<String>(
                  value: codes.contains(fromCode) ? fromCode : 'USD',
                  isExpanded: true,
                  items: codes.map((code) {
                    return DropdownMenuItem(
                      value: code,
                      child: Text('${flag(code)} $code'),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => fromCode = v);
                  },
                ),
                const SizedBox(height: 15),
                Center(
                  child: IconButton.filled(
                    onPressed: () {
                      setState(() {
                        final temp = fromCode;
                        fromCode = toCode;
                        toCode = temp;
                      });
                    },
                    icon: const Icon(Icons.swap_vert),
                  ),
                ),
                Text(tr('کوم اسعارو ته', 'به کدام ارز', 'To currency')),
                DropdownButtonFormField<String>(
                  value: codes.contains(toCode) ? toCode : 'AFN',
                  isExpanded: true,
                  items: codes.map((code) {
                    return DropdownMenuItem(
                      value: code,
                      child: Text('${flag(code)} $code'),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => toCode = v);
                  },
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: widget.dark
                        ? Colors.white12
                        : const Color(0xFF00843D).withOpacity(.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Text(tr('پایله', 'نتیجه', 'Result')),
                      const SizedBox(height: 8),
                      Text(
                        '$convertedAmount $toCode',
                        style: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget languagePage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          tr('د ژبې انتخاب', 'انتخاب زبان', 'Language Settings'),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 18),
        for (final item in [
          {'code': 'ps', 'name': 'پښتو', 'flag': '🇦🇫'},
          {'code': 'fa', 'name': 'دری', 'flag': '🇦🇫'},
          {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
        ])
          Card(
            child: RadioListTile<String>(
              value: item['code']!,
              groupValue: widget.language,
              title: Text('${item['flag']}  ${item['name']}'),
              onChanged: (v) {
                if (v != null) widget.onLanguageChanged(v);
              },
            ),
          ),
        const Divider(height: 30),
        SwitchListTile(
          secondary: const Icon(Icons.dark_mode),
          title: Text(tr('تور او سپین حالت', 'حالت تاریک', 'Dark mode')),
          value: widget.dark,
          onChanged: widget.onDarkChanged,
        ),
      ],
    );
  }

  Widget developerAvatar({double radius = 55}) {
    final hasPhoto =
        photoPath != null && File(photoPath!).existsSync();

    return CircleAvatar(
      radius: radius,
      backgroundColor:
          widget.dark ? Colors.white24 : const Color(0xFF00843D),
      backgroundImage: hasPhoto ? FileImage(File(photoPath!)) : null,
      child: hasPhoto
          ? null
          : Icon(Icons.person, size: radius, color: Colors.white),
    );
  }

  Widget developerPage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 20),
        Center(
          child: GestureDetector(
            onTap: choosePhoto,
            child: developerAvatar(radius: 65),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton.icon(
            onPressed: choosePhoto,
            icon: const Icon(Icons.photo_library),
            label: Text(tr('عکس بدلول', 'تغییر عکس', 'Change photo')),
          ),
        ),
        const SizedBox(height: 15),
        const Center(
          child: Text(
            'Abdullah Eman',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            '🇦🇫  Afghanistan',
            style: TextStyle(fontSize: 18),
          ),
        ),
        const SizedBox(height: 20),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.currency_exchange),
          title: Text(tr('افغانۍ', 'افغانی', 'Afghan Afghani')),
          subtitle: const Text('AFN'),
        ),
        ListTile(
          leading: const Icon(Icons.calendar_month),
          title: Text(
            tr(
              'د نرخونو د تازه کېدو وخت',
              'زمان بروزرسانی نرخ‌ها',
              'Rates update time',
            ),
          ),
          subtitle: Text(
            updatedAt == null ? '-' : updatedAt!.toLocal().toString(),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.flag),
          title: Text(tr('افغانستان', 'افغانستان', 'Afghanistan')),
          subtitle: Text(tr('جوړوونکی', 'توسعه‌دهنده', 'Developer')),
        ),
      ],
    );
  }

  // د افغانستان د پیسو تاریخ
  Widget aboutPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.dark ? Colors.white10 : const Color(0xFF00843D),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              const Text('🇦🇫', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              Text(
                tr(
                  'د افغانۍ تاریخ',
                  'تاریخچه افغانی',
                  'History of the Afghan Afghani',
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'AFN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('د افغانۍ پېژندنه', 'معرفی افغانی', 'About the Afghani'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  tr(
                    'افغانۍ د افغانستان رسمي ملي پیسه ده. د افغانۍ نوم په ۱۳۰۴ لمریز کال کې د اماني دورې پر مهال د هېواد د پیسو لپاره وکارول شو. افغانۍ د افغانستان د اقتصاد او سوداګرۍ مهمه برخه ده.',
                    'افغانی واحد پول رسمی افغانستان است. نام افغانی در سال ۱۳۰۴ خورشیدی در دوره امانی برای پول کشور به کار گرفته شد. افغانی بخش مهم اقتصاد و تجارت افغانستان است.',
                    'The Afghani is the official currency of Afghanistan. The name Afghani was introduced for the national currency in 1925 during the Amanullah Khan era. It remains an important part of Afghanistan’s economy and trade.',
                  ),
                  style: const TextStyle(fontSize: 14, height: 1.7),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(
                    'د اماني دورې پاچا',
                    'پادشاه دوره امانی',
                    'King of the Amanullah era',
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: Colors.brown.withOpacity(.15),
                      child: const Icon(
                        Icons.account_balance,
                        size: 36,
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Amanullah Khan',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  tr(
                    'د امان الله خان د واکمنۍ پر مهال د افغانستان د ملي پیسو د جوړولو او تنظیم بهیر پیل شو. دا د هغه وخت تاریخي مشر و؛ خو د بانکنوټونو د ډیزاین د یوه مشخص شخص نوم په دې برخه کې نه دی تایید شوی.',
                    'در زمان پادشاهی امان‌الله خان روند ایجاد و تنظیم پول ملی افغانستان آغاز شد. او رهبر تاریخی آن دوره بود؛ اما نام یک طراح مشخص اسکناس‌ها در این بخش تأیید نشده است.',
                    'The process of establishing and organizing Afghanistan’s national currency took place during Amanullah Khan’s reign. He was the historical ruler of that period; however, a specific banknote designer is not identified here.',
                  ),
                  style: const TextStyle(fontSize: 13, height: 1.7),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(
                    'د بانکنوټونو تاریخ',
                    'تاریخچه اسکناس‌ها',
                    'Banknote history',
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  tr(
                    'افغانستان د خپل تاریخ په اوږدو کې بېلابېل کاغذي بانکنوټونه او فلزي سکې کارولي دي. د افغانستان بانک د ملي پیسو د خپرولو او تنظیم رسمي اداره ده.',
                    'افغانستان در طول تاریخ خود اسکناس‌ها و سکه‌های گوناگون داشته است. د افغانستان بانک اداره رسمی نشر و تنظیم پول ملی است.',
                    'Afghanistan has used different banknotes and coins throughout its history. Da Afghanistan Bank is the official institution responsible for issuing and regulating the national currency.',
                  ),
                  style: const TextStyle(fontSize: 14, height: 1.7),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(
                    'د ۲۰۰۲ کال د پیسو بدلون',
                    'تغییر پول در سال ۲۰۰۲',
                    'The 2002 currency reform',
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  tr(
                    'په ۲۰۰۲ کال کې د افغانستان پیسې اصلاح شوې او له پخوانۍ افغانۍ څخه درې صفرونه لرې شول. د دې بدلون موخه د پیسو د حساب او راکړې ورکړې اسانه کول وو.',
                    'در سال ۲۰۰۲ پول افغانستان اصلاح شد و سه صفر از واحد پول قبلی حذف گردید. هدف این تغییر آسان‌سازی محاسبات و معاملات بود.',
                    'In 2002, Afghanistan carried out a currency reform and removed three zeros from the previous Afghani. The reform was intended to make calculations and transactions easier.',
                  ),
                  style: const TextStyle(fontSize: 14, height: 1.7),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  tr(
                    'د اپلیکیشن جوړوونکی',
                    'سازنده اپلیکیشن',
                    'App developer',
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                developerAvatar(radius: 42),
                const SizedBox(height: 10),
                const Text(
                  'Abdullah Eman',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  tr(
                    'د Afghani Exchange جوړوونکی',
                    'سازنده Afghani Exchange',
                    'Creator of Afghani Exchange',
                  ),
                  style: const TextStyle(color: Colors.grey),
                ),
                TextButton.icon(
                  onPressed: choosePhoto,
                  icon: const Icon(Icons.photo_camera),
                  label: Text(
                    tr('د جوړوونکي عکس بدلول', 'تغییر عکس سازنده', 'Change developer photo'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      marketsPage(),
      worldPage(),
      converterPage(),
      languagePage(),
      developerPage(),
      aboutPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🇦🇫 Afghani Exchange',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: fetchRates,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: IndexedStack(
        index: page,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: page,
        onDestinationSelected: (v) => setState(() => page = v),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.show_chart),
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
            icon: const Icon(Icons.language),
            label: tr('ژبه', 'زبان', 'Language'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person),
            label: tr('جوړوونکی', 'سازنده', 'Developer'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.info_outline),
            label: tr('زموږ په اړه', 'درباره ما', 'About'),
          ),
        ],
      ),
    );
  }
}
