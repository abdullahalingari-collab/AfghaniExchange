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
  'PKR': '🇵🇰', 'INR': '🇮🇳', 'IRR': '🇮🇷', 'SAR': '🇸🇦',
  'AED': '🇦🇪', 'TRY': '🇹🇷', 'CNY': '🇨🇳', 'JPY': '🇯🇵',
  'KWD': '🇰🇼', 'QAR': '🇶🇦', 'BHD': '🇧🇭', 'OMR': '🇴🇲',
  'CAD': '🇨🇦', 'AUD': '🇦🇺', 'CHF': '🇨🇭', 'RUB': '🇷🇺',
  'SEK': '🇸🇪', 'NOK': '🇳🇴', 'DKK': '🇩🇰', 'NZD': '🇳🇿',
  'SGD': '🇸🇬', 'MYR': '🇲🇾', 'THB': '🇹🇭', 'IDR': '🇮🇩',
  'KRW': '🇰🇷', 'HKD': '🇭🇰', 'BDT': '🇧🇩', 'LKR': '🇱🇰',
  'NPR': '🇳🇵', 'IQD': '🇮🇶', 'EGP': '🇪🇬', 'ZAR': '🇿🇦',
  'BRL': '🇧🇷', 'MXN': '🇲🇽', 'ARS': '🇦🇷', 'UAH': '🇺🇦',
  'PLN': '🇵🇱', 'CZK': '🇨🇿', 'HUF': '🇭🇺', 'RON': '🇷🇴',
  'ILS': '🇮🇱', 'JOD': '🇯🇴', 'KZT': '🇰🇿', 'UZS': '🇺🇿',
  'TJS': '🇹🇯', 'GEL': '🇬🇪', 'AMD': '🇦🇲', 'AZN': '🇦🇿',
  'DZD': '🇩🇿', 'MAD': '🇲🇦', 'TND': '🇹🇳', 'KES': '🇰🇪',
  'NGN': '🇳🇬', 'GHS': '🇬🇭', 'ETB': '🇪🇹', 'XOF': '🌍',
  'XAF': '🌍',
};

const Map<String, Map<String, String>> currencyNames = {
  'AFN': {'ps': 'افغانۍ', 'fa': 'افغانی', 'en': 'Afghan Afghani'},
  'USD': {'ps': 'امریکایي ډالر', 'fa': 'دالر آمریکا', 'en': 'US Dollar'},
  'EUR': {'ps': 'یورو', 'fa': 'یورو', 'en': 'Euro'},
  'GBP': {'ps': 'برېتانوي پونډ', 'fa': 'پوند بریتانیا', 'en': 'British Pound'},
  'PKR': {'ps': 'پاکستانۍ روپۍ', 'fa': 'روپیه پاکستان', 'en': 'Pakistani Rupee'},
  'INR': {'ps': 'هندي روپۍ', 'fa': 'روپیه هند', 'en': 'Indian Rupee'},
  'IRR': {'ps': 'ایراني تومان/ریال', 'fa': 'ریال ایران', 'en': 'Iranian Rial'},
  'SAR': {'ps': 'سعودي ریال', 'fa': 'ریال سعودی', 'en': 'Saudi Riyal'},
  'AED': {'ps': 'اماراتي درهم', 'fa': 'درهم امارات', 'en': 'UAE Dirham'},
  'TRY': {'ps': 'ترکي لیره', 'fa': 'لیره ترکیه', 'en': 'Turkish Lira'},
  'CNY': {'ps': 'چینایي یوان', 'fa': 'یوان چین', 'en': 'Chinese Yuan'},
  'JPY': {'ps': 'جاپاني ین', 'fa': 'ین جاپان', 'en': 'Japanese Yen'},
  'KWD': {'ps': 'کویتي دینار', 'fa': 'دینار کویت', 'en': 'Kuwaiti Dinar'},
  'QAR': {'ps': 'قطري ریال', 'fa': 'ریال قطر', 'en': 'Qatari Riyal'},
  'BHD': {'ps': 'بحریني دینار', 'fa': 'دینار بحرین', 'en': 'Bahraini Dinar'},
  'OMR': {'ps': 'عماني ریال', 'fa': 'ریال عمان', 'en': 'Omani Rial'},
  'CAD': {'ps': 'کاناډایي ډالر', 'fa': 'دالر کانادا', 'en': 'Canadian Dollar'},
  'AUD': {'ps': 'اسټرالیایي ډالر', 'fa': 'دالر استرالیا', 'en': 'Australian Dollar'},
  'CHF': {'ps': 'سویسي فرانک', 'fa': 'فرانک سوئیس', 'en': 'Swiss Franc'},
  'RUB': {'ps': 'روسي روبل', 'fa': 'روبل روسیه', 'en': 'Russian Ruble'},
  'SEK': {'ps': 'سویډني کرونا', 'fa': 'کرون سویدن', 'en': 'Swedish Krona'},
  'NOK': {'ps': 'نارویژي کرونا', 'fa': 'کرون ناروی', 'en': 'Norwegian Krone'},
  'DKK': {'ps': 'ډنمارکي کرونا', 'fa': 'کرون دنمارک', 'en': 'Danish Krone'},
  'NZD': {'ps': 'نیوزیلنډي ډالر', 'fa': 'دالر نیوزیلند', 'en': 'New Zealand Dollar'},
  'SGD': {'ps': 'سنګاپوري ډالر', 'fa': 'دالر سنگاپور', 'en': 'Singapore Dollar'},
  'MYR': {'ps': 'مالیزیایي رینګټ', 'fa': 'رینگیت مالیزیا', 'en': 'Malaysian Ringgit'},
  'THB': {'ps': 'تایلنډي باټ', 'fa': 'بات تایلند', 'en': 'Thai Baht'},
  'IDR': {'ps': 'اندونیزیایي روپیه', 'fa': 'روپیه اندونیزیا', 'en': 'Indonesian Rupiah'},
  'KRW': {'ps': 'کوریایي وون', 'fa': 'وون کوریای جنوبی', 'en': 'South Korean Won'},
  'HKD': {'ps': 'هانګ کانګ ډالر', 'fa': 'دالر هنگ‌کنگ', 'en': 'Hong Kong Dollar'},
  'BDT': {'ps': 'بنګله دېشي ټکه', 'fa': 'تاکای بنگلادش', 'en': 'Bangladeshi Taka'},
  'LKR': {'ps': 'سریلانکایي روپۍ', 'fa': 'روپیه سریلانکا', 'en': 'Sri Lankan Rupee'},
  'NPR': {'ps': 'نېپالي روپۍ', 'fa': 'روپیه نپال', 'en': 'Nepalese Rupee'},
  'IQD': {'ps': 'عراقي دینار', 'fa': 'دینار عراق', 'en': 'Iraqi Dinar'},
  'EGP': {'ps': 'مصري پونډ', 'fa': 'پوند مصر', 'en': 'Egyptian Pound'},
  'ZAR': {'ps': 'سویلي افریقایي رنډ', 'fa': 'رند آفریقای جنوبی', 'en': 'South African Rand'},
  'BRL': {'ps': 'برازیلي ریال', 'fa': 'رئال برازیل', 'en': 'Brazilian Real'},
  'MXN': {'ps': 'مکسیکوي پیسو', 'fa': 'پزوی مکزیک', 'en': 'Mexican Peso'},
  'ARS': {'ps': 'ارجنټایني پیسو', 'fa': 'پزوی آرژانتین', 'en': 'Argentine Peso'},
  'UAH': {'ps': 'اوکرایني هریونیا', 'fa': 'هریونیا اوکراین', 'en': 'Ukrainian Hryvnia'},
  'PLN': {'ps': 'پولنډي زلوټي', 'fa': 'زوتی لهستان', 'en': 'Polish Zloty'},
  'CZK': {'ps': 'چېکي کرونا', 'fa': 'کرون چک', 'en': 'Czech Koruna'},
  'HUF': {'ps': 'هنګري فورنټ', 'fa': 'فورینت مجارستان', 'en': 'Hungarian Forint'},
  'RON': {'ps': 'رومانیایي لېو', 'fa': 'لئو رومانی', 'en': 'Romanian Leu'},
  'ILS': {'ps': 'اسراییلي شېکل', 'fa': 'شکل اسرائیل', 'en': 'Israeli Shekel'},
  'JOD': {'ps': 'اردني دینار', 'fa': 'دینار اردن', 'en': 'Jordanian Dinar'},
  'KZT': {'ps': 'قزاقستاني ټینګ', 'fa': 'تنگه قزاقستان', 'en': 'Kazakhstani Tenge'},
  'UZS': {'ps': 'ازبک سوم', 'fa': 'سوم ازبکستان', 'en': 'Uzbekistani Som'},
  'TJS': {'ps': 'تاجکستاني سوموني', 'fa': 'سامانی تاجیکستان', 'en': 'Tajikistani Somoni'},
  'GEL': {'ps': 'ګرجستاني لاري', 'fa': 'لاری گرجستان', 'en': 'Georgian Lari'},
  'AMD': {'ps': 'ارمنستاني ډرام', 'fa': 'درام ارمنستان', 'en': 'Armenian Dram'},
  'AZN': {'ps': 'اذربایجاني منات', 'fa': 'منات آذربایجان', 'en': 'Azerbaijani Manat'},
  'DZD': {'ps': 'الجزایري دینار', 'fa': 'دینار الجزایر', 'en': 'Algerian Dinar'},
  'MAD': {'ps': 'مراکش درهم', 'fa': 'درهم مراکش', 'en': 'Moroccan Dirham'},
  'TND': {'ps': 'تونسي دینار', 'fa': 'دینار تونس', 'en': 'Tunisian Dinar'},
  'KES': {'ps': 'کینیا شیلینګ', 'fa': 'شیلینگ کنیا', 'en': 'Kenyan Shilling'},
  'NGN': {'ps': 'نایجریایي نایرا', 'fa': 'نایرا نیجریه', 'en': 'Nigerian Naira'},
  'GHS': {'ps': 'ګانایي سېدي', 'fa': 'سدی غنا', 'en': 'Ghanaian Cedi'},
  'ETB': {'ps': 'ایتوپیایي بیر', 'fa': 'بیر اتیوپی', 'en': 'Ethiopian Birr'},
  'XOF': {'ps': 'لوېدیځ افریقایي فرانک', 'fa': 'فرانک آفریقای غربی', 'en': 'West African CFA Franc'},
  'XAF': {'ps': 'منځنۍ افریقایي فرانک', 'fa': 'فرانک آفریقای مرکزی', 'en': 'Central African CFA Franc'},
};

const Map<String, Map<String, String>> words = {
  'ps': {
    'markets': 'بازارونه', 'world': 'نړیوال اسعار', 'convert': 'تبدیل',
    'language': 'ژبه', 'settings': 'تنظیمات', 'about': 'د اپ په اړه',
    'refresh': 'نرخونه تازه کړه', 'loading': 'نرخونه ترلاسه کېږي...',
    'error': 'معلومات ترلاسه نه شول', 'buy': 'پېر', 'sell': 'پلور',
    'average': 'منځنی نرخ', 'updated': 'وروستی تازه کېدل',
    'stale': 'خبرتیا: معلومات زاړه دي', 'amount': 'مقدار',
    'from': 'له', 'to': 'ته', 'result': 'پایله',
    'choose': 'انتخاب کړه', 'dark': 'تیاره بڼه', 'light': 'روښانه بڼه',
    'developer': 'جوړوونکی', 'changePhoto': 'عکس بدل کړه',
    'description': 'د اسعارو د نرخونو او تبدیل لپاره یو ساده اپلیکیشن.',
    'slogan': 'افغانۍ زموږ ملي هویت دی؛ راکړه ورکړه په افغانۍ وکړو! 🇦🇫',
    'source': 'سرچینه', 'noData': 'د دې بازار تایید شوي نرخونه اوس نشته.',
    'worldInfo': 'نړیوال نرخونه د مرجع API څخه اخیستل کېږي؛ د صرافۍ بازار نرخونه ورسره توپیر لرلی شي.',
    'official': 'رسمي نرخونه', 'market': 'د بازار نرخونه',
    'indicative': 'اټکلي نرخونه', 'languageTitle': 'د اپ ژبه وټاکئ',
    'photoSaved': 'عکس په موبایل کې خوندي شو',
  },
  'fa': {
    'markets': 'بازارها', 'world': 'ارزهای جهانی', 'convert': 'تبدیل',
    'language': 'زبان', 'settings': 'تنظیمات', 'about': 'درباره برنامه',
    'refresh': 'تازه‌سازی نرخ‌ها', 'loading': 'در حال دریافت نرخ‌ها...',
    'error': 'دریافت اطلاعات ناموفق بود', 'buy': 'خرید', 'sell': 'فروش',
    'average': 'نرخ میانگین', 'updated': 'آخرین به‌روزرسانی',
    'stale': 'هشدار: اطلاعات قدیمی است', 'amount': 'مقدار',
    'from': 'از', 'to': 'به', 'result': 'نتیجه',
    'choose': 'انتخاب کنید', 'dark': 'حالت تاریک', 'light': 'حالت روشن',
    'developer': 'سازنده', 'changePhoto': 'تغییر عکس',
    'description': 'برنامه‌ای ساده برای مشاهده و تبدیل نرخ ارزها.',
    'slogan': 'افغانی هویت ملی ماست؛ دادوستد خود را با افغانی انجام دهیم! 🇦🇫',
    'source': 'منبع', 'noData': 'در حال حاضر نرخ تأییدشده‌ای برای این بازار موجود نیست.',
    'worldInfo': 'نرخ‌های جهانی از API مرجع دریافت می‌شوند و ممکن است با نرخ بازار صرافی تفاوت داشته باشند.',
    'official': 'نرخ رسمی', 'market': 'نرخ بازار',
    'indicative': 'نرخ تقریبی', 'languageTitle': 'زبان برنامه را انتخاب کنید',
    'photoSaved': 'عکس در موبایل ذخیره شد',
  },
  'en': {
    'markets': 'Markets', 'world': 'World Rates', 'convert': 'Converter',
    'language': 'Language', 'settings': 'Settings', 'about': 'About',
    'refresh': 'Refresh rates', 'loading': 'Loading rates...',
    'error': 'Could not load data', 'buy': 'Buy', 'sell': 'Sell',
    'average': 'Average', 'updated': 'Last updated',
    'stale': 'Warning: data may be outdated', 'amount': 'Amount',
    'from': 'From', 'to': 'To', 'result': 'Result',
    'choose': 'Choose', 'dark': 'Dark mode', 'light': 'Light mode',
    'developer': 'Developer', 'changePhoto': 'Change photo',
    'description': 'A simple app for viewing and converting currency rates.',
    'slogan': 'The Afghani is our national identity. Let us trade in Afghani! 🇦🇫',
    'source': 'Source', 'noData': 'No verified rates are currently available for this market.',
    'worldInfo': 'World rates come from a reference API and may differ from local exchange-market rates.',
    'official': 'Official rates', 'market': 'Market rates',
    'indicative': 'Indicative rates', 'languageTitle': 'Choose app language',
    'photoSaved': 'Photo saved on this device',
  },
};

class AfghaniExchangeApp extends StatefulWidget {
  const AfghaniExchangeApp({super.key});

  @override
  State<AfghaniExchangeApp> createState() => _AfghaniExchangeAppState();
}

class _AfghaniExchangeAppState extends State<AfghaniExchangeApp> {
  bool darkMode = false;
  String language = 'ps';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      darkMode = prefs.getBool('darkMode') ?? false;
      language = prefs.getString('language') ?? 'ps';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', darkMode);
    await prefs.setString('language', language);
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF087B45);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afghani Exchange',
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: green,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: green,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: green,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF075C36),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: ExchangeHome(
        language: language,
        darkMode: darkMode,
        onLanguageChanged: (value) {
          setState(() => language = value);
          _saveSettings();
        },
        onDarkModeChanged: (value) {
          setState(() => darkMode = value);
          _saveSettings();
        },
      ),
    );
  }
}

class ExchangeHome extends StatefulWidget {
  final String language;
  final bool darkMode;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<bool> onDarkModeChanged;

  const ExchangeHome({
    super.key,
    required this.language,
    required this.darkMode,
    required this.onLanguageChanged,
    required this.onDarkModeChanged,
  });

  @override
  State<ExchangeHome> createState() => _ExchangeHomeState();
}

class _ExchangeHomeState extends State<ExchangeHome> {
  int page = 0;
  bool loading = false;
  String? error;
  Map<String, dynamic> markets = {};
  List<dynamic> world = [];
  String? worldUpdatedAt;
  int? worldAgeMinutes;
  bool worldStale = false;
  String selectedMarket = 'sarai';
  String fromCode = 'USD';
  String toCode = 'AFN';
  final amountController = TextEditingController(text: '1');
  String? developerPhoto;

  String t(String key) => words[widget.language]?[key] ??
      words['en']![key] ?? key;

  @override
  void initState() {
    super.initState();
    _loadPhoto();
    fetchRates();
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<void> _loadPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => developerPhoto = prefs.getString('developerPhoto'));
  }

  Future<void> _changePhoto() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1000,
      );
      if (image == null) return;

      final directory = await getApplicationDocumentsDirectory();
      final saved = await File(image.path).copy(
        '${directory.path}/developer_photo.jpg',
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('developerPhoto', saved.path);

      if (!mounted) return;
      setState(() => developerPhoto = saved.path);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('photoSaved'))),
      );
    } catch (e) {
      _showMessage('Photo error: $e');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> fetchRates() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final response = await http.get(Uri.parse(workerUrl))
          .timeout(const Duration(seconds: 25));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Invalid response');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cachedRates', response.body);

      if (!mounted) return;
      setState(() {
        markets = Map<String, dynamic>.from(data['markets'] ?? {});
        world = List<dynamic>.from(data['world'] ?? []);
        worldUpdatedAt = data['worldUpdatedAt']?.toString();
        worldAgeMinutes = data['worldAgeMinutes'] is num
            ? (data['worldAgeMinutes'] as num).toInt()
            : null;
        worldStale = data['worldIsStale'] == true;
        loading = false;
      });
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cachedRates');

      if (cached != null) {
        try {
          final data = jsonDecode(cached) as Map<String, dynamic>;
          if (!mounted) return;
          setState(() {
            markets = Map<String, dynamic>.from(data['markets'] ?? {});
            world = List<dynamic>.from(data['world'] ?? []);
            worldUpdatedAt = data['worldUpdatedAt']?.toString();
            worldAgeMinutes = data['worldAgeMinutes'] is num
                ? (data['worldAgeMinutes'] as num).toInt()
                : null;
            worldStale = true;
            loading = false;
            error = e.toString();
          });
          return;
        } catch (_) {}
      }

      if (!mounted) return;
      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  double? worldRate(String code) {
    if (code == 'AFN') return 1;

    for (final item in world) {
      if (item is Map && item['code'] == code) {
        final value = item['afnPerUnit'];
        if (value is num && value > 0) return value.toDouble();
      }
    }
    return null;
  }

  Map<String, dynamic>? marketRow(String market, String code) {
    final marketData = markets[market];
    if (marketData is! Map) return null;

    final rows = marketData['rows'];
    if (rows is! List) return null;

    for (final item in rows) {
      if (item is! Map) continue;
      final label = item['label']?.toString().toUpperCase() ?? '';
      if (RegExp('\\b${RegExp.escape(code)}\\s*/\\s*AFN\\b')
          .hasMatch(label)) {
        return Map<String, dynamic>.from(item);
      }
    }
    return null;
  }

  double? marketRate(String code) {
    if (code == 'AFN') return 1;

    final row = marketRow(selectedMarket, code);
    if (row == null) return null;

    final buy = row['buy'];
    final unit = row['unit'];

    if (buy is! num || unit is! num || unit <= 0) return null;
    return buy.toDouble() / unit.toDouble();
  }

  double? rateFor(String code) {
    return marketRate(code) ?? worldRate(code);
  }

  String currencyName(String code) {
    return currencyNames[code]?[widget.language] ??
        currencyNames[code]?['en'] ??
        code;
  }

  String formatNumber(double value, {int decimals = 4}) {
    if (!value.isFinite) return '—';

    final fixed = value.toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final integer = parts[0];
    final buffer = StringBuffer();

    for (int i = 0; i < integer.length; i++) {
      if (i > 0 && (integer.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(integer[i]);
    }

    String decimal = parts.length > 1 ? parts[1] : '';
    while (decimal.endsWith('0') && decimal.isNotEmpty) {
      decimal = decimal.substring(0, decimal.length - 1);
    }

    return decimal.isEmpty ? buffer.toString() : '${buffer.toString()}.$decimal';
  }

  String formatDate(String? value) {
    if (value == null) return '—';
    final date = DateTime.tryParse(value)?.toLocal();
    if (date == null) return value;
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/'
        '${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  double? get convertedAmount {
    final amount = double.tryParse(amountController.text.trim());
    final fromRate = rateFor(fromCode);
    final toRate = rateFor(toCode);

    if (amount == null || amount < 0 || fromRate == null ||
        toRate == null || toRate == 0) {
      return null;
    }
    return amount * fromRate / toRate;
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      t('markets'), t('world'), t('convert'),
      t('language'), t('settings'), t('about'),
    ];

    return Directionality(
      textDirection: widget.language == 'en'
          ? TextDirection.ltr
          : TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Afghani Exchange',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              onPressed: loading ? null : fetchRates,
              icon: const Icon(Icons.refresh),
              tooltip: t('refresh'),
            ),
          ],
        ),
        body: Column(
          children: [
            _flagBanner(),
            Expanded(
              child: loading && markets.isEmpty && world.isEmpty
                  ? Center(child: Text(t('loading')))
                  : _pageBody(),
            ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: page,
          onDestinationSelected: (value) {
            setState(() => page = value);
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.storefront_outlined),
              selectedIcon: const Icon(Icons.storefront),
              label: t('markets'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.public),
              label: t('world'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.currency_exchange),
              label: t('convert'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.language),
              label: t('language'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings),
              label: t('settings'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.info_outline),
              label: t('about'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _flagBanner() {
    return SizedBox(
      height: 7,
      child: Row(
        children: [
          Expanded(child: Container(color: const Color(0xFF202020))),
          Expanded(child: Container(color: const Color(0xFFCE2028))),
          Expanded(child: Container(color: const Color(0xFF087B45))),
        ],
      ),
    );
  }

  Widget _pageBody() {
    switch (page) {
      case 0:
        return _marketsPage();
      case 1:
        return _worldPage();
      case 2:
        return _convertPage();
      case 3:
        return _languagePage();
      case 4:
        return _settingsPage();
      default:
        return _aboutPage();
    }
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF087B45)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _marketSelector() {
    final labels = {
      'bank': widget.language == 'ps' ? 'افغانستان بانک'
          : widget.language == 'fa' ? 'بانک افغانستان' : 'Da Afghanistan Bank',
      'sarai': widget.language == 'ps' ? 'شهزاده سرای'
          : widget.language == 'fa' ? 'سرای شهزاده' : 'Sarai Shahzada',
      'khorasan': widget.language == 'ps' ? 'خراسان (هرات)'
          : widget.language == 'fa' ? 'خراسان (هرات)' : 'Khorasan (Herat)',
      'kandahar': widget.language == 'ps' ? 'کندهار'
          : widget.language == 'fa' ? 'قندهار' : 'Kandahar',
      'nangarhar': widget.language == 'ps' ? 'ننګرهار'
          : widget.language == 'fa' ? 'ننگرهار' : 'Nangarhar',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonFormField<String>(
        value: selectedMarket,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: t('choose'),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        items: labels.entries.map((entry) {
          return DropdownMenuItem(
            value: entry.key,
            child: Text(entry.value),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) setState(() => selectedMarket = value);
        },
      ),
    );
  }

  Widget _marketsPage() {
    final data = markets[selectedMarket];
    final rows = data is Map && data['rows'] is List
        ? List<dynamic>.from(data['rows'])
        : <dynamic>[];
    final isStale = data is Map && data['stale'] == true;
    final sourceError = data is Map ? data['error']?.toString() : null;

    return RefreshIndicator(
      onRefresh: fetchRates,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 20),
        children: [
          _sectionTitle(t('markets'), Icons.storefront),
          _marketSelector(),
          if (isStale)
            _notice(t('stale'), Colors.orange),
          if (rows.isEmpty)
            _emptyMarket(sourceError)
          else
            ...rows.map((item) => _marketCard(
                  Map<String, dynamic>.from(item as Map),
                  data is Map ? data['rateType']?.toString() : null,
                )),
          if (data is Map && data['checkedAt'] != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '${t('updated')}: ${formatDate(data['checkedAt']?.toString())}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  Widget _emptyMarket(String? details) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.cloud_off, size: 42, color: Colors.orange),
              const SizedBox(height: 12),
              Text(t('noData'), textAlign: TextAlign.center),
              if (details != null) ...[
                const SizedBox(height: 8),
                Text(details,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _marketCard(Map<String, dynamic> row, String? rateType) {
    final label = row['label']?.toString() ?? '';
    final match = RegExp(r'([A-Z]{3})\s*/\s*AFN', caseSensitive: false)
        .firstMatch(label);
    final code = match?.group(1)?.toUpperCase() ?? '';
    final buy = row['buy'] is num ? (row['buy'] as num).toDouble() : null;
    final sell = row['sell'] is num ? (row['sell'] as num).toDouble() : null;
    final unit = row['unit'] is num ? (row['unit'] as num).toDouble() : 1.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Text(flags[code] ?? '💱',
                    style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(code,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(currencyName(code),
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                if (unit > 1)
                  Text(
                    '${formatNumber(unit.toDouble(), decimals: 0)} ${widget.language == 'en' ? 'units' : 'واحده'}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
              ],
            ),
            const Divider(height: 22),
            Row(
              children: [
                Expanded(child: _rateColumn(t('buy'), buy)),
                Expanded(child: _rateColumn(t('sell'), sell)),
                Expanded(
                  child: _rateColumn(
                    t('average'),
                    buy != null && sell != null ? (buy + sell) / 2 : null,
                  ),
                ),
              ],
            ),
            if (rateType != null)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    rateType == 'official'
                        ? t('official')
                        : rateType == 'indicative'
                            ? t('indicative')
                            : t('market'),
                    style: const TextStyle(
                        fontSize: 11, color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _rateColumn(String label, double? value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 5),
        Text(
          value == null ? '—' : formatNumber(value),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ],
    );
  }

  Widget _notice(String message, Color color) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message, style: TextStyle(color: color)),
    );
  }

  Widget _worldPage() {
    final sorted = [...world];
    sorted.sort((a, b) =>
        (a['code'] as String).compareTo(b['code'] as String));

    return RefreshIndicator(
      onRefresh: fetchRates,
      child: ListView(
        children: [
          _sectionTitle(t('world'), Icons.public),
          _notice(t('worldInfo'), Colors.blue),
          if (worldStale) _notice(t('stale'), Colors.orange),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              '${t('updated')}: ${formatDate(worldUpdatedAt)}'
              '${worldAgeMinutes == null ? '' : '  •  ${worldAgeMinutes} min'}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          ...sorted.map((item) {
            final code = item['code'].toString();
            final value = (item['afnPerUnit'] as num).toDouble();

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: ListTile(
                leading: Text(flags[code] ?? '🌐',
                    style: const TextStyle(fontSize: 27)),
                title: Text('$code - ${currencyName(code)}'),
                trailing: Text(
                  formatNumber(value, decimals: 6),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _currencyDropdown(String value, ValueChanged<String?> onChanged) {
    final codes = <String>{'AFN', ...world.map((e) => e['code'].toString())}
        .toList()
      ..sort();

    return DropdownButtonFormField<String>(
      value: codes.contains(value) ? value : 'AFN',
      isExpanded: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: codes.map((code) {
        return DropdownMenuItem(
          value: code,
          child: Text('${flags[code] ?? '🌐'}  $code - ${currencyName(code)}',
              overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _convertPage() {
    final result = convertedAmount;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionTitle(t('convert'), Icons.currency_exchange),
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
                    labelText: t('amount'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                Text('${t('from')}:'),
                const SizedBox(height: 6),
                _currencyDropdown(fromCode, (value) {
                  if (value != null) setState(() => fromCode = value);
                }),
                const SizedBox(height: 16),
                IconButton.filled(
                  onPressed: () {
                    setState(() {
                      final temp = fromCode;
                      fromCode = toCode;
                      toCode = temp;
                    });
                  },
                  icon: const Icon(Icons.swap_vert),
                ),
                const SizedBox(height: 10),
                Text('${t('to')}:'),
                const SizedBox(height: 6),
                _currencyDropdown(toCode, (value) {
                  if (value != null) setState(() => toCode = value);
                }),
                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF087B45).withOpacity(0.10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF087B45)),
                  ),
                  child: Column(
                    children: [
                      Text(t('result'),
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text(
                        result == null
                            ? '—'
                            : '${formatNumber(result, decimals: 6)} $toCode',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF087B45),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.language == 'en'
                      ? 'Local market rate is preferred when available; otherwise the world reference rate is used.'
                      : widget.language == 'fa'
                          ? 'در صورت موجود بودن، نرخ بازار محلی استفاده می‌شود؛ در غیر آن نرخ مرجع جهانی به کار می‌رود.'
                          : 'که د محلي بازار نرخ موجود وي، هماغه کارېږي؛ که نه وي، نړیوال مرجع نرخ کارول کېږي.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _languagePage() {
    return ListView(
      children: [
        _sectionTitle(t('languageTitle'), Icons.language),
        _languageTile('ps', 'پښتو', '🇦🇫'),
        _languageTile('fa', 'دری', '🇦🇫'),
        _languageTile('en', 'English', '🌐'),
      ],
    );
  }

  Widget _languageTile(String code, String name, String flag) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: RadioListTile<String>(
        value: code,
        groupValue: widget.language,
        onChanged: (value) {
          if (value != null) widget.onLanguageChanged(value);
        },
        title: Text('$flag  $name'),
        activeColor: const Color(0xFF087B45),
      ),
    );
  }

  Widget _settingsPage() {
    return ListView(
      children: [
        _sectionTitle(t('settings'), Icons.settings),
        SwitchListTile(
          title: Text(widget.darkMode ? t('dark') : t('light')),
          secondary: Icon(
            widget.darkMode ? Icons.dark_mode : Icons.light_mode,
          ),
          value: widget.darkMode,
          onChanged: widget.onDarkModeChanged,
        ),
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(t('language')),
          subtitle: Text(widget.language.toUpperCase()),
          onTap: () => setState(() => page = 3),
        ),
        ListTile(
          leading: const Icon(Icons.refresh),
          title: Text(t('refresh')),
          onTap: fetchRates,
        ),
      ],
    );
  }

  Widget _aboutPage() {
    final photoExists = developerPhoto != null &&
        File(developerPhoto!).existsSync();

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const SizedBox(height: 16),
        Center(
          child: Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF087B45),
                width: 3,
              ),
            ),
            child: ClipOval(
              child: photoExists
                  ? Image.file(File(developerPhoto!), fit: BoxFit.cover)
                  : const Icon(Icons.person, size: 65),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Abdullah Eman',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Center(
          child: Text(
            t('developer'),
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: OutlinedButton.icon(
            onPressed: _changePhoto,
            icon: const Icon(Icons.photo_camera),
            label: Text(t('changePhoto')),
          ),
        ),
        const SizedBox(height: 22),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                const Icon(
                  Icons.currency_exchange,
                  size: 42,
                  color: Color(0xFF087B45),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Afghani Exchange',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(t('description'), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Text(
                  t('slogan'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF087B45),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              t('worldInfo'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'Version 1.0.0',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
