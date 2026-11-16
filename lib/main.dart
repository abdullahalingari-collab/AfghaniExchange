import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AfghaniExchangeApp());
}

class MarketRate {
  final String code;
  final String name;
  final String flag;
  final double buy;
  final double sell;
  final String unit;

  const MarketRate({
    required this.code,
    required this.name,
    required this.flag,
    required this.buy,
    required this.sell,
    this.unit = '',
  });
}

class MarketData {
  final String title;
  final String url;
  final List<MarketRate> rates;
  final String updated;
  final String? error;

  const MarketData({
    required this.title,
    required this.url,
    this.rates = const [],
    this.updated = '',
    this.error,
  });
}

const currencyInfo = <String, List<String>>{
  'USD': ['US Dollar', '🇺🇸', ''],
  'EUR': ['Euro', '🇪🇺', ''],
  'GBP': ['British Pound', '🇬🇧', ''],
  'INR': ['Indian Rupee', '🇮🇳', '1K'],
  'IRR': ['Iranian Rial / Toman', '🇮🇷', '1K'],
  'PKR': ['Pakistani Rupee', '🇵🇰', '1K'],
  'SAR': ['Saudi Riyal', '🇸🇦', ''],
  'AED': ['UAE Dirham', '🇦🇪', ''],
  'CHF': ['Swiss Franc', '🇨🇭', ''],
  'AUD': ['Australian Dollar', '🇦🇺', ''],
  'CAD': ['Canadian Dollar', '🇨🇦', ''],
  'RUB': ['Russian Ruble', '🇷🇺', ''],
  'DKK': ['Danish Krone', '🇩🇰', ''],
  'SEK': ['Swedish Krona', '🇸🇪', ''],
  'NOK': ['Norwegian Krone', '🇳🇴', ''],
  'TRY': ['Turkish Lira', '🇹🇷', ''],
  'CNY': ['Chinese Yuan', '🇨🇳', ''],
  'KWD': ['Kuwaiti Dinar', '🇰🇼', ''],
  'QAR': ['Qatari Riyal', '🇶🇦', ''],
  'BHD': ['Bahraini Dinar', '🇧🇭', ''],
  'JPY': ['Japanese Yen', '🇯🇵', '1K'],
};

const translations = <String, Map<String, String>>{
  'ps': {
    'app': 'افغاني اکسچینج پرو',
    'bank': 'د افغانستان بانک',
    'sarai': 'سرای شهزاده',
    'khorasan': 'خراسان مارکیټ',
    'developer': 'جوړوونکی',
    'buy': 'پېرود',
    'sell': 'پلور',
    'cash': 'نغدي نرخ',
    'refresh': 'نرخونه تازه کړه',
    'updated': 'وروستی تازه کېدل',
    'loading': 'نرخونه ترلاسه کېږي...',
    'noRates': 'نرخونه ترلاسه نه شول',
    'retry': 'بیا هڅه',
    'changePhoto': 'عکس بدل کړه',
    'removePhoto': 'عکس لرې کړه',
    'photoSaved': 'عکس خوندي شو',
    'photoError': 'عکس انتخاب نه شو',
    'language': 'ژبه',
    'dark': 'تیاره بڼه',
    'light': 'روښانه بڼه',
    'sourceNote': 'دا د سرچینې خپاره شوي نرخونه دي.',
    'name': 'Abdullah Eman',
    'source': 'اصلي سرچینه',
  },
  'fa': {
    'app': 'افغانی اکسچنج پرو',
    'bank': 'د افغانستان بانک',
    'sarai': 'سرای شهزاده',
    'khorasan': 'مارکیت خراسان',
    'developer': 'سازنده',
    'buy': 'خرید',
    'sell': 'فروش',
    'cash': 'نرخ نقدی',
    'refresh': 'تازه‌سازی نرخ‌ها',
    'updated': 'آخرین به‌روزرسانی',
    'loading': 'در حال دریافت نرخ‌ها...',
    'noRates': 'نرخ‌ها دریافت نشد',
    'retry': 'تلاش دوباره',
    'changePhoto': 'تغییر عکس',
    'removePhoto': 'حذف عکس',
    'photoSaved': 'عکس ذخیره شد',
    'photoError': 'انتخاب عکس ناموفق بود',
    'language': 'زبان',
    'dark': 'حالت تاریک',
    'light': 'حالت روشن',
    'sourceNote': 'این نرخ‌های منتشرشده توسط منبع هستند.',
    'name': 'Abdullah Eman',
    'source': 'منبع اصلی',
  },
  'en': {
    'app': 'Afghani Exchange Pro',
    'bank': 'Da Afghanistan Bank',
    'sarai': 'Sarai Shahzada',
    'khorasan': 'Khorasan Market',
    'developer': 'Developer',
    'buy': 'Buy',
    'sell': 'Sell',
    'cash': 'Cash rate',
    'refresh': 'Refresh rates',
    'updated': 'Last updated',
    'loading': 'Loading rates...',
    'noRates': 'Rates could not be loaded',
    'retry': 'Try again',
    'changePhoto': 'Change photo',
    'removePhoto': 'Remove photo',
    'photoSaved': 'Photo saved',
    'photoError': 'Could not select photo',
    'language': 'Language',
    'dark': 'Dark mode',
    'light': 'Light mode',
    'sourceNote': 'These are rates published by the source.',
    'name': 'Abdullah Eman',
    'source': 'Original source',
  },
};

String currencyCode(String label) {
  final upper = label.toUpperCase();

  final pair = RegExp(
    r'\b([A-Z]{3})\s*/\s*AFN\b',
  ).firstMatch(upper);

  if (pair != null) return pair.group(1)!;

  if (upper.contains('US DOLLAR') || upper.contains('USD')) return 'USD';
  if (upper.contains('EURO')) return 'EUR';
  if (upper.contains('POUND') || upper.contains('GBP')) return 'GBP';
  if (upper.contains('INDIAN') || upper.contains('INR')) return 'INR';
  if (upper.contains('IRAN') || upper.contains('TOMAN') || upper.contains('IRR')) return 'IRR';
  if (upper.contains('PAKISTAN') || upper.contains('PKR')) return 'PKR';
  if (upper.contains('SAUDI') || upper.contains('SAR')) return 'SAR';
  if (upper.contains('UAE') || upper.contains('DIRHAM') || upper.contains('AED')) return 'AED';
  if (upper.contains('SWISS') || upper.contains('CHF')) return 'CHF';
  if (upper.contains('AUSTRALIAN') || upper.contains('AUD')) return 'AUD';
  if (upper.contains('CANADIAN') || upper.contains('CAD')) return 'CAD';
  if (upper.contains('RUSSIAN') || upper.contains('RUBLE') || upper.contains('RUB')) return 'RUB';
  if (upper.contains('DANISH') || upper.contains('DKK')) return 'DKK';
  if (upper.contains('SWEDISH') || upper.contains('SEK')) return 'SEK';
  if (upper.contains('NORWEGIAN') || upper.contains('NOK')) return 'NOK';
  if (upper.contains('TURKISH') || upper.contains('TRY')) return 'TRY';
  if (upper.contains('CHINESE') || upper.contains('CNY')) return 'CNY';
  if (upper.contains('KUWAIT') || upper.contains('KWD')) return 'KWD';
  if (upper.contains('QATAR') || upper.contains('QAR')) return 'QAR';
  if (upper.contains('BAHRAIN') || upper.contains('BHD')) return 'BHD';
  if (upper.contains('JAPAN') || upper.contains('JPY')) return 'JPY';

  return '';
}

double? numberFrom(String value) {
  final cleaned = value
      .replaceAll(',', '')
      .replaceAll(RegExp(r'[^0-9.\-]'), '');

  return double.tryParse(cleaned);
}

class RateService {
  static const saraiUrl =
      'https://sarafi.af/en/exchange-rates';

  static const khorasanUrl =
      'https://sarafi.af/en/exchange-rates/khorasan-market';

  static const bankUrl =
      'https://www.dab.gov.af/exchange-rates';

  static Future<MarketData> fetchSarafi({
    required String title,
    required String url,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0',
          'Accept': 'text/html',
        },
      ).timeout(const Duration(seconds: 25));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final doc = html_parser.parse(response.body);
      final results = <MarketRate>[];

      for (final row in doc.querySelectorAll('table tr')) {
        final cells = row.querySelectorAll('th,td');

        if (cells.length < 3) continue;

        final code = currencyCode(cells[0].text.trim());

        if (code.isEmpty || !currencyInfo.containsKey(code)) {
          continue;
        }

        final buy = numberFrom(cells[1].text);
        final sell = numberFrom(cells[2].text);

        if (buy == null || sell == null || buy <= 0 || sell <= 0) {
          continue;
        }

        final info = currencyInfo[code]!;

        results.add(
          MarketRate(
            code: code,
            name: info[0],
            flag: info[1],
            unit: info[2],
            buy: buy,
            sell: sell,
          ),
        );
      }

      if (results.isEmpty) {
        throw Exception('No exchange-rate rows found');
      }

      return MarketData(
        title: title,
        url: url,
        rates: results,
        updated: DateTime.now().toLocal().toString().substring(0, 16),
      );
    } catch (e) {
      return MarketData(
        title: title,
        url: url,
        error: e.toString(),
      );
    }
  }

  static Future<MarketData> fetchBank() async {
    try {
      final response = await http.get(
        Uri.parse(bankUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0',
          'Accept': 'text/html',
        },
      ).timeout(const Duration(seconds: 25));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final doc = html_parser.parse(response.body);
      final results = <MarketRate>[];

      for (final row in doc.querySelectorAll('table tr')) {
        final cells = row.querySelectorAll('th,td');

        if (cells.length < 5) continue;

        final code = currencyCode(cells[0].text.trim());

        if (code.isEmpty || !currencyInfo.containsKey(code)) {
          continue;
        }

        final cashSell = numberFrom(cells[1].text);
        final cashBuy = numberFrom(cells[2].text);

        if (cashBuy == null || cashSell == null ||
            cashBuy <= 0 || cashSell <= 0) {
          continue;
        }

        final info = currencyInfo[code]!;

        results.add(
          MarketRate(
            code: code,
            name: info[0],
            flag: info[1],
            unit: info[2],
            buy: cashBuy,
            sell: cashSell,
          ),
        );
      }

      if (results.isEmpty) {
        throw Exception('No official bank rates found');
      }

      return MarketData(
        title: 'Da Afghanistan Bank',
        url: bankUrl,
        rates: results,
        updated: DateTime.now().toLocal().toString().substring(0, 16),
      );
    } catch (e) {
      return MarketData(
        title: 'Da Afghanistan Bank',
        url: bankUrl,
        error: e.toString(),
      );
    }
  }
}

class AfghaniExchangeApp extends StatefulWidget {
  const AfghaniExchangeApp({super.key});

  @override
  State<AfghaniExchangeApp> createState() =>
      _AfghaniExchangeAppState();
}

class _AfghaniExchangeAppState
    extends State<AfghaniExchangeApp> {
  ThemeMode themeMode = ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afghani Exchange Pro',
      themeMode: themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF087F5B),
        ),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF16A085),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: ExchangeHome(
        onThemeChanged: (isDark) {
          setState(() {
            themeMode = isDark
                ? ThemeMode.dark
                : ThemeMode.light;
          });
        },
      ),
    );
  }
}

class ExchangeHome extends StatefulWidget {
  final ValueChanged<bool> onThemeChanged;

  const ExchangeHome({
    super.key,
    required this.onThemeChanged,
  });

  @override
  State<ExchangeHome> createState() => _ExchangeHomeState();
}

class _ExchangeHomeState extends State<ExchangeHome> {
  String language = 'ps';
  String? photoPath;
  bool loading = false;
  int selectedTab = 0;

  Timer? timer;

  MarketData? bankData;
  MarketData? saraiData;
  MarketData? khorasanData;

  final ImagePicker picker = ImagePicker();

  String tr(String key) =>
      translations[language]?[key] ?? key;

  @override
  void initState() {
    super.initState();

    loadSettings();
    refreshAll();

    timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => refreshAll(),
    );
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final savedPhoto = prefs.getString('developer_photo_path');

    if (!mounted) return;

    setState(() {
      language = prefs.getString('app_language') ?? 'ps';
      photoPath = savedPhoto;
    });

    if (savedPhoto != null &&
        !File(savedPhoto).existsSync()) {
      await prefs.remove('developer_photo_path');

      if (mounted) {
        setState(() => photoPath = null);
      }
    }
  }

  Future<void> setLanguage(String value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('app_language', value);

    if (mounted) {
      setState(() => language = value);
    }
  }

  Future<void> refreshAll() async {
    if (!mounted) return;

    setState(() => loading = true);

    final results = await Future.wait([
      RateService.fetchBank(),
      RateService.fetchSarafi(
        title: 'Sarai Shahzada',
        url: RateService.saraiUrl,
      ),
      RateService.fetchSarafi(
        title: 'Khorasan Market',
        url: RateService.khorasanUrl,
      ),
    ]);

    if (!mounted) return;

    setState(() {
      bankData = results[0];
      saraiData = results[1];
      khorasanData = results[2];
      loading = false;
    });
  }

  Future<void> choosePhoto() async {
    try {
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (picked == null) return;

      final directory =
          await getApplicationDocumentsDirectory();

      final destination = File(
        '${directory.path}/developer_profile.jpg',
      );

      await File(picked.path).copy(destination.path);

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        'developer_photo_path',
        destination.path,
      );

      if (!mounted) return;

      setState(() => photoPath = destination.path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('photoSaved'))),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('photoError'))),
      );
    }
  }

  Future<void> removePhoto() async {
    final oldPath = photoPath;

    if (oldPath != null) {
      final file = File(oldPath);

      if (await file.exists()) {
        await file.delete();
      }
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('developer_photo_path');

    if (mounted) {
      setState(() => photoPath = null);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      tr('bank'),
      tr('sarai'),
      tr('khorasan'),
      tr('developer'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🇦🇫',
              style: TextStyle(fontSize: 25),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                tr('app'),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: tr('language'),
            icon: const Icon(Icons.translate),
            onSelected: setLanguage,
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'ps',
                child: Text('پښتو'),
              ),
              PopupMenuItem(
                value: 'fa',
                child: Text('دری'),
              ),
              PopupMenuItem(
                value: 'en',
                child: Text('English'),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              widget.onThemeChanged(
                Theme.of(context).brightness !=
                    Brightness.dark,
              );
            },
            icon: const Icon(Icons.brightness_6_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF075E48),
                  Color(0xFF12966F),
                ],
              ),
            ),
            child: Row(
              children: [
                const Text(
                  '🇦🇫',
                  style: TextStyle(fontSize: 38),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tr('app'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  color: Colors.white,
                  onPressed: refreshAll,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 54,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: 7),
              itemBuilder: (context, index) {
                return ChoiceChip(
                  label: Text(tabs[index]),
                  selected: selectedTab == index,
                  onSelected: (_) {
                    setState(() => selectedTab = index);
                  },
                );
              },
            ),
          ),
          Expanded(child: buildSelectedPage()),
        ],
      ),
    );
  }

  Widget buildSelectedPage() {
    switch (selectedTab) {
      case 0:
        return marketPage(
          bankData,
          tr('bank'),
          true,
        );

      case 1:
        return marketPage(
          saraiData,
          tr('sarai'),
          false,
        );

      case 2:
        return marketPage(
          khorasanData,
          tr('khorasan'),
          false,
        );

      default:
        return developerPage();
    }
  }

  Widget marketPage(
    MarketData? data,
    String title,
    bool isBank,
  ) {
    if (loading && data == null) {
      return Center(child: Text(tr('loading')));
    }

    if (data == null ||
        data.error != null ||
        data.rates.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48),
              const SizedBox(height: 12),
              Text(tr('noRates')),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: refreshAll,
                icon: const Icon(Icons.refresh),
                label: Text(tr('retry')),
              ),
              if (data?.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    data!.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: refreshAll,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          12, 8, 12, 24,
        ),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        '🇦🇫',
                        style: TextStyle(fontSize: 25),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge,
                        ),
                      ),
                      if (loading)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${tr('updated')}: ${data.updated}',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tr('sourceNote'),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: refreshAll,
                      icon: const Icon(Icons.refresh),
                      label: Text(tr('refresh')),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...data.rates.map(
            (rate) => rateCard(rate, isBank),
          ),
          const SizedBox(height: 12),
          Text(
            '${tr('source')}: ${data.url}',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall,
          ),
        ],
      ),
    );
  }

  Widget rateCard(MarketRate rate, bool isBank) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  rate.flag,
                  style: const TextStyle(fontSize: 29),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        rate.code,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        rate.name,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall,
                      ),
                    ],
                  ),
                ),
                if (rate.unit.isNotEmpty && !isBank)
                  Chip(
                    label: Text(rate.unit),
                    visualDensity:
                        VisualDensity.compact,
                  ),
              ],
            ),
            const Divider(height: 18),
            Row(
              children: [
                Expanded(
                  child: rateValue(
                    tr('buy'),
                    rate.buy,
                    isBank ? tr('cash') : 'AFN',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: rateValue(
                    tr('sell'),
                    rate.sell,
                    isBank ? tr('cash') : 'AFN',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget rateValue(
    String label,
    double value,
    String suffix,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            value.toStringAsFixed(
              value >= 100 ? 2 : 4,
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            suffix,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget developerPage() {
    final hasPhoto = photoPath != null &&
        File(photoPath!).existsSync();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                const Text(
                  '🇦🇫',
                  style: TextStyle(fontSize: 38),
                ),
                const SizedBox(height: 14),
                CircleAvatar(
                  radius: 65,
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primaryContainer,
                  backgroundImage: hasPhoto
                      ? FileImage(File(photoPath!))
                      : null,
                  child: hasPhoto
                      ? null
                      : const Icon(
                          Icons.person,
                          size: 75,
                        ),
                ),
                const SizedBox(height: 16),
                Text(
                  tr('name'),
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(tr('developer')),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: choosePhoto,
                  icon: const Icon(
                    Icons.photo_library_outlined,
                  ),
                  label: Text(tr('changePhoto')),
                ),
                if (hasPhoto)
                  TextButton.icon(
                    onPressed: removePhoto,
                    icon: const Icon(
                      Icons.delete_outline,
                    ),
                    label: Text(tr('removePhoto')),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
