import 'dart:async';
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

String tr(String lang, String ps, String fa, String en) {
  if (lang == 'fa') return fa;
  if (lang == 'en') return en;
  return ps;
}

const Map<String, String> currencyFlags = {
  'AFN': '🇦🇫',
  'USD': '🇺🇸',
  'EUR': '🇪🇺',
  'GBP': '🇬🇧',
  'PKR': '🇵🇰',
  'IRR': '🇮🇷',
  'INR': '🇮🇳',
  'CNY': '🇨🇳',
  'AED': '🇦🇪',
  'SAR': '🇸🇦',
  'TRY': '🇹🇷',
  'RUB': '🇷🇺',
  'CAD': '🇨🇦',
  'AUD': '🇦🇺',
  'JPY': '🇯🇵',
  'CHF': '🇨🇭',
  'KWD': '🇰🇼',
  'QAR': '🇶🇦',
  'OMR': '🇴🇲',
  'BDT': '🇧🇩',
  'UZS': '🇺🇿',
  'KZT': '🇰🇿',
  'TJS': '🇹🇯',
  'MYR': '🇲🇾',
  'THB': '🇹🇭',
  'SGD': '🇸🇬',
  'SEK': '🇸🇪',
  'NOK': '🇳🇴',
  'DKK': '🇩🇰',
  'NZD': '🇳🇿',
  'BRL': '🇧🇷',
  'ZAR': '🇿🇦',
  'EGP': '🇪🇬',
  'IQD': '🇮🇶',
  'BHD': '🇧🇭',
  'JOD': '🇯🇴',
  'LKR': '🇱🇰',
  'NPR': '🇳🇵',
  'KRW': '🇰🇷',
  'HKD': '🇭🇰',
};

const Map<String, String> currencyNames = {
  'AFN': 'افغانۍ',
  'USD': 'US Dollar',
  'EUR': 'Euro',
  'GBP': 'British Pound',
  'PKR': 'Pakistani Rupee',
  'IRR': 'Iranian Rial',
  'INR': 'Indian Rupee',
  'CNY': 'Chinese Yuan',
  'AED': 'UAE Dirham',
  'SAR': 'Saudi Riyal',
  'TRY': 'Turkish Lira',
  'RUB': 'Russian Ruble',
  'CAD': 'Canadian Dollar',
  'AUD': 'Australian Dollar',
  'JPY': 'Japanese Yen',
  'CHF': 'Swiss Franc',
  'KWD': 'Kuwaiti Dinar',
  'QAR': 'Qatari Riyal',
  'OMR': 'Omani Rial',
  'BDT': 'Bangladeshi Taka',
  'UZS': 'Uzbekistani Som',
  'KZT': 'Kazakhstani Tenge',
  'TJS': 'Tajikistani Somoni',
  'MYR': 'Malaysian Ringgit',
  'THB': 'Thai Baht',
  'SGD': 'Singapore Dollar',
  'SEK': 'Swedish Krona',
  'NOK': 'Norwegian Krone',
  'DKK': 'Danish Krone',
  'NZD': 'New Zealand Dollar',
  'BRL': 'Brazilian Real',
  'ZAR': 'South African Rand',
  'EGP': 'Egyptian Pound',
  'IQD': 'Iraqi Dinar',
  'BHD': 'Bahraini Dinar',
  'JOD': 'Jordanian Dinar',
  'LKR': 'Sri Lankan Rupee',
  'NPR': 'Nepalese Rupee',
  'KRW': 'South Korean Won',
  'HKD': 'Hong Kong Dollar',
};

String currencyName(String code, String lang) {
  if (lang == 'ps') {
    const names = {
      'USD': 'امریکایي ډالر',
      'EUR': 'یورو',
      'GBP': 'انګلیسي پونډ',
      'PKR': 'پاکستانۍ روپۍ',
      'IRR': 'ایراني تومان/ریال',
      'INR': 'هندي روپۍ',
      'CNY': 'چینایي یوان',
      'AED': 'اماراتي درهم',
      'SAR': 'سعودي ریال',
      'TRY': 'ترکي لیره',
    };
    return names[code] ?? currencyNames[code] ?? code;
  }

  if (lang == 'fa') {
    const names = {
      'USD': 'دالر آمریکایی',
      'EUR': 'یورو',
      'GBP': 'پوند انگلیس',
      'PKR': 'روپیه پاکستان',
      'IRR': 'ریال ایران',
      'INR': 'روپیه هند',
      'CNY': 'یوان چین',
      'AED': 'درهم امارات',
      'SAR': 'ریال سعودی',
      'TRY': 'لیره ترکیه',
    };
    return names[code] ?? currencyNames[code] ?? code;
  }

  return currencyNames[code] ?? code;
}

String codeOf(String label) {
  final text = label.toUpperCase();

  for (final code in currencyFlags.keys) {
    if (text.contains(code)) return code;
  }

  if (text.contains('DOLLAR')) return 'USD';
  if (text.contains('EURO')) return 'EUR';
  if (text.contains('POUND')) return 'GBP';
  if (text.contains('PAKISTAN')) return 'PKR';
  if (text.contains('INDIA')) return 'INR';
  if (text.contains('IRAN')) return 'IRR';
  if (text.contains('DIRHAM')) return 'AED';
  if (text.contains('YUAN')) return 'CNY';

  return '';
}

String money(num? value) {
  if (value == null) return '—';
  return value.toStringAsFixed(2);
}

class AfghaniExchangeApp extends StatefulWidget {
  const AfghaniExchangeApp({super.key});

  @override
  State<AfghaniExchangeApp> createState() =>
      _AfghaniExchangeAppState();
}

class _AfghaniExchangeAppState extends State<AfghaniExchangeApp> {
  String lang = 'ps';
  bool dark = false;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      lang = prefs.getString('language') ?? 'ps';
      dark = prefs.getBool('dark') ?? false;
    });
  }

  Future<void> changeLanguage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', value);
    if (mounted) setState(() => lang = value);
  }

  Future<void> changeTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark', value);
    if (mounted) setState(() => dark = value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afghani Exchange Pro',
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF087F5B),
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F7F8),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF16A085),
        brightness: Brightness.dark,
      ),
      home: ExchangeHome(
        lang: lang,
        dark: dark,
        onLanguage: changeLanguage,
        onTheme: changeTheme,
      ),
    );
  }
}

class ExchangeHome extends StatefulWidget {
  final String lang;
  final bool dark;
  final ValueChanged<String> onLanguage;
  final ValueChanged<bool> onTheme;

  const ExchangeHome({
    super.key,
    required this.lang,
    required this.dark,
    required this.onLanguage,
    required this.onTheme,
  });

  @override
  State<ExchangeHome> createState() => _ExchangeHomeState();
}

class _ExchangeHomeState extends State<ExchangeHome> {
  Map<String, dynamic> markets = {};
  List<Map<String, dynamic>> world = [];

  bool loading = false;
  bool worldStale = false;
  String? error;

  DateTime? checkedAt;
  DateTime? worldUpdated;
  int? worldAge;

  String market = 'bank';
  String bankType = 'cash';
  int page = 0;

  String from = 'USD';
  String to = 'AFN';

  final TextEditingController amount =
      TextEditingController(text: '1');

  String? photoPath;
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    loadLocalData();
    fetchRates();

    refreshTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => fetchRates(),
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    amount.dispose();
    super.dispose();
  }

  Future<void> loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();

    final savedMarkets = prefs.getString('markets');
    final savedWorld = prefs.getString('world');

    if (!mounted) return;

    setState(() {
      photoPath = prefs.getString('developer_photo');

      if (savedMarkets != null) {
        try {
          markets = Map<String, dynamic>.from(
            jsonDecode(savedMarkets),
          );
        } catch (_) {}
      }

      if (savedWorld != null) {
        try {
          world = (jsonDecode(savedWorld) as List)
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        } catch (_) {}
      }
    });
  }

  Future<void> fetchRates() async {
    if (loading) return;

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final response = await http.get(
        Uri.parse(workerUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map) {
        throw Exception('Invalid server response');
      }

      final data = Map<String, dynamic>.from(decoded);
      final rawMarkets = data['markets'];

      final newMarkets = <String, dynamic>{};

      if (rawMarkets is Map) {
        for (final entry in rawMarkets.entries) {
          newMarkets[entry.key.toString()] =
              Map<String, dynamic>.from(entry.value as Map);
        }
      }

      final rawWorld = data['world'];
      final newWorld = <Map<String, dynamic>>[];

      if (rawWorld is List) {
        for (final item in rawWorld) {
          if (item is Map) {
            newWorld.add(Map<String, dynamic>.from(item));
          }
        }
      }

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        'markets',
        jsonEncode(newMarkets),
      );

      await prefs.setString(
        'world',
        jsonEncode(newWorld),
      );

      final updated = DateTime.tryParse(
        data['updatedAt']?.toString() ?? '',
      );

      if (!mounted) return;

      setState(() {
        markets = newMarkets;
        world = newWorld;
        worldUpdated = updated;
        checkedAt = DateTime.now();

        worldStale = data['worldIsStale'] == true;

        final age = data['worldAgeMinutes'];
        worldAge = age is num ? age.toInt() : null;

        if (data['worldIsStale'] == true) {
          worldStale = true;
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  String marketName(String key) {
    switch (key) {
      case 'bank':
        return tr(widget.lang, 'د افغانستان بانک', 'بانک مرکزی افغانستان', 'Da Afghanistan Bank');
      case 'sarai':
        return tr(widget.lang, 'سرای شهزاده', 'سرای شهزاده', 'Sarai Shahzada');
      case 'khorasan':
        return tr(widget.lang, 'خراسان هرات', 'خراسان هرات', 'Khorasan Herat');
      case 'kandahar':
        return tr(widget.lang, 'کندهار', 'قندهار', 'Kandahar');
      case 'nangarhar':
        return tr(widget.lang, 'ننګرهار', 'ننگرهار', 'Nangarhar');
      default:
        return key;
    }
  }

  List<Map<String, dynamic>> selectedRows() {
    final data = markets[market];

    if (data is! Map) return [];

    final marketData = Map<String, dynamic>.from(data);

    dynamic rawRows;

    if (market == 'bank') {
      if (bankType == 'transfer') {
        rawRows = marketData['transferRows'];
      } else if (bankType == 'average') {
        rawRows = marketData['averageRows'];
      } else {
        rawRows = marketData['rows'];
      }
    } else {
      rawRows = marketData['rows'];
    }

    if (rawRows is! List) return [];

    return rawRows
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  double? converted() {
    final input = double.tryParse(
      amount.text.replaceAll(',', '').trim(),
    );

    if (input == null) return null;

    if (from == to) return input;

    if (from == 'AFN') {
      final target = worldRate(to);
      if (target == null || target == 0) return null;
      return input / target;
    }

    final source = worldRate(from);
    if (source == null || source == 0) return null;

    if (to == 'AFN') {
      return input * source;
    }

    final target = worldRate(to);
    if (target == null || target == 0) return null;

    return input * source / target;
  }

  double? worldRate(String code) {
    if (code == 'AFN') return 1;

    for (final item in world) {
      if (item['code']?.toString().toUpperCase() == code) {
        final value = item['afnPerUnit'];
        if (value is num) return value.toDouble();
      }
    }

    final rows = selectedRows();

    for (final row in rows) {
      final label = row['label']?.toString() ?? '';
      if (codeOf(label) == code) {
        final value = row['buy'];
        if (value is num) return value.toDouble();
      }
    }

    return null;
  }

  Future<void> choosePhoto() async {
    try {
      final picker = ImagePicker();

      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (image == null) return;

      final directory = await getApplicationDocumentsDirectory();

      final extension = image.path.contains('.')
          ? image.path.split('.').last
          : 'jpg';

      final savedFile = await File(image.path).copy(
        '${directory.path}/developer_photo.$extension',
      );

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        'developer_photo',
        savedFile.path,
      );

      if (!mounted) return;

      setState(() => photoPath = savedFile.path);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Photo error: $e')),
      );
    }
  }

  Widget pageBody() {
    switch (page) {
      case 0:
        return marketsPage();
      case 1:
        return worldPage();
      case 2:
        return converterPage();
      case 3:
        return settingsPage();
      case 4:
        return developerPage();
      default:
        return aboutPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = [
      tr(widget.lang, 'بازارونه', 'بازارها', 'Markets'),
      tr(widget.lang, 'نړیوال اسعار', 'ارزهای جهان', 'World'),
      tr(widget.lang, 'بدلون', 'تبدیل', 'Convert'),
      tr(widget.lang, 'تنظیمات', 'تنظیمات', 'Settings'),
      tr(widget.lang, 'جوړوونکی', 'سازنده', 'Developer'),
      tr(widget.lang, 'په اړه', 'درباره', 'About'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Afghani Exchange Pro',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: loading ? null : fetchRates,
            icon: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: pageBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: page,
        onDestinationSelected: (v) => setState(() => page = v),
        destinations: [
          for (int i = 0; i < labels.length; i++)
            NavigationDestination(
              icon: Icon([
                Icons.storefront,
                Icons.public,
                Icons.currency_exchange,
                Icons.settings,
                Icons.person,
                Icons.info_outline,
              ][i]),
              label: labels[i],
            ),
        ],
      ),
    );
  }

  Widget marketsPage() {
    final rows = selectedRows();
    final marketData = Map<String, dynamic>.from(
      markets[market] ?? {},
    );

    return RefreshIndicator(
      onRefresh: fetchRates,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          if (error != null) _notice(error!, Colors.red),
          _statusCard(),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: market,
            decoration: InputDecoration(
              labelText: tr(
                widget.lang,
                'بازار او سرچینه',
                'بازار و منبع',
                'Market / Source',
              ),
              border: const OutlineInputBorder(),
            ),
            items: [
              'bank',
              'sarai',
              'khorasan',
              'kandahar',
              'nangarhar',
            ].map((k) {
              return DropdownMenuItem(
                value: k,
                child: Text(marketName(k)),
              );
            }).toList(),
            onChanged: (v) {
              if (v != null) setState(() => market = v);
            },
          ),

          if (market == 'bank') ...[
            const SizedBox(height: 10),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'cash',
                  label: Text(tr(widget.lang, 'نغدې', 'نقدی', 'Cash')),
                ),
                ButtonSegment(
                  value: 'transfer',
                  label: Text(tr(widget.lang, 'حواله', 'حواله', 'Transfer')),
                ),
                ButtonSegment(
                  value: 'average',
                  label: Text(tr(widget.lang, 'اوسط', 'اوسط', 'Average')),
                ),
              ],
              selected: {bankType},
              onSelectionChanged: (s) {
                setState(() => bankType = s.first);
              },
            ),
          ],

          const SizedBox(height: 12),

          if (marketData['rateType'] == 'indicative')
            _notice(
              tr(
                widget.lang,
                'دا نرخونه اټکلي/بازاري دي؛ رسمي بانکي نرخونه نه دي.',
                'این نرخ‌ها تقریبی/بازاری‌اند و نرخ رسمی بانکی نیستند.',
                'These are indicative market rates, not official bank-dealer quotes.',
              ),
              Colors.orange,
            ),

          if (marketData['error'] != null && rows.isEmpty)
            _notice(
              tr(
                widget.lang,
                'د دې سرچینې نرخونه اوس ونه لوستل شول. وروسته بیا هڅه وکړئ.',
                'نرخ‌های این منبع فعلاً خوانده نشد. بعداً دوباره تلاش کنید.',
                'Rates from this source could not be read right now. Please try again later.',
              ),
              Colors.orange,
            ),

          if (rows.isEmpty && loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),

          if (rows.isEmpty && !loading)
            _empty(
              tr(
                widget.lang,
                'اوس مهال نرخونه نشته.',
                'فعلاً نرخی موجود نیست.',
                'No rates currently available.',
              ),
            ),

          if (rows.isNotEmpty) _rateTable(rows),

          const SizedBox(height: 16),

          Text(
            tr(
              widget.lang,
              'یادونه: د بازار نرخونه د سرچینې د تازه کولو له وخت سره تړلي دي.',
              'یادداشت: نرخ بازار وابسته به زمان به‌روزرسانی منبع است.',
              'Note: market rates depend on when the source provider updates its data.',
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _rateTable(List<Map<String, dynamic>> rows) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    tr(widget.lang, 'اسعار', 'ارز', 'Currency'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    tr(widget.lang, 'اخیستل', 'خرید', 'Buy'),
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    tr(widget.lang, 'پلورل', 'فروش', 'Sell'),
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          for (final r in rows)
            Builder(
              builder: (context) {
                final label = r['label']?.toString() ?? '';
                final code = codeOf(label);

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 11,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Row(
                          children: [
                            Text(
                              currencyFlags[code] ?? '💱',
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    code.isEmpty ? label : code,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    label,
                                    style: Theme.of(context).textTheme.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Text(
                          money(r['buy'] as num?),
                          textAlign: TextAlign.end,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          money(r['sell'] as num?),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget worldPage() {
    final list = [...world]
      ..sort(
        (a, b) => (a['code'] ?? '')
            .toString()
            .compareTo((b['code'] ?? '').toString()),
      );

    return RefreshIndicator(
      onRefresh: fetchRates,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          _statusCard(),

          if (worldStale)
            _notice(
              tr(
                widget.lang,
                'د نړیوالو اسعارو سرچینه زاړه معلومات لري؛ دا نرخونه ژوندۍ/ثانیه‌يي نه دي.',
                'منبع ارز جهانی اطلاعات قدیمی دارد؛ این نرخ‌ها لحظه‌ای نیستند.',
                'World-rate provider data is stale; these are not live tick-by-tick rates.',
              ),
              Colors.orange,
            ),

          if (list.isEmpty)
            _empty(
              tr(
                widget.lang,
                'نړیوال نرخونه نشته.',
                'نرخ جهانی موجود نیست.',
                'World rates are unavailable.',
              ),
            ),

          if (list.isNotEmpty)
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (final item in list)
                    ListTile(
                      dense: true,
                      leading: Text(
                        currencyFlags[item['code']] ?? '🌐',
                        style: const TextStyle(fontSize: 23),
                      ),
                      title: Text(
                        '${item['code']}  ${currencyName(item['code'].toString(), widget.lang)}',
                      ),
                      trailing: Text(
                        '${money((item['afnPerUnit'] as num?)?.toDouble())} AFN',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget converterPage() {
    final codes = <String>{
      'AFN',
      ...world.map((e) => e['code'].toString()),
      ...selectedRows().map(
        (e) => codeOf(e['label']?.toString() ?? ''),
      ),
    }.where((e) => e.length == 3).toList()
      ..sort();

    final availableCodes = codes.isEmpty ? ['AFN'] : codes;

    final selectedFrom =
        availableCodes.contains(from) ? from : availableCodes.first;
    final selectedTo =
        availableCodes.contains(to) ? to : 'AFN';

    final result = converted();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _statusCard(),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  tr(
                    widget.lang,
                    'د اسعارو بدلون',
                    'تبدیل ارز',
                    'Currency Converter',
                  ),
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: amount,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: tr(widget.lang, 'اندازه', 'مقدار', 'Amount'),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),

                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: selectedFrom,
                  decoration: InputDecoration(
                    labelText: tr(widget.lang, 'له', 'از', 'From'),
                    border: const OutlineInputBorder(),
                  ),
                  items: availableCodes.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Text('${currencyFlags[c] ?? '🌐'} $c'),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => from = v);
                  },
                ),

                IconButton(
                  onPressed: () {
                    setState(() {
                      final x = from;
                      from = to;
                      to = x;
                    });
                  },
                  icon: const Icon(Icons.swap_vert, size: 30),
                ),

                DropdownButtonFormField<String>(
                  value: selectedTo,
                  decoration: InputDecoration(
                    labelText: tr(widget.lang, 'ته', 'به', 'To'),
                    border: const OutlineInputBorder(),
                  ),
                  items: availableCodes.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Text('${currencyFlags[c] ?? '🌐'} $c'),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => to = v);
                  },
                ),

                const SizedBox(height: 16),

                Text(
                  result == null ? '— $selectedTo' : '${money(result)} $selectedTo',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),

                const SizedBox(height: 6),

                Text(
                  tr(
                    widget.lang,
                    'محاسبه د موجودو نړیوالو مرجع نرخونو له مخې کېږي.',
                    'محاسبه بر اساس نرخ‌های مرجع جهانی موجود انجام می‌شود.',
                    'Calculation uses the available world reference rates.',
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        DropdownButtonFormField<String>(
          value: market,
          decoration: InputDecoration(
            labelText: tr(
              widget.lang,
              'د محاسبې بازار',
              'بازار محاسبه',
              'Calculation market',
            ),
            border: const OutlineInputBorder(),
          ),
          items: [
            'bank',
            'sarai',
            'khorasan',
            'kandahar',
            'nangarhar',
          ].map((k) {
            return DropdownMenuItem(
              value: k,
              child: Text(marketName(k)),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) setState(() => market = v);
          },
        ),
      ],
    );
  }

  Widget settingsPage() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Text(
        tr(widget.lang, 'تنظیمات', 'تنظیمات', 'Settings'),
        style: Theme.of(context).textTheme.titleLarge,
      ),

      SwitchListTile(
        title: Text(
          tr(widget.lang, 'تیاره بڼه', 'حالت تاریک', 'Dark mode'),
        ),
        value: widget.dark,
        onChanged: widget.onTheme,
        secondary: const Icon(Icons.dark_mode),
      ),

      const SizedBox(height: 10),

      Text(
        tr(widget.lang, 'ژبه', 'زبان', 'Language'),
        style: Theme.of(context).textTheme.titleMedium,
      ),

      RadioListTile<String>(
        value: 'ps',
        groupValue: widget.lang,
        title: const Text('پښتو'),
        onChanged: (v) {
          if (v != null) widget.onLanguage(v);
        },
      ),

      RadioListTile<String>(
        value: 'fa',
        groupValue: widget.lang,
        title: const Text('دری'),
        onChanged: (v) {
          if (v != null) widget.onLanguage(v);
        },
      ),

      RadioListTile<String>(
        value: 'en',
        groupValue: widget.lang,
        title: const Text('English'),
        onChanged: (v) {
          if (v != null) widget.onLanguage(v);
        },
      ),
    ],
  );

  Widget developerPage() => ListView(
    padding: const EdgeInsets.all(18),
    children: [
      const SizedBox(height: 12),

      Center(
        child: GestureDetector(
          onTap: choosePhoto,
          child: CircleAvatar(
            radius: 66,
            backgroundImage: photoPath != null &&
                    File(photoPath!).existsSync()
                ? FileImage(File(photoPath!))
                : null,
            child: photoPath == null
                ? const Icon(Icons.add_a_photo, size: 42)
                : null,
          ),
        ),
      ),

      const SizedBox(height: 12),

      Center(
        child: Text(
          'Abdullah Eman',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),

      Center(
        child: Text(
          tr(
            widget.lang,
            'د اپلیکیشن جوړوونکی',
            'سازنده اپلیکیشن',
            'App Developer',
          ),
        ),
      ),

      const SizedBox(height: 14),

      OutlinedButton.icon(
        onPressed: choosePhoto,
        icon: const Icon(Icons.photo_library),
        label: Text(
          tr(widget.lang, 'عکس بدلول', 'تغییر عکس', 'Change Photo'),
        ),
      ),

      Text(
        tr(
          widget.lang,
          'عکس یوازې په همدې موبایل کې ساتل کېږي او د اپ له بندېدو وروسته هم پاتې کېږي.',
          'عکس فقط در همین موبایل ذخیره می‌شود و پس از بستن برنامه باقی می‌ماند.',
          'The photo is stored locally on this device and remains after the app closes.',
        ),
      ),
    ],
  );

  Widget aboutPage() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Text(
        tr(
          widget.lang,
          'د Afghani Exchange Pro په اړه',
          'درباره Afghani Exchange Pro',
          'About Afghani Exchange Pro',
        ),
        style: Theme.of(context).textTheme.titleLarge,
      ),

      const SizedBox(height: 12),

      Text(
        tr(
          widget.lang,
          'دا اپ د افغانستان د بېلابېلو بازارونو او نړیوالو اسعارو د معلوماتو د کتلو او د اسعارو د بدلون لپاره جوړ شوی دی.',
          'این برنامه برای مشاهده نرخ بازارهای مختلف افغانستان، ارزهای جهانی و تبدیل ارز ساخته شده است.',
          'This app displays rates from several Afghan market sources, world reference currencies, and currency conversions.',
        ),
      ),

      const SizedBox(height: 12),

      const Text('Version 7'),

      const SizedBox(height: 8),

      Text(
        tr(
          widget.lang,
          'د نرخونو دقت او تازه‌والی د اصلي سرچینو په معلوماتو پورې تړلی دی. د معاملې مخکې نرخ له صراف سره تایید کړئ.',
          'دقت و تازگی نرخ‌ها به اطلاعات منابع اصلی بستگی دارد. پیش از معامله نرخ را با صراف تأیید کنید.',
          'Accuracy and freshness depend on upstream providers. Confirm a rate with the exchange dealer before making a transaction.',
        ),
      ),
    ],
  );

  Widget _statusCard() => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(
            worldStale ? Icons.warning_amber : Icons.check_circle,
            color: worldStale ? Colors.orange : Colors.green,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(
                    widget.lang,
                    'د معلوماتو حالت',
                    'وضعیت اطلاعات',
                    'Data status',
                  ),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                Text(
                  worldUpdated == null
                      ? tr(
                          widget.lang,
                          'د نړیوالو سرچینو وخت معلوم نه دی',
                          'زمان منبع جهانی نامشخص است',
                          'World source time unavailable',
                        )
                      : '${tr(widget.lang, 'د نړیوالو سرچینو تازه کېدل', 'به‌روزرسانی منبع جهانی', 'World source update')}: ${worldUpdated!.toLocal()}',
                ),

                if (worldAge != null)
                  Text(
                    '${tr(widget.lang, 'د معلوماتو عمر', 'سن اطلاعات', 'Data age')}: ${worldAge! ~/ 60}h ${worldAge! % 60}m',
                  ),

                if (checkedAt != null)
                  Text(
                    '${tr(widget.lang, 'API کتلی', 'بررسی API', 'API checked')}: ${checkedAt!.toLocal()}',
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _notice(String text, Color color) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withOpacity(.12),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(text),
  );

  Widget _empty(String text) => Padding(
    padding: const EdgeInsets.all(24),
    child: Center(
      child: Text(text, textAlign: TextAlign.center),
    ),
  );
}
