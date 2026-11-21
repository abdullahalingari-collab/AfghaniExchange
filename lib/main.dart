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
};

const Map<String, Map<String, String>> names = {
  'ps': {
    'AFN': 'افغانۍ', 'USD': 'امریکایي ډالر', 'EUR': 'یورو',
    'GBP': 'برتانوي پونډ', 'PKR': 'پاکستانۍ روپۍ',
    'INR': 'هندي روپۍ', 'IRR': 'ایراني ریال', 'CNY': 'چینایي یوان',
    'TRY': 'ترکي لیره', 'AED': 'اماراتي درهم', 'SAR': 'سعودي ریال',
    'QAR': 'قطري ریال', 'KWD': 'کویتي دینار', 'CAD': 'کاناډایي ډالر',
    'AUD': 'اسټرالیایي ډالر', 'JPY': 'جاپاني ین',
  },
  'fa': {
    'AFN': 'افغانی', 'USD': 'دالر آمریکایی', 'EUR': 'یورو',
    'GBP': 'پوند انگلیس', 'PKR': 'روپیه پاکستانی',
    'INR': 'روپیه هندی', 'IRR': 'ریال ایرانی', 'CNY': 'یوان چین',
    'TRY': 'لیره ترکیه', 'AED': 'درهم امارات', 'SAR': 'ریال سعودی',
    'QAR': 'ریال قطر', 'KWD': 'دینار کویت', 'CAD': 'دالر کانادا',
    'AUD': 'دالر آسترالیا', 'JPY': 'ین جاپان',
  },
  'en': {
    'AFN': 'Afghan Afghani', 'USD': 'US Dollar', 'EUR': 'Euro',
    'GBP': 'British Pound', 'PKR': 'Pakistani Rupee',
    'INR': 'Indian Rupee', 'IRR': 'Iranian Rial', 'CNY': 'Chinese Yuan',
    'TRY': 'Turkish Lira', 'AED': 'UAE Dirham', 'SAR': 'Saudi Riyal',
    'QAR': 'Qatari Riyal', 'KWD': 'Kuwaiti Dinar',
    'CAD': 'Canadian Dollar', 'AUD': 'Australian Dollar',
    'JPY': 'Japanese Yen',
  },
};

String fmt(dynamic value) {
  final number = double.tryParse('$value');
  if (number == null || !number.isFinite) return '—';
  return number.toStringAsFixed(2);
}

String currencyName(String code, String language) {
  return names[language]?[code] ?? code;
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
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      language = prefs.getString('language') ?? 'ps';
      darkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> changeLanguage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', value);
    if (mounted) setState(() => language = value);
  }

  Future<void> changeTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff087d50)),
        scaffoldBackgroundColor: const Color(0xfff3f7f5),
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
        onLanguageChanged: changeLanguage,
        onThemeChanged: changeTheme,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String language;
  final bool darkMode;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<bool> onThemeChanged;

  const HomePage({
    super.key,
    required this.language,
    required this.darkMode,
    required this.onLanguageChanged,
    required this.onThemeChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int page = 0;
  bool loading = false;
  String error = '';
  String selectedMarket = 'sarai';
  String updatedAt = '';
  Map<String, dynamic> markets = {};
  List<dynamic> world = [];
  String? photoPath;

  final picker = ImagePicker();
  final fromController = TextEditingController(text: 'USD');
  final toController = TextEditingController(text: 'AFN');
  final amountController = TextEditingController(text: '1');

  final marketLabels = {
    'bank': {'ps': 'د افغانستان بانک', 'fa': 'بانک افغانستان', 'en': 'Afghanistan Bank'},
    'sarai': {'ps': 'سرای شهزاده', 'fa': 'سرای شهزاده', 'en': 'Sarai Shahzada'},
    'khorasan': {'ps': 'خراسان (هرات)', 'fa': 'خراسان (هرات)', 'en': 'Khorasan (Herat)'},
    'kandahar': {'ps': 'کندهار', 'fa': 'قندهار', 'en': 'Kandahar'},
    'nangarhar': {'ps': 'ننګرهار (جلال‌اباد)', 'fa': 'ننگرهار (جلال‌آباد)', 'en': 'Nangarhar (Jalalabad)'},
  };

  String get lang => widget.language;

  String tr(String ps, String fa, String en) {
    if (lang == 'fa') return fa;
    if (lang == 'en') return en;
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
    fromController.dispose();
    toController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> loadPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('developerPhoto');
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

    final directory = await getApplicationDocumentsDirectory();
    final saved = await File(image.path).copy(
      '${directory.path}/developer_photo.jpg',
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('developerPhoto', saved.path);

    if (mounted) setState(() => photoPath = saved.path);
  }

  Future<void> fetchRates() async {
    if (mounted) {
      setState(() {
        loading = true;
        error = '';
      });
    }

    try {
      final response = await http
          .get(Uri.parse(workerUrl))
          .timeout(const Duration(seconds: 25));

      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      if (data is! Map) throw Exception('Invalid server response');

      final receivedMarkets = data['markets'];
      final receivedWorld = data['world'];

      if (mounted) {
        setState(() {
          markets = receivedMarkets is Map
              ? Map<String, dynamic>.from(receivedMarkets)
              : {};
          world = receivedWorld is List ? receivedWorld : [];
          updatedAt = '${data['updatedAt'] ?? ''}';
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
          error = e.toString();
        });
      }
    }
  }

  List<dynamic> marketRows(String key) {
    final market = markets[key];
    if (market is Map && market['rows'] is List) {
      return market['rows'] as List;
    }
    return [];
  }

  double? numberOf(dynamic value) {
    if (value == null) return null;
    return double.tryParse(
      value.toString().replaceAll(',', '').replaceAll(' ', ''),
    );
  }

  List<Map<String, dynamic>> get selectedRows {
    return marketRows(selectedMarket)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  double? rateFor(String code) {
    for (final row in selectedRows) {
      final label = '${row['label'] ?? ''}'.toUpperCase();
      if (label.contains(code.toUpperCase())) {
        return numberOf(row['buy']) ??
            numberOf(row['sell']);
      }
    }

    for (final item in world) {
      if (item is Map && '${item['code']}'.toUpperCase() == code) {
        return numberOf(item['afnPerUnit']) ?? numberOf(item['rate']);
      }
    }
    return null;
  }

  double? convertedAmount() {
    final amount = numberOf(amountController.text);
    if (amount == null) return null;

    final from = fromController.text.trim().toUpperCase();
    final to = toController.text.trim().toUpperCase();

    if (from == to) return amount;

    final fromRate = rateFor(from);
    final toRate = rateFor(to);

    if (fromRate == null || toRate == null || fromRate == 0) {
      return null;
    }

    return amount * fromRate / toRate;
  }

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget marketCard(String key) {
    final label = marketLabels[key]?[lang] ?? key;
    final rows = marketRows(key);
    final market = markets[key];
    final rateType = market is Map ? '${market['rateType'] ?? ''}' : '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => selectedMarket = key),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (selectedMarket == key)
                    const Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
              const SizedBox(height: 10),
              if (rows.isEmpty)
                Text(tr(
                  'اوس مهال معلومات نشته',
                  'در حال حاضر معلومات موجود نیست',
                  'No rates available',
                ))
              else
                ...rows.whereType<Map>().take(8).map((row) {
                  final labelText = '${row['label'] ?? ''}';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            labelText,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                tr('اخیستل', 'خرید', 'Buy'),
                                style: const TextStyle(fontSize: 11),
                              ),
                              Text(
                                fmt(row['buy']),
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                tr('پلورل', 'فروش', 'Sell'),
                                style: const TextStyle(fontSize: 11),
                              ),
                              Text(
                                fmt(row['sell']),
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              if (rateType.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    rateType,
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
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
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                const Text('🇦🇫', style: TextStyle(fontSize: 35)),
                const Text(
                  'Afghani Exchange',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tr('د اسعارو تازه نرخونه', 'نرخ تازه اسعار', 'Latest currency rates'),
                  style: const TextStyle(color: Colors.white),
                ),
                if (updatedAt.isNotEmpty)
                  Text(
                    '${tr('وروستی تازه کول', 'آخرین بروزرسانی', 'Last update')}: $updatedAt',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
              ],
            ),
          ),
          if (error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                '${tr('د معلوماتو ستونزه', 'خطا در دریافت معلومات', 'Data error')}: $error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          sectionTitle(tr('د بازارونو نرخونه', 'نرخ بازارها', 'Market rates')),
          ...marketLabels.keys.map(marketCard),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(25),
              child: Center(child: CircularProgressIndicator()),
            ),
          const SizedBox(height: 20),
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
          sectionTitle(tr('د نړۍ اسعار', 'ارزهای جهان', 'World currencies')),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(tr('معلومات نشته', 'معلومات موجود نیست', 'No data available')),
            ),
          ...items.map((item) {
            final code = '${item['code'] ?? ''}'.toUpperCase();
            final rate = item['afnPerUnit'] ?? item['rate'];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: ListTile(
                leading: Text(flags[code] ?? '🌐', style: const TextStyle(fontSize: 27)),
                title: Text('$code - ${currencyName(code, lang)}'),
                trailing: Text(
                  fmt(rate),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(tr('د یوې واحدې بیه په افغانۍ', 'قیمت یک واحد به افغانی', 'Value of one unit in AFN')),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget converterPage() {
    final result = convertedAmount();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        sectionTitle(tr('د اسعارو تبدیلول', 'تبدیل اسعار', 'Currency converter')),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: tr('اندازه', 'مقدار', 'Amount'),
                    prefixIcon: const Icon(Icons.payments),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: fromController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: tr('له کوم اسعارو', 'از کدام ارز', 'From currency'),
                    prefixIcon: const Icon(Icons.currency_exchange),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: toController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: tr('کوم اسعارو ته', 'به کدام ارز', 'To currency'),
                    prefixIcon: const Icon(Icons.currency_exchange),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Text(tr('نتیجه', 'نتیجه', 'Result')),
                      const SizedBox(height: 8),
                      Text(
                        result == null
                            ? '—'
                            : '${fmt(result)} ${toController.text.toUpperCase()}',
                        style: const TextStyle(
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
                    'د تبدیل لپاره د بازار ټاکل شوی نرخ کارول کېږي.',
                    'برای تبدیل از نرخ بازار انتخاب‌شده استفاده می‌شود.',
                    'The selected market rate is used for conversion.',
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

  Widget languagePage() {
    return ListView(
      children: [
        sectionTitle(tr('ژبه وټاکئ', 'انتخاب زبان', 'Choose language')),
        RadioListTile<String>(
          value: 'ps',
          groupValue: lang,
          title: const Text('🇦🇫 پښتو'),
          onChanged: (v) {
            if (v != null) widget.onLanguageChanged(v);
          },
        ),
        RadioListTile<String>(
          value: 'fa',
          groupValue: lang,
          title: const Text('🇦🇫 دری'),
          onChanged: (v) {
            if (v != null) widget.onLanguageChanged(v);
          },
        ),
        RadioListTile<String>(
          value: 'en',
          groupValue: lang,
          title: const Text('🇬🇧 English'),
          onChanged: (v) {
            if (v != null) widget.onLanguageChanged(v);
          },
        ),
        const Divider(),
        SwitchListTile(
          secondary: const Icon(Icons.dark_mode),
          title: Text(tr('تیاره بڼه', 'حالت تاریک', 'Dark mode')),
          value: widget.darkMode,
          onChanged: widget.onThemeChanged,
        ),
      ],
    );
  }

  Widget developerPage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 20),
        Center(
          child: GestureDetector(
            onTap: changePhoto,
            child: CircleAvatar(
              radius: 65,
              backgroundColor: Colors.green,
              backgroundImage: photoPath != null ? FileImage(File(photoPath!)) : null,
              child: photoPath == null
                  ? const Icon(Icons.person, size: 65, color: Colors.white)
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton.icon(
            onPressed: changePhoto,
            icon: const Icon(Icons.photo_camera),
            label: Text(tr('عکس بدل کړئ', 'تغییر عکس', 'Change photo')),
          ),
        ),
        const SizedBox(height: 15),
        Center(
          child: Text(
            'Abdullah Eman',
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            tr('د اپلیکیشن جوړوونکی', 'سازنده اپلیکیشن', 'App Developer'),
          ),
        ),
        const SizedBox(height: 25),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.currency_exchange, color: Colors.green),
          title: const Text('Afghani Exchange'),
          subtitle: Text(tr('د اسعارو اپلیکیشن', 'اپلیکیشن اسعار', 'Currency exchange app')),
        ),
        ListTile(
          leading: const Icon(Icons.flag, color: Colors.green),
          title: Text(tr('افغانستان', 'افغانستان', 'Afghanistan')),
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
      languagePage(),
      developerPage(),
    ];

    final titles = [
      tr('بازارونه', 'بازارها', 'Markets'),
      tr('د نړۍ اسعار', 'ارزهای جهان', 'World'),
      tr('تبدیل', 'تبدیل', 'Converter'),
      tr('ژبه او بڼه', 'زبان و حالت', 'Language'),
      tr('جوړوونکی', 'سازنده', 'Developer'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🇦🇫 Afghani Exchange',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: fetchRates,
            icon: const Icon(Icons.refresh),
            tooltip: tr('تازه کول', 'بروزرسانی', 'Refresh'),
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
          NavigationDestination(icon: const Icon(Icons.store), label: tr('بازار', 'بازار', 'Markets')),
          NavigationDestination(icon: const Icon(Icons.public), label: tr('نړۍ', 'جهان', 'World')),
          NavigationDestination(icon: const Icon(Icons.calculate), label: tr('تبدیل', 'تبدیل', 'Convert')),
          NavigationDestination(icon: const Icon(Icons.language), label: tr('ژبه', 'زبان', 'Language')),
          NavigationDestination(icon: const Icon(Icons.person), label: tr('جوړوونکی', 'سازنده', 'Developer')),
        ],
      ),
    );
  }
}
