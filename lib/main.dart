import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String apiUrl =
    'https://afghani-exchange-api.abdullah-alingari.workers.dev/api/rates';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AfghaniExchangeApp());
}

const Map<String, Map<String, String>> translations = {
  'ps': {
    'markets': 'د افغانستان بازارونه',
    'world': 'نړیوال نرخونه',
    'convert': 'د اسعارو تبادله',
    'developer': 'جوړوونکی',
    'bank': 'د افغانستان بانک',
    'sarai': 'سرای شهزاده',
    'khorasan': 'خراسان مارکیټ',
    'buy': 'اخیستل',
    'sell': 'پلورل',
    'refresh': 'نرخونه تازه کړه',
    'amount': 'اندازه ولیکه',
    'from': 'له کوم اسعارو',
    'to': 'کومو اسعارو ته',
    'result': 'د تبادلې پایله',
    'photo': 'عکس بدل کړه',
    'dark': 'تور او سپین حالت',
    'language': 'ژبه',
    'updated': 'د نرخونو وروستی تازه کېدل',
    'loading': 'نرخونه لوډ کېږي...',
    'error': 'نرخونه ترلاسه نه شول',
    'noWorld': 'اوس نړیوال نرخونه نشته',
    'market': 'د تبادلې بازار',
    'selectMarket': 'بازار انتخاب کړه',
    'afn': 'افغانۍ',
    'noRate': 'د دې اسعارو نرخ نشته',
    'date': 'نېټه',
    'app': 'Afghani Exchange',
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
    'refresh': 'تازه‌سازی نرخ‌ها',
    'amount': 'مقدار را وارد کنید',
    'from': 'از کدام ارز',
    'to': 'به کدام ارز',
    'result': 'نتیجه تبدیل',
    'photo': 'تغییر عکس',
    'dark': 'حالت سیاه و سفید',
    'language': 'زبان',
    'updated': 'آخرین به‌روزرسانی نرخ‌ها',
    'loading': 'در حال دریافت نرخ‌ها...',
    'error': 'دریافت نرخ‌ها ناموفق بود',
    'noWorld': 'نرخ جهانی موجود نیست',
    'market': 'بازار تبدیل',
    'selectMarket': 'بازار را انتخاب کنید',
    'afn': 'افغانی',
    'noRate': 'نرخ این ارز موجود نیست',
    'date': 'تاریخ',
    'app': 'Afghani Exchange',
  },
  'en': {
    'markets': 'Afghanistan Markets',
    'world': 'World Rates',
    'convert': 'Currency Exchange',
    'developer': 'Developer',
    'bank': 'Da Afghanistan Bank',
    'sarai': 'Sarai Shahzada',
    'khorasan': 'Khorasan Market',
    'buy': 'Buy',
    'sell': 'Sell',
    'refresh': 'Refresh rates',
    'amount': 'Enter amount',
    'from': 'From currency',
    'to': 'To currency',
    'result': 'Conversion result',
    'photo': 'Change photo',
    'dark': 'Black and white mode',
    'language': 'Language',
    'updated': 'Rates last updated',
    'loading': 'Loading rates...',
    'error': 'Could not load rates',
    'noWorld': 'World rates are unavailable',
    'market': 'Exchange market',
    'selectMarket': 'Select market',
    'afn': 'Afghan Afghani',
    'noRate': 'Rate not available',
    'date': 'Date',
    'app': 'Afghani Exchange',
  },
};

const Map<String, Map<String, String>> currencies = {
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

String flagOf(String code) => currencies[code]?['flag'] ?? '🌐';
String nameOf(String code) => currencies[code]?['name'] ?? code;

class AfghaniExchangeApp extends StatefulWidget {
  const AfghaniExchangeApp({super.key});

  @override
  State<AfghaniExchangeApp> createState() => _AfghaniExchangeAppState();
}

class _AfghaniExchangeAppState extends State<AfghaniExchangeApp> {
  String language = 'ps';
  bool dark = false;

  @override
  Widget build(BuildContext context) {
    final background = dark ? Colors.black : const Color(0xfff4f4f4);
    final surface = dark ? const Color(0xff111111) : Colors.white;
    final foreground = dark ? Colors.white : Colors.black;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afghani Exchange 🇦🇫',
      theme: ThemeData(
        useMaterial3: true,
        brightness: dark ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: dark ? Brightness.dark : Brightness.light,
          surface: surface,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: 0,
        ),
        dividerColor: dark ? Colors.white24 : Colors.black12,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      home: HomePage(
        language: language,
        dark: dark,
        onLanguage: (value) => setState(() => language = value),
        onDark: (value) => setState(() => dark = value),
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
  int selectedTab = 0;

  String photoPath = '';
  final amountController = TextEditingController(text: '100');
  String fromCode = 'USD';
  String toCode = 'AFN';
  String selectedMarket = 'sarai';
  bool useBuyRate = true;

  String tr(String key) => translations[widget.language]?[key] ?? key;

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
    final path = prefs.getString('developer_photo') ?? '';
    if (mounted) setState(() => photoPath = path);
  }

  Future<void> changePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (image == null) return;

    final directory = await getApplicationDocumentsDirectory();
    final extension = image.path.contains('.')
        ? image.path.substring(image.path.lastIndexOf('.'))
        : '.jpg';
    final destination = '${directory.path}/developer_photo$extension';
    final saved = await File(image.path).copy(destination);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('developer_photo', saved.path);

    if (mounted) setState(() => photoPath = saved.path);
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
      final newMarkets = data['markets'] as Map<String, dynamic>? ?? {};
      final newWorld = data['world'] as List? ?? [];

      if (!mounted) return;
      setState(() {
        markets = newMarkets;
        world = newWorld;
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

  String codeFromLabel(String label) {
    final value = label.toUpperCase();
    const codes = [
      'USD', 'EUR', 'GBP', 'INR', 'PKR', 'IRR', 'CNY', 'AED',
      'SAR', 'CHF', 'AUD', 'CAD', 'RUB', 'DKK', 'SEK', 'NOK',
      'TRY', 'KWD', 'QAR', 'BHD', 'JPY'
    ];

    for (final code in codes) {
      if (value.contains(code)) return code;
    }
    if (value.contains('INDIAN')) return 'INR';
    if (value.contains('PAKISTAN')) return 'PKR';
    if (value.contains('EURO')) return 'EUR';
    if (value.contains('POUND')) return 'GBP';
    if (value.contains('SWISS')) return 'CHF';
    if (value.contains('DIRHAM')) return 'AED';
    if (value.contains('RIYAL')) return 'SAR';
    if (value.contains('TOMAN')) return 'IRR';
    return '';
  }

  // د بازارونو اصلي buy او sell ارزښتونه هماغسې ښودل کېږي.
  // د تبادلې لپاره د 1K اسعارو نرخ پر 1000 وېشل کېږي.
  Map<String, double> marketRates() {
    final result = <String, double>{'AFN': 1};
    final market = markets[selectedMarket] as Map<String, dynamic>? ?? {};
    final rows = market['rows'] as List? ?? [];

    for (final item in rows) {
      if (item is! Map) continue;
      final label = item['label']?.toString() ?? '';
      final code = codeFromLabel(label);
      if (code.isEmpty) continue;

      final raw = item[useBuyRate ? 'buy' : 'sell'];
      if (raw is! num) continue;

      double rate = raw.toDouble();
      if (label.toUpperCase().contains('1K')) {
        rate /= 1000;
      }
      if (rate > 0) result[code] = rate;
    }

    for (final item in world) {
      if (item is! Map) continue;
      final code = item['code']?.toString() ?? '';
      final raw = item['afnPerUnit'];
      if (code.isNotEmpty && raw is num && raw > 0) {
        result.putIfAbsent(code, () => raw.toDouble());
      }
    }

    return result;
  }

  double get convertedAmount {
    final amount = double.tryParse(amountController.text) ?? 0;
    final rates = marketRates();
    final from = rates[fromCode] ?? 0;
    final to = rates[toCode] ?? 0;

    if (from <= 0 || to <= 0) return 0;
    return amount * from / to;
  }

  Widget panel({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: widget.dark ? const Color(0xff111111) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.dark ? Colors.white24 : Colors.black12,
        ),
      ),
      child: child,
    );
  }

  Widget marketCard(String marketKey, String title) {
    final market = markets[marketKey] as Map<String, dynamic>? ?? {};
    final rows = market['rows'] as List? ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: widget.dark ? const Color(0xff111111) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.dark ? Colors.white24 : Colors.black12,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance, size: 22),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 25),
            if (rows.isEmpty)
              Text(market['error']?.toString() ?? tr('error'))
            else
              ...rows.map((item) {
                final row = item as Map<String, dynamic>;
                final label = row['label']?.toString() ?? '';
                final code = codeFromLabel(label);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Row(
                    children: [
                      Text(
                        flagOf(code),
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${tr('buy')}: ${row['buy']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${tr('sell')}: ${row['sell']}',
                            style: const TextStyle(color: Colors.grey),
                          ),
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

  Widget marketsPage() {
    return RefreshIndicator(
      onRefresh: fetchRates,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          marketCard('bank', tr('bank')),
          marketCard('sarai', tr('sarai')),
          marketCard('khorasan', tr('khorasan')),
          if (updatedAt != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                '${tr('updated')}: ${updatedAt!.toLocal()}',
                textAlign: TextAlign.center,
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
        if (sorted.isEmpty)
          panel(child: Text(tr('noWorld')))
        else
          ...sorted.map((item) {
            final code = item['code'].toString();
            final rate = (item['afnPerUnit'] as num).toDouble();
            return Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: panel(
                child: Row(
                  children: [
                    Text(flagOf(code),
                        style: const TextStyle(fontSize: 25)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(code,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text(nameOf(code),
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    Text(
                      rate.toStringAsFixed(4),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget converterPage() {
    final rates = marketRates();
    final codes = rates.keys.toList()..sort();

    if (!codes.contains(fromCode)) {
      fromCode = codes.contains('USD') ? 'USD' : 'AFN';
    }
    if (!codes.contains(toCode)) toCode = 'AFN';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        panel(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('market'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 9),
              DropdownButtonFormField<String>(
                value: selectedMarket,
                isExpanded: true,
                items: [
                  DropdownMenuItem(
                      value: 'bank', child: Text(tr('bank'))),
                  DropdownMenuItem(
                      value: 'sarai', child: Text(tr('sarai'))),
                  DropdownMenuItem(
                      value: 'khorasan', child: Text(tr('khorasan'))),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedMarket = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: true,
                    label: Text(tr('buy')),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text(tr('sell')),
                  ),
                ],
                selected: {useBuyRate},
                onSelectionChanged: (values) {
                  setState(() => useBuyRate = values.first);
                },
              ),
              const SizedBox(height: 20),
              Text(tr('amount'),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: '100',
                  prefixIcon: Icon(Icons.edit),
                ),
              ),
              const SizedBox(height: 18),
              Text(tr('from')),
              const SizedBox(height: 7),
              DropdownButtonFormField<String>(
                value: fromCode,
                isExpanded: true,
                items: codes.map((code) {
                  return DropdownMenuItem(
                    value: code,
                    child: Text('${flagOf(code)}  $code - ${nameOf(code)}'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => fromCode = value);
                },
              ),
              const SizedBox(height: 12),
              Center(
                child: IconButton.filledTonal(
                  onPressed: () {
                    setState(() {
                      final old = fromCode;
                      fromCode = toCode;
                      toCode = old;
                    });
                  },
                  icon: const Icon(Icons.swap_vert, size: 27),
                ),
              ),
              const SizedBox(height: 8),
              Text(tr('to')),
              const SizedBox(height: 7),
              DropdownButtonFormField<String>(
                value: toCode,
                isExpanded: true,
                items: codes.map((code) {
                  return DropdownMenuItem(
                    value: code,
                    child: Text('${flagOf(code)}  $code - ${nameOf(code)}'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => toCode = value);
                },
              ),
              const SizedBox(height: 22),
              Text(tr('result'),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 9),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: widget.dark ? Colors.white : Colors.black,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  rates[fromCode] == null || rates[toCode] == null
                      ? tr('noRate')
                      : '${convertedAmount.toStringAsFixed(4)} $toCode',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: widget.dark ? Colors.black : Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget developerPage() {
    final hasPhoto =
        photoPath.isNotEmpty && File(photoPath).existsSync();

    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        const SizedBox(height: 20),
        Center(
          child: CircleAvatar(
            radius: 65,
            backgroundColor:
                widget.dark ? Colors.white12 : Colors.black12,
            backgroundImage:
                hasPhoto ? FileImage(File(photoPath)) : null,
            child: hasPhoto
                ? null
                : const Icon(Icons.person, size: 65),
          ),
        ),
        const SizedBox(height: 17),
        const Center(
          child: Text(
            'Abdullah Eman',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            '🇦🇫 Afghanistan',
            style: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: FilledButton.icon(
            onPressed: changePhoto,
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(tr('photo')),
          ),
        ),
        const SizedBox(height: 25),
        panel(
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.language),
                  const SizedBox(width: 12),
                  Expanded(child: Text(tr('language'))),
                  DropdownButton<String>(
                    value: widget.language,
                    items: const [
                      DropdownMenuItem(
                          value: 'ps', child: Text('پښتو')),
                      DropdownMenuItem(
                          value: 'fa', child: Text('دری')),
                      DropdownMenuItem(
                          value: 'en', child: Text('English')),
                    ],
                    onChanged: (value) {
                      if (value != null) widget.onLanguage(value);
                    },
                  ),
                ],
              ),
              const Divider(),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(tr('dark')),
                secondary: const Icon(Icons.contrast),
                value: widget.dark,
                onChanged: widget.onDark,
              ),
              if (updatedAt != null) ...[
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_month),
                  title: Text(tr('date')),
                  subtitle: Text(
                    '${updatedAt!.toLocal().year}-'
                    '${updatedAt!.toLocal().month.toString().padLeft(2, '0')}-'
                    '${updatedAt!.toLocal().day.toString().padLeft(2, '0')}',
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 25),
        const Center(
          child: Text(
            'Afghani Exchange 🇦🇫',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      tr('markets'),
      tr('world'),
      tr('convert'),
      tr('developer'),
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
          titleSpacing: 16,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🇦🇫', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 7),
              Text(
                'Afghani Exchange',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: widget.dark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: tr('refresh'),
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
                    const SizedBox(height: 13),
                    Text(tr('loading')),
                  ],
                ),
              )
            : error != null && markets.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(tr('error')),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: fetchRates,
                          child: Text(tr('refresh')),
                        ),
                      ],
                    ),
                  )
                : pages[selectedTab],
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedTab,
          onDestinationSelected: (index) {
            setState(() => selectedTab = index);
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.currency_exchange),
              label: tr('markets'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.public),
              label: tr('world'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.swap_horiz),
              label: tr('convert'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              label: tr('developer'),
            ),
          ],
        ),
      ),
    );
  }
}
