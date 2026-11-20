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
  'AED': '🇦🇪', 'SAR': '🇸🇦', 'TRY': '🇹🇷', 'JPY': '🇯🇵',
  'AUD': '🇦🇺', 'CAD': '🇨🇦', 'CHF': '🇨🇭', 'RUB': '🇷🇺',
  'QAR': '🇶🇦', 'KWD': '🇰🇼', 'BHD': '🇧🇭', 'OMR': '🇴🇲',
  'SEK': '🇸🇪', 'NOK': '🇳🇴', 'DKK': '🇩🇰', 'NZD': '🇳🇿',
  'SGD': '🇸🇬', 'MYR': '🇲🇾', 'THB': '🇹🇭', 'IDR': '🇮🇩',
  'BDT': '🇧🇩', 'LKR': '🇱🇰', 'NPR': '🇳🇵', 'EGP': '🇪🇬',
  'ZAR': '🇿🇦', 'BRL': '🇧🇷', 'MXN': '🇲🇽', 'KRW': '🇰🇷',
  'HKD': '🇭🇰', 'TWD': '🇹🇼', 'PLN': '🇵🇱', 'CZK': '🇨🇿',
  'HUF': '🇭🇺', 'RON': '🇷🇴', 'BGN': '🇧🇬', 'UAH': '🇺🇦',
  'ILS': '🇮🇱', 'JOD': '🇯🇴', 'IQD': '🇮🇶', 'KZT': '🇰🇿',
  'UZS': '🇺🇿', 'GEL': '🇬🇪', 'AMD': '🇦🇲', 'AZN': '🇦🇿',
  'XDR': '🌐', 'XAU': '🥇', 'XAG': '🥈',
};

const Map<String, List<String>> names = {
  'AFN': ['افغانۍ', 'افغانی', 'Afghan Afghani'],
  'USD': ['امریکایي ډالر', 'دالر آمریکا', 'US Dollar'],
  'EUR': ['یورو', 'یورو', 'Euro'],
  'GBP': ['برتانوي پونډ', 'پوند بریتانیا', 'British Pound'],
  'PKR': ['پاکستانۍ کلدارې', 'روپیه پاکستان', 'Pakistani Rupee'],
  'INR': ['هندي روپۍ', 'روپیه هند', 'Indian Rupee'],
  'IRR': ['ایراني ریال', 'ریال ایران', 'Iranian Rial'],
  'CNY': ['چینایي یوان', 'یوان چین', 'Chinese Yuan'],
  'AED': ['اماراتي درهم', 'درهم امارات', 'UAE Dirham'],
  'SAR': ['سعودي ریال', 'ریال سعودی', 'Saudi Riyal'],
  'TRY': ['ترکي لیره', 'لیره ترکیه', 'Turkish Lira'],
  'JPY': ['جاپاني ین', 'ین جاپان', 'Japanese Yen'],
  'AUD': ['اسټرالیايي ډالر', 'دالر استرالیا', 'Australian Dollar'],
  'CAD': ['کاناډايي ډالر', 'دالر کانادا', 'Canadian Dollar'],
  'CHF': ['سویسي فرانک', 'فرانک سوئیس', 'Swiss Franc'],
  'RUB': ['روسي روبل', 'روبل روسیه', 'Russian Ruble'],
  'QAR': ['قطري ریال', 'ریال قطر', 'Qatari Riyal'],
  'KWD': ['کویتي دینار', 'دینار کویت', 'Kuwaiti Dinar'],
  'BHD': ['بحریني دینار', 'دینار بحرین', 'Bahraini Dinar'],
  'OMR': ['عماني ریال', 'ریال عمان', 'Omani Rial'],
  'SEK': ['سویډني کرونا', 'کرون سوئد', 'Swedish Krona'],
  'NOK': ['نارویژي کرونا', 'کرون ناروی', 'Norwegian Krone'],
  'DKK': ['ډنمارکي کرونا', 'کرون دنمارک', 'Danish Krone'],
  'NZD': ['نیوزیلنډي ډالر', 'دالر نیوزیلند', 'New Zealand Dollar'],
  'SGD': ['سنګاپوري ډالر', 'دالر سنگاپور', 'Singapore Dollar'],
  'MYR': ['مالیزیايي رینګټ', 'رینگیت مالیزیا', 'Malaysian Ringgit'],
  'THB': ['تایلنډي بات', 'بات تایلند', 'Thai Baht'],
  'IDR': ['اندونیزیايي روپیه', 'روپیه اندونیزیا', 'Indonesian Rupiah'],
  'BDT': ['بنګله دېشي ټاکه', 'تاکا بنگله‌دیش', 'Bangladeshi Taka'],
  'LKR': ['سریلانکايي روپۍ', 'روپیه سریلانکا', 'Sri Lankan Rupee'],
  'NPR': ['نیپالي روپۍ', 'روپیه نیپال', 'Nepalese Rupee'],
  'EGP': ['مصري پونډ', 'پوند مصر', 'Egyptian Pound'],
  'ZAR': ['سویلي افریقايي رنډ', 'رند افریقای جنوبی', 'South African Rand'],
  'BRL': ['برازیلي ریال', 'رئال برازیل', 'Brazilian Real'],
  'MXN': ['مکسیکويي پیسو', 'پزو مکزیک', 'Mexican Peso'],
  'KRW': ['کوریایي وان', 'وون کوریای جنوبی', 'South Korean Won'],
  'HKD': ['هانګ کانګي ډالر', 'دالر هنگ‌کنگ', 'Hong Kong Dollar'],
  'TWD': ['تایواني ډالر', 'دالر تایوان', 'Taiwan Dollar'],
  'PLN': ['پولنډي زلوتي', 'زلوتی پولند', 'Polish Zloty'],
  'CZK': ['چېکي کرونا', 'کرون چک', 'Czech Koruna'],
  'HUF': ['هنګري فورنټ', 'فورینت مجارستان', 'Hungarian Forint'],
  'RON': ['رومانیایي لیو', 'لئو رومانی', 'Romanian Leu'],
  'BGN': ['بلغاري لیف', 'لف بلغارستان', 'Bulgarian Lev'],
  'UAH': ['اوکرایني هریونیا', 'گریونا اوکراین', 'Ukrainian Hryvnia'],
  'ILS': ['اسرائیلي شېکل', 'شیکل اسرائیل', 'Israeli Shekel'],
  'JOD': ['اردني دینار', 'دینار اردن', 'Jordanian Dinar'],
  'IQD': ['عراقي دینار', 'دینار عراق', 'Iraqi Dinar'],
  'KZT': ['قزاقستاني ټینګ', 'تنگه قزاقستان', 'Kazakhstani Tenge'],
  'UZS': ['ازبکستاني سوم', 'سوم ازبکستان', 'Uzbekistani Som'],
  'GEL': ['ګرجستاني لاري', 'لاری گرجستان', 'Georgian Lari'],
  'AMD': ['ارمني ډرام', 'درام ارمنستان', 'Armenian Dram'],
  'AZN': ['اذربایجاني منات', 'منات آذربایجان', 'Azerbaijani Manat'],
};

String currencyName(String code, String language) {
  final item = names[code];
  if (item == null) return code;
  final index = language == 'ps' ? 0 : language == 'fa' ? 1 : 2;
  return item[index];
}

String formatted(num value, {int digits = 2}) {
  final fixed = value.toStringAsFixed(digits);
  final parts = fixed.split('.');
  final whole = parts[0];
  final buffer = StringBuffer();
  for (int i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(whole[i]);
  }
  return parts.length > 1 ? '${buffer.toString()}.${parts[1]}' : buffer.toString();
}

class AfghaniExchangeApp extends StatefulWidget {
  const AfghaniExchangeApp({super.key});

  @override
  State<AfghaniExchangeApp> createState() => _AfghaniExchangeAppState();
}

class _AfghaniExchangeAppState extends State<AfghaniExchangeApp> {
  bool darkMode = false;
  String language = 'ps';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afghani Exchange Pro',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xff087b45),
        brightness: darkMode ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor:
            darkMode ? const Color(0xff101713) : const Color(0xfff5f8f6),
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      home: ExchangeHome(
        language: language,
        darkMode: darkMode,
        onLanguageChanged: (v) => setState(() => language = v),
        onThemeChanged: (v) => setState(() => darkMode = v),
      ),
    );
  }
}

class ExchangeHome extends StatefulWidget {
  final String language;
  final bool darkMode;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<bool> onThemeChanged;

  const ExchangeHome({
    super.key,
    required this.language,
    required this.darkMode,
    required this.onLanguageChanged,
    required this.onThemeChanged,
  });

  @override
  State<ExchangeHome> createState() => _ExchangeHomeState();
}

class _ExchangeHomeState extends State<ExchangeHome> {
  int page = 0;
  bool loading = true;
  String error = '';
  String market = 'sarai';
  String marketMode = 'average';
  Map<String, dynamic> markets = {};
  List<dynamic> world = [];
  String checkedAt = '';
  String worldUpdatedAt = '';
  bool worldStale = false;
  String developerPhoto = '';
  final picker = ImagePicker();
  final amountController = TextEditingController(text: '1');
  String fromCode = 'USD';
  String toCode = 'AFN';

  String tr(String ps, String fa, String en) {
    if (widget.language == 'fa') return fa;
    if (widget.language == 'en') return en;
    return ps;
  }

  @override
  void initState() {
    super.initState();
    loadSaved();
    fetchRates();
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<void> loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      developerPhoto = prefs.getString('developerPhoto') ?? '';
      final savedMarkets = prefs.getString('savedMarkets');
      final savedWorld = prefs.getString('savedWorld');
      if (savedMarkets != null) {
        markets = Map<String, dynamic>.from(jsonDecode(savedMarkets));
      }
      if (savedWorld != null) {
        world = List<dynamic>.from(jsonDecode(savedWorld));
      }
    });
  }

  Future<void> fetchRates() async {
    if (mounted) setState(() {
      loading = true;
      error = '';
    });

    try {
      final response = await http.get(Uri.parse(workerUrl))
          .timeout(const Duration(seconds: 25));
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['success'] != true) {
        throw Exception('API returned an unsuccessful response');
      }

      final newMarkets = Map<String, dynamic>.from(data['markets'] ?? {});
      final newWorld = List<dynamic>.from(data['world'] ?? []);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('savedMarkets', jsonEncode(newMarkets));
      await prefs.setString('savedWorld', jsonEncode(newWorld));

      if (!mounted) return;
      setState(() {
        markets = newMarkets;
        world = newWorld;
        checkedAt = data['checkedAt']?.toString() ?? '';
        worldUpdatedAt = data['worldUpdatedAt']?.toString() ?? '';
        worldStale = data['worldIsStale'] == true;
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

  Map<String, dynamic> get selectedMarket {
    return Map<String, dynamic>.from(markets[market] ?? {});
  }

  List<dynamic> get marketRows {
    return List<dynamic>.from(selectedMarket['rows'] ?? []);
  }

  double? worldRate(String code) {
    for (final item in world) {
      if (item is Map && item['code'] == code) {
        final rate = item['afnPerUnit'];
        if (rate is num && rate > 0) return rate.toDouble();
      }
    }
    return null;
  }

  double? marketRate(String code) {
    for (final item in marketRows) {
      if (item is Map) {
        final label = item['label']?.toString() ?? '';
        if (label.startsWith('$code/') || label.startsWith('$code ')) {
          final buy = (item['buy'] as num?)?.toDouble();
          final unit = (item['unit'] as num?)?.toDouble() ?? 1;
          if (buy != null && unit > 0) return buy / unit;
        }
      }
    }
    return null;
  }

  double? rateFor(String code) {
    if (code == 'AFN') return 1;
    return worldRate(code) ?? marketRate(code);
  }

  String get conversionResult {
    final amount = double.tryParse(amountController.text.replaceAll(',', ''));
    if (amount == null) return '—';
    final fromRate = rateFor(fromCode);
    final toRate = rateFor(toCode);
    if (fromRate == null || toRate == null || toRate == 0) return '—';
    return formatted(amount * fromRate / toRate, digits: 4);
  }

  String dateText(String value) {
    if (value.isEmpty) return tr('معلومات نشته', 'معلومات موجود نیست', 'Not available');
    final date = DateTime.tryParse(value)?.toLocal();
    if (date == null) return value;
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}  '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
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

    if (mounted) setState(() => developerPhoto = saved.path);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      marketPage(),
      worldPage(),
      convertPage(),
      languagePage(),
      settingsPage(),
      developerPage(),
      aboutPage(),
    ];

    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.storefront_outlined),
        label: tr('بازار', 'بازار', 'Markets'),
      ),
      NavigationDestination(
        icon: const Icon(Icons.public),
        label: tr('نړۍ', 'جهان', 'World'),
      ),
      NavigationDestination(
        icon: const Icon(Icons.currency_exchange),
        label: tr('بدلون', 'تبدیل', 'Convert'),
      ),
      NavigationDestination(
        icon: const Icon(Icons.language),
        label: tr('ژبې', 'زبان‌ها', 'Languages'),
      ),
      NavigationDestination(
        icon: const Icon(Icons.settings_outlined),
        label: tr('تنظیمات', 'تنظیمات', 'Settings'),
      ),
      NavigationDestination(
        icon: const Icon(Icons.person_outline),
        label: tr('جوړوونکی', 'سازنده', 'Developer'),
      ),
      NavigationDestination(
        icon: const Icon(Icons.info_outline),
        label: tr('په اړه', 'درباره', 'About'),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Afghani Exchange Pro',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: fetchRates,
            icon: const Icon(Icons.refresh),
            tooltip: tr('نرخونه تازه کړه', 'به‌روزرسانی نرخ‌ها', 'Refresh rates'),
          ),
        ],
      ),
      body: IndexedStack(index: page, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: page,
        onDestinationSelected: (v) => setState(() => page = v),
        destinations: destinations,
      ),
    );
  }

  Widget marketPage() {
    final marketNames = {
      'bank': tr('د افغانستان بانک', 'بانک افغانستان', 'Da Afghanistan Bank'),
      'sarai': tr('سرای شهزاده', 'سرای شهزاده', 'Sarai Shahzada'),
      'khorasan': tr('خراسان – هرات', 'خراسان – هرات', 'Khorasan – Herat'),
      'kandahar': tr('کندهار', 'قندهار', 'Kandahar'),
      'nangarhar': tr('ننګرهار', 'ننگرهار', 'Nangarhar'),
    };

    final current = selectedMarket;
    final marketError = current['error']?.toString() ?? '';
    final isEmpty = marketRows.isEmpty;

    return RefreshIndicator(
      onRefresh: fetchRates,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          headerCard(
            tr('د افغانۍ د بازار نرخونه', 'نرخ بازار افغانی', 'Afghan Market Rates'),
            tr('د بېلابېلو بازارونو د اسعارو نرخونه',
                'نرخ ارز در بازارهای مختلف', 'Exchange rates from Afghan markets'),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: market,
            decoration: InputDecoration(
              labelText: tr('بازار وټاکئ', 'انتخاب بازار', 'Select market'),
              border: const OutlineInputBorder(),
            ),
            items: marketNames.entries.map((e) {
              return DropdownMenuItem(value: e.key, child: Text(e.value));
            }).toList(),
            onChanged: (v) {
              if (v != null) setState(() => market = v);
            },
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(marketNames[market]!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  const SizedBox(height: 6),
                  Text(
                    tr('د بازار د معلوماتو وخت: ', 'زمان اطلاعات بازار: ', 'Market data time: ') +
                        dateText(current['checkedAt']?.toString() ?? ''),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  if (market == 'bank' && marketError.isNotEmpty)
                    warningText(tr(
                      'د افغانستان بانک سرچینه اوس ځواب نه ورکوي. نرخونه نه دي اټکل شوي.',
                      'منبع بانک افغانستان فعلاً پاسخ نمی‌دهد. نرخ تخمینی نمایش داده نمی‌شود.',
                      'Da Afghanistan Bank source is currently unavailable. No estimated rates are shown.',
                    )),
                  if (market == 'nangarhar' && isEmpty)
                    warningText(tr(
                      'د ننګرهار لپاره تایید شوی د نرخ جدول نشته.',
                      'برای ننگرهار جدول نرخ تأییدشده موجود نیست.',
                      'No verified rate table is currently available for Nangarhar.',
                    )),
                  if (marketError.isNotEmpty && market != 'bank' && market != 'nangarhar')
                    warningText(marketError),
                  if (isEmpty && marketError.isEmpty)
                    Text(tr('اوس مهال نرخونه نشته.', 'در حال حاضر نرخی موجود نیست.', 'No rates available right now.')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (!isEmpty) ...[
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'buy', label: Text(tr('اخیستل', 'خرید', 'Buy'))),
                ButtonSegment(value: 'sell', label: Text(tr('پلورل', 'فروش', 'Sell'))),
                ButtonSegment(value: 'average', label: Text(tr('منځنی', 'میانگین', 'Average'))),
              ],
              selected: {marketMode},
              onSelectionChanged: (v) => setState(() => marketMode = v.first),
            ),
            const SizedBox(height: 12),
            ...marketRows.map((row) {
              final item = Map<String, dynamic>.from(row);
              final label = item['label']?.toString() ?? '';
              final code = label.split('/').first;
              final unit = (item['unit'] as num?)?.toDouble() ?? 1;
              final buy = (item['buy'] as num?)?.toDouble() ?? 0;
              final sell = (item['sell'] as num?)?.toDouble() ?? 0;
              final value = marketMode == 'buy'
                  ? buy
                  : marketMode == 'sell'
                      ? sell
                      : (buy + sell) / 2;

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(flags[code] ?? '💱', style: const TextStyle(fontSize: 21)),
                  ),
                  title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    unit == 1
                        ? tr('د ۱ واحد نرخ', 'نرخ برای ۱ واحد', 'Rate per 1 unit')
                        : tr('د $unit واحدو نرخ', 'نرخ برای $unit واحد', 'Rate for $unit units'),
                  ),
                  trailing: Text(
                    '${formatted(value)} AFN',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              );
            }),
          ],
          const SizedBox(height: 10),
          Text(
            tr('یادونه: د بازار نرخونه د سرچینې د خپرو شوو معلوماتو له مخې ښودل کېږي.',
                'یادآوری: نرخ بازار مطابق اطلاعات منتشرشده منبع نمایش داده می‌شود.',
                'Note: Market rates are displayed as published by their source.'),
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget worldPage() {
    final sorted = [...world];
    sorted.sort((a, b) =>
        (a['code'] ?? '').toString().compareTo((b['code'] ?? '').toString()));

    return RefreshIndicator(
      onRefresh: fetchRates,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          headerCard(
            tr('د نړۍ اسعار', 'ارزهای جهان', 'World Currencies'),
            tr('د هر اسعارو ارزښت د افغانۍ په مقابل کې',
                'ارزش هر ارز در برابر افغانی',
                'Value of each currency against AFN'),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(
                worldStale ? Icons.warning_amber : Icons.update,
                color: worldStale ? Colors.orange : Colors.green,
              ),
              title: Text(worldStale
                  ? tr('نرخونه زاړه دي', 'نرخ‌ها قدیمی هستند', 'Rates may be stale')
                  : tr('د نرخونو د سرچینې وخت', 'زمان منبع نرخ‌ها', 'Rate source time')),
              subtitle: Text(dateText(worldUpdatedAt)),
            ),
          ),
          if (loading && world.isEmpty)
            const Center(child: Padding(
              padding: EdgeInsets.all(25),
              child: CircularProgressIndicator(),
            )),
          if (world.isEmpty && !loading)
            warningText(tr('د نړۍ نرخونه نه دي ترلاسه شوي.', 'نرخ‌های جهان دریافت نشد.', 'World rates could not be loaded.')),
          ...sorted.map((item) {
            final code = item['code']?.toString() ?? '';
            final rate = (item['afnPerUnit'] as num?)?.toDouble();
            if (rate == null) return const SizedBox.shrink();
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(flags[code] ?? '🌐', style: const TextStyle(fontSize: 21)),
                ),
                title: Text('$code  •  ${currencyName(code, widget.language)}'),
                subtitle: Text(tr('د ۱ واحد ارزښت په افغانۍ',
                    'ارزش ۱ واحد به افغانی', 'Value of 1 unit in AFN')),
                trailing: Text(
                  '${formatted(rate, digits: 6)} AFN',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget convertPage() {
    final codes = <String>{'AFN', ...world.map((e) => e['code'].toString())}.toList()
      ..sort();

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        headerCard(
          tr('د اسعارو تبدیل', 'تبدیل ارز', 'Currency Converter'),
          tr('خپل مبلغ ولیکئ او اسعار بدل کړئ',
              'مبلغ را وارد کنید و ارز را تبدیل نمایید',
              'Enter an amount and convert currencies'),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: tr('مبلغ', 'مبلغ', 'Amount'),
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.payments_outlined),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 18),
        DropdownButtonFormField<String>(
          value: codes.contains(fromCode) ? fromCode : 'USD',
          decoration: InputDecoration(
            labelText: tr('له کوم اسعارو', 'از کدام ارز', 'From currency'),
            border: const OutlineInputBorder(),
          ),
          items: codes.map((code) => DropdownMenuItem(
            value: code,
            child: Text('${flags[code] ?? '🌐'}  $code — ${currencyName(code, widget.language)}'),
          )).toList(),
          onChanged: (v) => setState(() => fromCode = v ?? 'USD'),
        ),
        const SizedBox(height: 12),
        Center(
          child: IconButton.filledTonal(
            onPressed: () => setState(() {
              final temp = fromCode;
              fromCode = toCode;
              toCode = temp;
            }),
            icon: const Icon(Icons.swap_vert, size: 28),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: codes.contains(toCode) ? toCode : 'AFN',
          decoration: InputDecoration(
            labelText: tr('کومو اسعارو ته', 'به کدام ارز', 'To currency'),
            border: const OutlineInputBorder(),
          ),
          items: codes.map((code) => DropdownMenuItem(
            value: code,
            child: Text('${flags[code] ?? '🌐'}  $code — ${currencyName(code, widget.language)}'),
          )).toList(),
          onChanged: (v) => setState(() => toCode = v ?? 'AFN'),
        ),
        const SizedBox(height: 24),
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                Text(tr('د تبدیل پایله', 'نتیجه تبدیل', 'Conversion result')),
                const SizedBox(height: 8),
                Text(
                  '$conversionResult $toCode',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('1 $fromCode = ${formatted(
                  (rateFor(fromCode) ?? 0) / (rateFor(toCode) ?? 1),
                  digits: 6,
                )} $toCode'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          tr('محاسبه د نړۍ د نرخونو له مخې کېږي؛ که د نړۍ نرخ نه وي، د ټاکل شوي افغان بازار نرخ کارول کېږي.',
              'محاسبه بر اساس نرخ جهانی انجام می‌شود؛ در صورت نبود نرخ جهانی، از نرخ بازار انتخاب‌شده استفاده می‌شود.',
              'Conversion uses world rates; if unavailable, the selected Afghan market rate is used.'),
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget languagePage() {
    final options = [
      ('ps', '🇦🇫', 'پښتو'),
      ('fa', '🇦🇫', 'دری'),
      ('en', '🇬🇧', 'English'),
    ];

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        headerCard('Language / ژبه / زبان',
            tr('د اپلیکیشن ژبه وټاکئ', 'زبان برنامه را انتخاب کنید', 'Choose your app language')),
        const SizedBox(height: 18),
        ...options.map((item) => Card(
          child: RadioListTile<String>(
            value: item.$1,
            groupValue: widget.language,
            onChanged: (v) {
              if (v != null) widget.onLanguageChanged(v);
            },
            title: Text('${item.$2}  ${item.$3}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            secondary: const Icon(Icons.translate),
          ),
        )),
      ],
    );
  }

  Widget settingsPage() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        headerCard(
          tr('تنظیمات', 'تنظیمات', 'Settings'),
          tr('د اپلیکیشن بڼه او نور انتخابونه',
              'ظاهر برنامه و گزینه‌های دیگر', 'App appearance and preferences'),
        ),
        const SizedBox(height: 14),
        Card(
          child: SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: Text(tr('تیاره بڼه', 'حالت تاریک', 'Dark mode')),
            subtitle: Text(tr('د شپې لپاره تیاره رنګونه',
                'رنگ‌های تیره برای شب', 'Use a darker appearance')),
            value: widget.darkMode,
            onChanged: widget.onThemeChanged,
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.language),
            title: Text(tr('د اپ ژبه', 'زبان برنامه', 'App language')),
            subtitle: Text(widget.language == 'ps'
                ? 'پښتو'
                : widget.language == 'fa' ? 'دری' : 'English'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => setState(() => page = 3),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.refresh),
            title: Text(tr('نرخونه تازه کول', 'به‌روزرسانی نرخ‌ها', 'Refresh rates')),
            onTap: fetchRates,
          ),
        ),
        if (error.isNotEmpty) warningText(error),
      ],
    );
  }

  Widget developerPage() {
    final hasPhoto = developerPhoto.isNotEmpty && File(developerPhoto).existsSync();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        headerCard(
          tr('د اپلیکیشن جوړوونکی', 'سازنده برنامه', 'App Developer'),
          tr('د جوړوونکي انځور او معلومات', 'عکس و معلومات سازنده', 'Developer profile'),
        ),
        const SizedBox(height: 25),
        Center(
          child: CircleAvatar(
            radius: 72,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            backgroundImage: hasPhoto ? FileImage(File(developerPhoto)) : null,
            child: hasPhoto
                ? null
                : const Icon(Icons.person, size: 75),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text('Abdullah Eman',
              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(tr('د Afghani Exchange Pro جوړوونکی',
              'سازنده Afghani Exchange Pro',
              'Creator of Afghani Exchange Pro')),
        ),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: changePhoto,
          icon: const Icon(Icons.photo_library_outlined),
          label: Text(tr('عکس بدل کړه', 'تغییر عکس', 'Change photo')),
        ),
        const SizedBox(height: 10),
        Text(
          tr('ستاسو ټاکل شوی عکس یوازې په همدې موبایل کې ساتل کېږي.',
              'عکس انتخاب‌شده فقط در همین موبایل ذخیره می‌شود.',
              'Your selected photo is stored locally on this device.'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget aboutPage() {
    final hasPhoto = developerPhoto.isNotEmpty && File(developerPhoto).existsSync();

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        headerCard(
          tr('د اپلیکیشن په اړه', 'درباره برنامه', 'About the app'),
          'Afghani Exchange Pro',
        ),
        const SizedBox(height: 20),
        Center(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: const Icon(Icons.currency_exchange, size: 65),
          ),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text('Afghani Exchange Pro',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        Center(child: Text(tr('نسخه 1.0.0', 'نسخه 1.0.0', 'Version 1.0.0'))),
        const SizedBox(height: 22),
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: hasPhoto ? FileImage(File(developerPhoto)) : null,
              child: hasPhoto ? null : const Icon(Icons.person),
            ),
            title: const Text('Abdullah Eman'),
            subtitle: Text(tr('جوړوونکی او پراختیاکوونکی',
                'سازنده و توسعه‌دهنده', 'Creator and Developer')),
          ),
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text('🇦🇫', style: TextStyle(fontSize: 38)),
                const SizedBox(height: 12),
                Text(
                  'افغانۍ زموږ ملي هویت دی؛ راکړه ورکړه په افغانۍ وکړو! 🇦🇫',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          tr('دا اپلیکیشن د افغانۍ او د نړۍ د اسعارو د نرخونو د کتلو او تبدیلولو لپاره جوړ شوی دی.',
              'این برنامه برای مشاهده و تبدیل نرخ افغانی و ارزهای جهان ساخته شده است.',
              'This app is designed to view and convert Afghan and world currency rates.'),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget headerCard(String title, String subtitle) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(subtitle, style: const TextStyle(fontSize: 13)),
            if (loading) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Widget warningText(String message) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
      ),
      child: Text(message, style: const TextStyle(fontSize: 13)),
    );
  }
}
