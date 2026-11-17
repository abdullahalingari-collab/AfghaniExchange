import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const apiUrl =
    'https://afghani-exchange-api.abdullah-alingari.workers.dev/api/rates';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AfghanAsaarApp());
}

const Map<String, Map<String, String>> words = {
  'ps': {
    'markets': 'افغان بازارونه',
    'world': 'نړیوال نرخونه',
    'convert': 'د اسعارو بدلون',
    'developer': 'جوړوونکی',
    'bank': 'د افغانستان بانک',
    'sarai': 'سرای شهزاده',
    'khorasan': 'خراسان مارکیټ',
    'buy': 'اخیستل',
    'sell': 'پلورل',
    'refresh': 'تازه کول',
    'amount': 'اندازه',
    'from': 'له کوم اسعارو',
    'to': 'کومو اسعارو ته',
    'result': 'پایله',
    'choosePhoto': 'عکس بدلول',
    'dark': 'تیاره بڼه',
    'language': 'ژبه',
    'updated': 'وروستی تازه کېدل',
    'loading': 'نرخونه لوډ کېږي...',
    'error': 'نرخونه ترلاسه نه شول',
    'noWorld': 'نړیوال نرخونه اوس نشته',
    'afn': 'افغانۍ',
    'rateInfo': 'نړیوال نرخونه د معلوماتو لپاره دي',
  },
  'fa': {
    'markets': 'بازارهای افغانستان',
    'world': 'نرخ‌های جهانی',
    'convert': 'تبدیل ارز',
    'developer': 'سازنده',
    'bank': 'بانک افغانستان',
    'sarai': 'سرای شهزاده',
    'khorasan': 'بازار خراسان',
    'buy': 'خرید',
    'sell': 'فروش',
    'refresh': 'تازه‌سازی',
    'amount': 'مقدار',
    'from': 'از ارز',
    'to': 'به ارز',
    'result': 'نتیجه',
    'choosePhoto': 'تغییر عکس',
    'dark': 'حالت تاریک',
    'language': 'زبان',
    'updated': 'آخرین به‌روزرسانی',
    'loading': 'در حال دریافت نرخ‌ها...',
    'error': 'دریافت نرخ‌ها ناموفق بود',
    'noWorld': 'نرخ جهانی موجود نیست',
    'afn': 'افغانی',
    'rateInfo': 'نرخ‌های جهانی برای معلومات هستند',
  },
  'en': {
    'markets': 'Afghanistan Markets',
    'world': 'World Rates',
    'convert': 'Currency Converter',
    'developer': 'Developer',
    'bank': 'Da Afghanistan Bank',
    'sarai': 'Sarai Shahzada',
    'khorasan': 'Khorasan Market',
    'buy': 'Buy',
    'sell': 'Sell',
    'refresh': 'Refresh',
    'amount': 'Amount',
    'from': 'From currency',
    'to': 'To currency',
    'result': 'Result',
    'choosePhoto': 'Change photo',
    'dark': 'Dark mode',
    'language': 'Language',
    'updated': 'Last updated',
    'loading': 'Loading rates...',
    'error': 'Could not load rates',
    'noWorld': 'World rates are unavailable',
    'afn': 'Afghan Afghani',
    'rateInfo': 'World rates are for information',
  },
};

const currencyInfo = <String, Map<String, String>>{
  'AFN': {'flag': '🇦🇫', 'name': 'Afghan Afghani'},
  'USD': {'flag': '🇺🇸', 'name': 'US Dollar'},
  'EUR': {'flag': '🇪🇺', 'name': 'Euro'},
  'GBP': {'flag': '🇬🇧', 'name': 'British Pound'},
  'INR': {'flag': '🇮🇳', 'name': 'Indian Rupee'},
  'PKR': {'flag': '🇵🇰', 'name': 'Pakistani Rupee'},
  'IRR': {'flag': '🇮🇷', 'name': 'Iranian Rial'},
  'CNY': {'flag': '🇨🇳', 'name': 'Chinese Yuan'},
  'AED': {'flag': '🇦🇪', 'name': 'UAE Dirham'},
  'SAR': {'flag': '🇸🇦', 'name': 'Saudi Riyal'},
  'CHF': {'flag': '🇨🇭', 'name': 'Swiss Franc'},
  'AUD': {'flag': '🇦🇺', 'name': 'Australian Dollar'},
  'CAD': {'flag': '🇨🇦', 'name': 'Canadian Dollar'},
  'RUB': {'flag': '🇷🇺', 'name': 'Russian Ruble'},
  'DKK': {'flag': '🇩🇰', 'name': 'Danish Krone'},
  'SEK': {'flag': '🇸🇪', 'name': 'Swedish Krona'},
  'NOK': {'flag': '🇳🇴', 'name': 'Norwegian Krone'},
  'TRY': {'flag': '🇹🇷', 'name': 'Turkish Lira'},
  'KWD': {'flag': '🇰🇼', 'name': 'Kuwaiti Dinar'},
  'QAR': {'flag': '🇶🇦', 'name': 'Qatari Riyal'},
  'BHD': {'flag': '🇧🇭', 'name': 'Bahraini Dinar'},
  'JPY': {'flag': '🇯🇵', 'name': 'Japanese Yen'},
  'NZD': {'flag': '🇳🇿', 'name': 'New Zealand Dollar'},
  'SGD': {'flag': '🇸🇬', 'name': 'Singapore Dollar'},
  'ZAR': {'flag': '🇿🇦', 'name': 'South African Rand'},
  'BRL': {'flag': '🇧🇷', 'name': 'Brazilian Real'},
  'KRW': {'flag': '🇰🇷', 'name': 'South Korean Won'},
  'THB': {'flag': '🇹🇭', 'name': 'Thai Baht'},
  'MYR': {'flag': '🇲🇾', 'name': 'Malaysian Ringgit'},
  'IDR': {'flag': '🇮🇩', 'name': 'Indonesian Rupiah'},
  'BDT': {'flag': '🇧🇩', 'name': 'Bangladeshi Taka'},
  'NPR': {'flag': '🇳🇵', 'name': 'Nepalese Rupee'},
  'EGP': {'flag': '🇪🇬', 'name': 'Egyptian Pound'},
  'IQD': {'flag': '🇮🇶', 'name': 'Iraqi Dinar'},
  'OMR': {'flag': '🇴🇲', 'name': 'Omani Rial'},
  'JOD': {'flag': '🇯🇴', 'name': 'Jordanian Dinar'},
  'KES': {'flag': '🇰🇪', 'name': 'Kenyan Shilling'},
  'NGN': {'flag': '🇳🇬', 'name': 'Nigerian Naira'},
  'MXN': {'flag': '🇲🇽', 'name': 'Mexican Peso'},
};

String flagFor(String code) => currencyInfo[code]?['flag'] ?? '🌐';
String nameFor(String code) => currencyInfo[code]?['name'] ?? code;

class AfghanAsaarApp extends StatefulWidget {
  const AfghanAsaarApp({super.key});

  @override
  State<AfghanAsaarApp> createState() => _AfghanAsaarAppState();
}

class _AfghanAsaarAppState extends State<AfghanAsaarApp> {
  String language = 'ps';
  bool dark = false;

  @override
  Widget build(BuildContext context) {
    final black = dark;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'افغان اسعار 🇦🇫',
      theme: ThemeData(
        useMaterial3: true,
        brightness: black ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: black ? Colors.black : const Color(0xfff5f6f8),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: black ? Brightness.dark : Brightness.light,
          surface: black ? const Color(0xff101010) : Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: black ? Colors.black : Colors.white,
          foregroundColor: black ? Colors.white : Colors.black,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: black ? const Color(0xff101010) : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: black ? Colors.white24 : Colors.black12,
            ),
          ),
        ),
      ),
      home: HomePage(
        language: language,
        dark: dark,
        onLanguage: (v) => setState(() => language = v),
        onDark: (v) => setState(() => dark = v),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String language;
  final bool dark;
  final ValueChanged<String> onLanguage;
  final ValueChanged<bool> onDark;

  const HomePage({
    super.key,
    required this.language,
    required this.dark,
    required this.onLanguage,
    required this.onDark,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic> markets = {};
  List<dynamic> world = [];
  bool loading = true;
  String? error;
  DateTime? updatedAt;
  int tab = 0;
  String photoPath = '';
  final amountController = TextEditingController(text: '100');
  String fromCode = 'USD';
  String toCode = 'AFN';

  String t(String key) => words[widget.language]?[key] ?? key;

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
    final saved = prefs.getString('developer_photo') ?? '';
    if (mounted) setState(() => photoPath = saved);
  }

  Future<void> choosePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return;

    final directory = await getApplicationDocumentsDirectory();
    final extension = image.path.contains('.')
        ? image.path.substring(image.path.lastIndexOf('.'))
        : '.jpg';
    final savedFile = await File(image.path).copy(
      '${directory.path}/developer_photo$extension',
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('developer_photo', savedFile.path);
    if (mounted) setState(() => photoPath = savedFile.path);
  }

  Future<void> fetchRates() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 25));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final marketData = data['markets'] as Map<String, dynamic>? ?? {};

      if (!mounted) return;
      setState(() {
        markets = marketData;
        world = (data['world'] as List?) ?? [];
        updatedAt = DateTime.tryParse(data['updatedAt']?.toString() ?? '');
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

  double rateOf(String code) {
    if (code == 'AFN') return 1;
    for (final item in world) {
      if (item is Map && item['code'] == code) {
        return (item['afnPerUnit'] as num).toDouble();
      }
    }
    return 0;
  }

  double get convertedAmount {
    final amount = double.tryParse(amountController.text) ?? 0;
    final fromRate = rateOf(fromCode);
    final toRate = rateOf(toCode);
    if (fromRate <= 0 || toRate <= 0) return 0;
    return amount * fromRate / toRate;
  }

  Widget marketCard(String key, String title) {
    final market = markets[key] as Map<String, dynamic>? ?? {};
    final rows = (market['rows'] as List?) ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold)),
            const Divider(height: 22),
            if (rows.isEmpty)
              Text(market['error']?.toString() ?? t('error'))
            else
              ...rows.map((item) {
                final row = item as Map<String, dynamic>;
                final label = row['label']?.toString() ?? '';
                final code = currencyCode(label);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Row(
                    children: [
                      Text(flagFor(code),
                          style: const TextStyle(fontSize: 23)),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(label,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${t('buy')}: ${row['buy']}'),
                          const SizedBox(height: 4),
                          Text('${t('sell')}: ${row['sell']}'),
                        ],
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

  String currencyCode(String label) {
    final upper = label.toUpperCase();
    const codes = [
      'USD', 'EUR', 'GBP', 'INR', 'PKR', 'IRR', 'CNY', 'AED',
      'SAR', 'CHF', 'AUD', 'CAD', 'RUB', 'DKK', 'SEK', 'NOK',
      'TRY', 'KWD', 'QAR', 'BHD', 'JPY'
    ];
    for (final code in codes) {
      if (upper.contains(code)) return code;
    }
    if (upper.contains('INDIAN')) return 'INR';
    if (upper.contains('PAKISTAN')) return 'PKR';
    if (upper.contains('EURO')) return 'EUR';
    if (upper.contains('POUND')) return 'GBP';
    if (upper.contains('SWISS')) return 'CHF';
    if (upper.contains('DIRHAM')) return 'AED';
    if (upper.contains('RIYAL')) return 'SAR';
    if (upper.contains('TOMAN')) return 'IRR';
    return 'AFN';
  }

  Widget marketsPage() {
    return RefreshIndicator(
      onRefresh: fetchRates,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          marketCard('bank', t('bank')),
          marketCard('sarai', t('sarai')),
          marketCard('khorasan', t('khorasan')),
          if (updatedAt != null)
            Center(
              child: Text(
                '${t('updated')}: ${updatedAt!.toLocal()}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  Widget worldPage() {
    final sorted = [...world]
      ..sort((a, b) => a['code'].toString().compareTo(b['code'].toString()));

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Text(t('rateInfo'),
                style: const TextStyle(color: Colors.grey)),
          ),
        ),
        if (sorted.isEmpty)
          Padding(
            padding: const EdgeInsets.all(25),
            child: Center(child: Text(t('noWorld'))),
          ),
        ...sorted.map((item) {
          final code = item['code'].toString();
          final rate = (item['afnPerUnit'] as num).toDouble();
          return Card(
            child: ListTile(
              leading: Text(flagFor(code),
                  style: const TextStyle(fontSize: 27)),
              title: Text('$code - ${nameFor(code)}'),
              trailing: Text(
                rate.toStringAsFixed(4),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        }),
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text('Rates By ExchangeRate-API',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey)),
        ),
      ],
    );
  }

  Widget converterPage() {
    final codes = <String>{
      'AFN',
      ...world.map((e) => e['code'].toString()),
    }.toList()
      ..sort();

    if (!codes.contains(fromCode)) fromCode = 'USD';
    if (!codes.contains(toCode)) toCode = 'AFN';

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t('amount'),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '100',
                  ),
                ),
                const SizedBox(height: 18),
                Text(t('from')),
                const SizedBox(height: 7),
                DropdownButtonFormField<String>(
                  value: fromCode,
                  isExpanded: true,
                  items: codes.map((code) {
                    return DropdownMenuItem(
                      value: code,
                      child: Text('${flagFor(code)}  $code - ${nameFor(code)}'),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => fromCode = value ?? fromCode),
                ),
                const SizedBox(height: 15),
                Center(
                  child: IconButton.filledTonal(
                    onPressed: () {
                      setState(() {
                        final old = fromCode;
                        fromCode = toCode;
                        toCode = old;
                      });
                    },
                    icon: const Icon(Icons.swap_vert),
                  ),
                ),
                const SizedBox(height: 10),
                Text(t('to')),
                const SizedBox(height: 7),
                DropdownButtonFormField<String>(
                  value: toCode,
                  isExpanded: true,
                  items: codes.map((code) {
                    return DropdownMenuItem(
                      value: code,
                      child: Text('${flagFor(code)}  $code - ${nameFor(code)}'),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => toCode = value ?? toCode),
                ),
                const SizedBox(height: 25),
                Text(t('result'),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: widget.dark
                        ? Colors.white10
                        : Colors.blueGrey.withOpacity(.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '${convertedAmount.toStringAsFixed(4)} $toCode',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget developerPage() {
    final hasPhoto = photoPath.isNotEmpty && File(photoPath).existsSync();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius:  sixty,
            backgroundColor: Colors.white12,
            backgroundImage:
                hasPhoto ? FileImage(File(photoPath)) : null,
            child: hasPhoto
                ? null
                : const Icon(Icons.person, size: 65),
          ),
          const SizedBox(height: 18),
          const Text(
            'Abdullah Eman',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: choosePhoto,
            icon: const Icon(Icons.photo_library),
            label: Text(t('choosePhoto')),
          ),
          const SizedBox(height: 25),
          DropdownButton<String>(
            value: widget.language,
            items: const [
              DropdownMenuItem(value: 'ps', child: Text('پښتو')),
              DropdownMenuItem(value: 'fa', child: Text('دری')),
              DropdownMenuItem(value: 'en', child: Text('English')),
            ],
            onChanged: (v) {
              if (v != null) widget.onLanguage(v);
            },
          ),
          SwitchListTile(
            title: Text(t('dark')),
            value: widget.dark,
            onChanged: widget.onDark,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      t('markets'),
      t('world'),
      t('convert'),
      t('developer'),
    ];

    final pages = [
      marketsPage(),
      worldPage(),
      converterPage(),
      developerPage(),
    ];

    return Directionality(
      textDirection:
          widget.language == 'en' ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'افغان اسعار 🇦🇫',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              tooltip: t('refresh'),
              onPressed: fetchRates,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: loading
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(t('loading')),
                  ],
                ),
              )
            : error != null && markets.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(t('error')),
                        const SizedBox(height: 10),
                        FilledButton(
                          onPressed: fetchRates,
                          child: Text(t('refresh')),
                        ),
                      ],
                    ),
                  )
                : pages[tab],
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (index) => setState(() => tab = index),
          destinations: [
            NavigationDestination(
                icon: const Icon(Icons.currency_exchange),
                label: t('markets')),
            NavigationDestination(
                icon: const Icon(Icons.public), label: t('world')),
            NavigationDestination(
                icon: const Icon(Icons.calculate), label: t('convert')),
            NavigationDestination(
                icon: const Icon(Icons.person), label: t('developer')),
          ],
        ),
      ),
    );
  }
}

const double sixty = 60;
