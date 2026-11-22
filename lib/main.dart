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
  'PKR': '🇵🇰', 'INR': '🇮🇳', 'IRR': '🇮🇷', 'IRT': '🇮🇷',
  'CNY': '🇨🇳', 'CNH': '🇨🇳', 'TRY': '🇹🇷', 'AED': '🇦🇪',
  'SAR': '🇸🇦', 'QAR': '🇶🇦', 'KWD': '🇰🇼', 'CAD': '🇨🇦',
  'AUD': '🇦🇺', 'JPY': '🇯🇵', 'CHF': '🇨🇭', 'RUB': '🇷🇺',
  'SEK': '🇸🇪', 'NOK': '🇳🇴', 'DKK': '🇩🇰', 'NZD': '🇳🇿',
  'SGD': '🇸🇬', 'MYR': '🇲🇾', 'THB': '🇹🇭', 'BDT': '🇧🇩',
  'LKR': '🇱🇰', 'NPR': '🇳🇵', 'IQD': '🇮🇶', 'OMR': '🇴🇲',
  'BHD': '🇧🇭', 'EGP': '🇪🇬', 'ZAR': '🇿🇦', 'BRL': '🇧🇷',
  'KRW': '🇰🇷', 'HKD': '🇭🇰', 'PLN': '🇵🇱', 'CZK': '🇨🇿',
  'HUF': '🇭🇺', 'UAH': '🇺🇦', 'GEL': '🇬🇪', 'AZN': '🇦🇿',
  'KZT': '🇰🇿', 'UZS': '🇺🇿', 'TJS': '🇹🇯', 'TMT': '🇹🇲',
  'KGS': '🇰🇬', 'MNT': '🇲🇳', 'IDR': '🇮🇩', 'PHP': '🇵🇭',
  'VND': '🇻🇳', 'MMK': '🇲🇲', 'KHR': '🇰🇭', 'LAK': '🇱🇦',
  'ARS': '🇦🇷', 'MXN': '🇲🇽', 'CLP': '🇨🇱', 'COP': '🇨🇴',
  'PEN': '🇵🇪', 'NGN': '🇳🇬', 'KES': '🇰🇪', 'GHS': '🇬🇭',
  'MAD': '🇲🇦', 'TND': '🇹🇳', 'DZD': '🇩🇿', 'ETB': '🇪🇹',
  'ILS': '🇮🇱', 'JOD': '🇯🇴', 'LBP': '🇱🇧', 'SYP': '🇸🇾',
  'YER': '🇾🇪', 'RON': '🇷🇴', 'BGN': '🇧🇬', 'HRK': '🇭🇷',
  'RSD': '🇷🇸', 'ISK': '🇮🇸', 'ALL': '🇦🇱', 'MDL': '🇲🇩',
  'XAF': '🌍', 'XOF': '🌍', 'XPF': '🌍', 'XCD': '🌎',
  'BAM': '🇧🇦', 'BBD': '🇧🇧', 'BMD': '🇧🇲', 'BSD': '🇧🇸',
  'BND': '🇧🇳', 'BOB': '🇧🇴', 'BWP': '🇧🇼', 'BYN': '🇧🇾',
  'BZD': '🇧🇿', 'CDF': '🇨🇩', 'CRC': '🇨🇷', 'CUP': '🇨🇺',
  'CVE': '🇨🇻', 'DJF': '🇩🇯', 'DOP': '🇩🇴', 'ERN': '🇪🇷',
  'FJD': '🇫🇯', 'GMD': '🇬🇲', 'GNF': '🇬🇳', 'GTQ': '🇬🇹',
  'GYD': '🇬🇾', 'HNL': '🇭🇳', 'HTG': '🇭🇹', 'JMD': '🇯🇲',
  'KMF': '🇰🇲', 'KYD': '🇰🇾', 'LRD': '🇱🇷', 'LSL': '🇱🇸',
  'LYD': '🇱🇾', 'MGA': '🇲🇬', 'MKD': '🇲🇰', 'MOP': '🇲🇴',
  'MRU': '🇲🇷', 'MUR': '🇲🇺', 'MVR': '🇲🇻', 'MWK': '🇲🇼',
  'MZN': '🇲🇿', 'NAD': '🇳🇦', 'NIO': '🇳🇮', 'PAB': '🇵🇦',
  'PGK': '🇵🇬', 'PYG': '🇵🇾', 'RWF': '🇷🇼', 'SBD': '🇸🇧',
  'SCR': '🇸🇨', 'SDG': '🇸🇩', 'SLE': '🇸🇱', 'SOS': '🇸🇴',
  'SRD': '🇸🇷', 'SSP': '🇸🇸', 'STN': '🇸🇹', 'SZL': '🇸🇿',
  'TOP': '🇹🇴', 'TTD': '🇹🇹', 'TWD': '🇹🇼', 'TZS': '🇹🇿',
  'UGX': '🇺🇬', 'UYU': '🇺🇾', 'VES': '🇻🇪', 'VUV': '🇻🇺',
  'WST': '🇼🇸', 'ZMW': '🇿🇲', 'ZWG': '🇿🇼', 'ZWL': '🇿🇼',
};

const Map<String, Map<String, String>> currencyNames = {
  'ps': {
    'AFN': 'افغانۍ', 'USD': 'امریکایي ډالر', 'EUR': 'یورو',
    'GBP': 'برتانوي پونډ', 'PKR': 'پاکستانۍ روپۍ',
    'INR': 'هندي روپۍ', 'IRR': 'ایراني ریال',
    'IRT': 'ایراني تومان', 'CNY': 'چینایي یوان',
    'TRY': 'ترکي لیره', 'AED': 'اماراتي درهم',
    'SAR': 'سعودي ریال', 'QAR': 'قطري ریال',
    'KWD': 'کویتي دینار', 'CAD': 'کاناډایي ډالر',
    'AUD': 'اسټرالیایي ډالر', 'JPY': 'جاپاني ین',
    'CHF': 'سویسي فرانک', 'RUB': 'روسي روبل',
  },
  'fa': {
    'AFN': 'افغانی', 'USD': 'دالر آمریکایی', 'EUR': 'یورو',
    'GBP': 'پوند انگلیس', 'PKR': 'روپیه پاکستانی',
    'INR': 'روپیه هندی', 'IRR': 'ریال ایرانی',
    'IRT': 'تومان ایرانی', 'CNY': 'یوان چین',
    'TRY': 'لیره ترکیه', 'AED': 'درهم امارات',
    'SAR': 'ریال سعودی', 'QAR': 'ریال قطر',
    'KWD': 'دینار کویت', 'CAD': 'دالر کانادا',
    'AUD': 'دالر آسترالیا', 'JPY': 'ین جاپان',
    'CHF': 'فرانک سویس', 'RUB': 'روبل روسیه',
  },
  'en': {
    'AFN': 'Afghan Afghani', 'USD': 'US Dollar', 'EUR': 'Euro',
    'GBP': 'British Pound', 'PKR': 'Pakistani Rupee',
    'INR': 'Indian Rupee', 'IRR': 'Iranian Rial',
    'IRT': 'Iranian Toman', 'CNY': 'Chinese Yuan',
    'TRY': 'Turkish Lira', 'AED': 'UAE Dirham',
    'SAR': 'Saudi Riyal', 'QAR': 'Qatari Riyal',
    'KWD': 'Kuwaiti Dinar', 'CAD': 'Canadian Dollar',
    'AUD': 'Australian Dollar', 'JPY': 'Japanese Yen',
    'CHF': 'Swiss Franc', 'RUB': 'Russian Ruble',
  },
};

double? toNumber(dynamic value) {
  if (value == null) return null;
  final n = double.tryParse(
    value.toString().replaceAll(',', '').replaceAll(' ', ''),
  );
  if (n == null || !n.isFinite) return null;
  return n;
}

String money(dynamic value, {int decimals = 2}) {
  final n = toNumber(value);
  return n == null ? '—' : n.toStringAsFixed(decimals);
}

String currencyName(String code, String lang) {
  return currencyNames[lang]?[code] ?? code;
}

String marketCurrencyCode(String label) {
  final s = label.toUpperCase().trim();

  if (s.contains('PAKISTAN') || s.contains('PKR')) return 'PKR';
  if (s.contains('INDIAN') || s.contains('INR')) return 'INR';
  if (s.contains('EURO') || s.contains('EUR')) return 'EUR';
  if (s.contains('POUND') || s.contains('GBP')) return 'GBP';
  if (s.contains('SWISS') || s.contains('CHF')) return 'CHF';
  if (s.contains('IRAN') || s.contains('TOMAN')) return 'IRT';
  if (s.contains('UAE') || s.contains('DIRHAM')) return 'AED';
  if (s.contains('SAUDI') || s.contains('RIYAL')) return 'SAR';
  if (s.contains('YUAN') || s.contains('CNY')) return 'CNY';
  if (s.contains('USD') || s.contains('DOLLAR')) return 'USD';

  final match = RegExp(r'\b([A-Z]{3})/AFN').firstMatch(s);
  if (match != null) return match.group(1)!;

  return '';
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
  bool offline = false;
  String error = '';
  String selectedMarket = 'bank';
  String updatedAt = '';
  String worldUpdatedAt = '';
  bool worldIsStale = false;

  Map<String, dynamic> markets = {};
  List<dynamic> world = [];
  String? photoPath;

  final picker = ImagePicker();
  final amountController = TextEditingController(text: '1');
  String fromCurrency = 'USD';
  String toCurrency = 'AFN';

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
    loadCachedRates();
    fetchRates();
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<SharedPreferences> get prefs async =>
      SharedPreferences.getInstance();

  Future<void> loadPhoto() async {
    final p = await prefs;
    final path = p.getString('developerPhoto');
    if (path != null && File(path).existsSync() && mounted) {
      setState(() => photoPath = path);
    }
  }

  Future<void> changePhoto() async {
    try {
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image == null) return;

      final dir = await getApplicationDocumentsDirectory();
      final saved = await File(image.path).copy(
        '${dir.path}/developer_photo.jpg',
      );
      final p = await prefs;
      await p.setString('developerPhoto', saved.path);

      if (mounted) setState(() => photoPath = saved.path);
    } catch (e) {
      showMessage('$e');
    }
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> loadCachedRates() async {
    final p = await prefs;
    final cached = p.getString('cachedRates');
    if (cached == null) return;

    try {
      final data = jsonDecode(cached);
      if (data is! Map || !mounted) return;
      setState(() {
        markets = data['markets'] is Map
            ? Map<String, dynamic>.from(data['markets'])
            : {};
        world = data['world'] is List ? data['world'] : [];
        updatedAt = '${data['checkedAt'] ?? ''}';
        worldUpdatedAt = '${data['worldUpdatedAt'] ?? ''}';
        worldIsStale = data['worldIsStale'] == true;
      });
    } catch (_) {}
  }

  Future<void> fetchRates() async {
    if (mounted) {
      setState(() {
        loading = true;
        error = '';
      });
    }

    try {
      final response = await http.get(
        Uri.parse(workerUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      if (data is! Map || data['success'] != true) {
        throw Exception('Invalid API response');
      }

      final receivedMarkets = data['markets'];
      final receivedWorld = data['world'];

      final newMarkets = receivedMarkets is Map
          ? Map<String, dynamic>.from(receivedMarkets)
          : <String, dynamic>{};
      final newWorld = receivedWorld is List
          ? receivedWorld
          : <dynamic>[];

      final checked = '${data['checkedAt'] ?? data['updatedAt'] ?? ''}';
      final worldTime = '${data['worldUpdatedAt'] ?? ''}';
      final stale = data['worldIsStale'] == true;

      final cacheData = {
        'markets': newMarkets,
        'world': newWorld,
        'checkedAt': checked,
        'worldUpdatedAt': worldTime,
        'worldIsStale': stale,
      };

      final p = await prefs;
      await p.setString('cachedRates', jsonEncode(cacheData));

      if (!mounted) return;
      setState(() {
        markets = newMarkets;
        world = newWorld;
        updatedAt = checked;
        worldUpdatedAt = worldTime;
        worldIsStale = stale;
        offline = false;
        loading = false;
        error = '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        offline = true;
        error = tr(
          'مهرباني وکړئ انټرنېټ سره وصل شئ، څو تازه نرخونه ترلاسه کړئ.',
          'لطفاً برای دریافت نرخ‌های تازه به اینترنت وصل شوید.',
          'Please connect to the internet to receive updated rates.',
        );
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

  List<String> get currencyCodes {
    final codes = <String>{'AFN'};

    for (final item in world) {
      if (item is Map) {
        final code = '${item['code'] ?? ''}'.toUpperCase();
        if (RegExp(r'^[A-Z]{3}$').hasMatch(code)) {
          codes.add(code);
        }
      }
    }

    for (final entry in markets.values) {
      if (entry is Map && entry['rows'] is List) {
        for (final row in entry['rows']) {
          if (row is Map) {
            final code = marketCurrencyCode('${row['label'] ?? ''}');
            if (code.isNotEmpty) codes.add(code);
          }
        }
      }
    }

    final result = codes.toList()..sort();
    return result;
  }

  double? worldRateFor(String code) {
    if (code == 'AFN') return 1;

    for (final item in world) {
      if (item is Map &&
          '${item['code'] ?? ''}'.toUpperCase() == code.toUpperCase()) {
        return toNumber(item['afnPerUnit']) ??
            toNumber(item['rate']);
      }
    }
    return null;
  }

  double? rateFor(String code, {bool useSell = false}) {
    if (code == 'AFN') return 1;

    for (final row in selectedRows) {
      final rowCode = marketCurrencyCode('${row['label'] ?? ''}');
      if (rowCode == code.toUpperCase()) {
        final value = toNumber(
          useSell ? row['sell'] : row['buy'],
        );
        final unit = toNumber(row['unit']) ?? 1;

        if (value != null && unit > 0) {
          return value / unit;
        }
      }
    }

    return worldRateFor(code);
  }

  double? get conversionResult {
    final amount = toNumber(amountController.text);
    if (amount == null) return null;

    final fromRate = rateFor(fromCurrency);
    final toRate = rateFor(toCurrency);

    if (fromRate == null || toRate == null || toRate == 0) {
      return null;
    }

    return amount * fromRate / toRate;
  }

  String formatDate(String value) {
    if (value.isEmpty) return '—';
    final date = DateTime.tryParse(value)?.toLocal();
    if (date == null) return value;

    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    final h = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');

    return '$y-$m-$d  $h:$min';
  }

  Widget notice(String message, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(message, style: TextStyle(color: color)),
    );
  }

  Widget marketSelector() {
    const colors = {
      'bank': Color(0xff07834f),
      'sarai': Color(0xff0785c4),
      'khorasan': Color(0xffe17b09),
      'kandahar': Color(0xff7944ad),
      'nangarhar': Color(0xffd83f78),
    };

    return SizedBox(
      height: 112,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        children: marketLabels.entries.map((entry) {
          final active = selectedMarket == entry.key;
          final color = colors[entry.key]!;

          return GestureDetector(
            onTap: () => setState(() => selectedMarket = entry.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 150,
              margin: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 8,
              ),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
                border: active
                    ? Border.all(color: Colors.white, width: 3)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(.2),
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.account_balance,
                    color: Colors.white,
                    size: 25,
                  ),
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
    final stale = market is Map && market['stale'] == true;
    final description =
        market is Map ? '${market['rateDescription'] ?? ''}' : '';

    final seen = <String>{};
    final uniqueRows = <Map<String, dynamic>>[];

    for (final row in rows) {
      final code = marketCurrencyCode('${row['label'] ?? ''}');
      final key = code.isEmpty ? '${row['label'] ?? ''}' : code;
      if (seen.add(key)) uniqueRows.add(row);
    }

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            color: Color(0xff087d50),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(14),
            ),
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
                  rateType == 'official'
                      ? tr('رسمي', 'رسمی', 'Official')
                      : rateType == 'indicative'
                          ? tr('اټکلي', 'تقریبی', 'Indicative')
                          : tr('بازار', 'بازار', 'Market'),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ),
        if (description.isNotEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(8),
            color: const Color(0xffeaf0f7),
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black87,
              ),
            ),
          ),
        if (stale)
          notice(
            tr(
              'دا معلومات پخواني دي.',
              'این معلومات قدیمی است.',
              'These rates are stale.',
            ),
            Colors.orange,
          ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 10,
          ),
          color: const Color(0xffeaf0f7),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(tr('اسعار', 'ارز', 'Currency')),
              ),
              Expanded(
                child: Text(
                  tr('پېر', 'خرید', 'Buy'),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  tr('پلور', 'فروش', 'Sell'),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        if (uniqueRows.isEmpty)
          Card(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Text(
                loading
                    ? tr(
                        'معلومات ترلاسه کېږي...',
                        'در حال دریافت معلومات...',
                        'Loading rates...',
                      )
                    : tr(
                        'د دې بازار نرخونه اوس نشته',
                        'نرخ این بازار موجود نیست',
                        'No rates available for this market',
                      ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ...List.generate(uniqueRows.length, (index) {
          final row = uniqueRows[index];
          final title = '${row['label'] ?? ''}';
          final code = marketCurrencyCode(title);
          final flag = flags[code] ?? '🌐';
          final unit = toNumber(row['unit']) ?? 1;
          final safeUnit = unit > 0 ? unit : 1;

          String showRate(dynamic value) {
            final n = toNumber(value);
            if (n == null) return '—';
            return money(n / safeUnit, decimals: 4);
          }

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              color: index.isEven
                  ? Theme.of(context).cardColor
                  : Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withOpacity(.35),
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
                      Text(
                        flag,
                        style: const TextStyle(fontSize: 26),
                      ),
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
                            if (unit > 1)
                              Text(
                                tr(
                                  'د هر واحد نرخ',
                                  'نرخ هر واحد',
                                  'Per unit',
                                ),
                                style: const TextStyle(fontSize: 9),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    showRate(row['buy']),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xff07834f),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    showRate(row['sell']),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xff1598c7),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        tr(
                          'د اسعارو نرخونه',
                          'نرخ اسعار',
                          'Currency exchange rates',
                        ),
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
          if (offline) notice(error, Colors.red),
          if (!offline && error.isNotEmpty) notice(error, Colors.orange),
          if (updatedAt.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 5,
              ),
              child: Text(
                '${tr('وروستی تازه کول', 'آخرین بروزرسانی', 'Last checked')}: ${formatDate(updatedAt)}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ),
          marketSelector(),
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
              tr(
                'د نړۍ ټول موجود اسعار',
                'تمام ارزهای موجود جهان',
                'World currencies',
              ),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          if (worldIsStale)
            notice(
              tr(
                'د نړۍ نرخونه تازه نه دي.',
                'نرخ‌های جهانی تازه نیستند.',
                'World rates are not fresh.',
              ),
              Colors.orange,
            ),
          if (worldUpdatedAt.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                '${tr('د نړۍ د نرخونو وخت', 'زمان نرخ‌های جهانی', 'World rates update')}: ${formatDate(worldUpdatedAt)}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                tr(
                  'اوس مهال معلومات نشته',
                  'معلومات موجود نیست',
                  'No data available',
                ),
              ),
            ),
          ...items.map((item) {
            final code = '${item['code'] ?? ''}'.toUpperCase();
            final rate = item['afnPerUnit'] ?? item['rate'];

            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 3,
              ),
              child: ListTile(
                leading: Text(
                  flags[code] ?? '🌐',
                  style: const TextStyle(fontSize: 28),
                ),
                title: Text(
                  '$code/AFN',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(currencyName(code, lang)),
                trailing: Text(
                  money(rate, decimals: 4),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xff7944ad),
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

  Widget currencyDropdown({
    required String value,
    required ValueChanged<String?> onChanged,
    required String label,
  }) {
    final codes = currencyCodes;
    final safeValue = codes.contains(value) ? value : 'AFN';

    return DropdownButtonFormField<String>(
      value: safeValue,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.currency_exchange),
      ),
      items: codes.map((code) {
        return DropdownMenuItem(
          value: code,
          child: Text(
            '${flags[code] ?? '🌐'}  $code - ${currencyName(code, lang)}',
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget converterPage() {
    final result = conversionResult;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          tr(
            'د اسعارو تبدیلول',
            'تبدیل اسعار',
            'Currency converter',
          ),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 21,
          ),
        ),
        const SizedBox(height: 15),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: tr('مقدار', 'مقدار', 'Amount'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.payments),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                currencyDropdown(
                  value: fromCurrency,
                  label: tr(
                    'له کوم اسعارو',
                    'از کدام ارز',
                    'From currency',
                  ),
                  onChanged: (v) {
                    if (v != null) setState(() => fromCurrency = v);
                  },
                ),
                const SizedBox(height: 12),
                IconButton.filled(
                  onPressed: () {
                    setState(() {
                      final old = fromCurrency;
                      fromCurrency = toCurrency;
                      toCurrency = old;
                    });
                  },
                  icon: const Icon(Icons.swap_vert),
                ),
                const SizedBox(height: 12),
                currencyDropdown(
                  value: toCurrency,
                  label: tr(
                    'کوم اسعارو ته',
                    'به کدام ارز',
                    'To currency',
                  ),
                  onChanged: (v) {
                    if (v != null) setState(() => toCurrency = v);
                  },
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xff07834f),
                        Color(0xff13a66a),
                      ],
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
                            : '${money(result, decimals: 4)} $toCurrency',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  tr(
                    'حساب د ټاکل شوي بازار د پېر نرخ او د اړتیا پر مهال د نړیوال مرجع نرخ پر بنسټ کېږي.',
                    'محاسبه بر اساس نرخ خرید بازار انتخاب‌شده و در صورت نیاز نرخ مرجع جهانی انجام می‌شود.',
                    'Conversion uses the selected market buy rate and falls back to the world reference rate when needed.',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
                if (worldIsStale)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      tr(
                        'یادونه: نړیوال نرخونه زاړه دي.',
                        'توجه: نرخ‌های جهانی قدیمی هستند.',
                        'Note: World reference rates are stale.',
                      ),
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                    ),
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
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
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
          title: Text(
            tr('نرخونه تازه کړه', 'بروزرسانی نرخ‌ها', 'Refresh rates'),
          ),
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
                  ? const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
        ),
        Center(
          child: TextButton.icon(
            onPressed: changePhoto,
            icon: const Icon(Icons.camera_alt),
            label: Text(
              tr('عکس بدل کړئ', 'تغییر عکس', 'Change photo'),
            ),
          ),
        ),
        const Center(
          child: Text(
            'Abdullah Eman',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Center(
          child: Text(
            tr(
              'د اپلیکیشن جوړوونکی',
              'سازنده اپلیکیشن',
              'App Developer',
            ),
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
                  tr(
                    'د افغانۍ تاریخ',
                    'تاریخ افغانی',
                    'History of the Afghani',
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
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
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
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
        onDestinationSelected: (index) {
          setState(() => page = index);
        },
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
            label: tr('په اړه', 'درباره', 'About'),
          ),
        ],
      ),
    );
  }
}
