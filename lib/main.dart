import 'dart:async';
import 'dart:convert';
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

class AfghaniExchangeApp extends StatefulWidget {
  const AfghaniExchangeApp({super.key});

  @override
  State<AfghaniExchangeApp> createState() => _AfghaniExchangeAppState();
}

class _AfghaniExchangeAppState extends State<AfghaniExchangeApp> {
  ThemeMode themeMode = ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afghani Exchange Pro',
      themeMode: themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: HomePage(
        onThemeChanged: (dark) {
          setState(() {
            themeMode = dark ? ThemeMode.dark : ThemeMode.light;
          });
        },
      ),
    );
  }
}

class CurrencyRate {
  final String code;
  final double buy;
  final double sell;

  CurrencyRate({
    required this.code,
    required this.buy,
    required this.sell,
  });
}

class HomePage extends StatefulWidget {
  final ValueChanged<bool> onThemeChanged;

  const HomePage({super.key, required this.onThemeChanged});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker picker = ImagePicker();

  String language = 'ps';
  String market = 'sarafi';
  String? photoPath;

  bool loading = false;
  String message = '';

  List<CurrencyRate> rates = [];
  List<String> favorites = ['USD', 'EUR', 'PKR'];

  final TextEditingController amountController =
      TextEditingController(text: '1');

  String selectedCurrency = 'USD';
  String lastUpdated = '—';

  Timer? refreshTimer;

  final Map<String, String> flags = {
    'USD': '🇺🇸',
    'EUR': '🇪🇺',
    'GBP': '🇬🇧',
    'PKR': '🇵🇰',
    'INR': '🇮🇳',
    'AED': '🇦🇪',
    'SAR': '🇸🇦',
    'TRY': '🇹🇷',
    'CNY': '🇨🇳',
    'JPY': '🇯🇵',
    'CAD': '🇨🇦',
    'AUD': '🇦🇺',
    'CHF': '🇨🇭',
    'RUB': '🇷🇺',
    'IRR': '🇮🇷',
    'BDT': '🇧🇩',
    'KWD': '🇰🇼',
    'QAR': '🇶🇦',
    'OMR': '🇴🇲',
    'AFN': '🇦🇫',
  };

  final Map<String, Map<String, String>> words = {
    'ps': {
      'title': 'افغاني اکسچینج پرو',
      'converter': 'د اسعارو تبدیل',
      'markets': 'د نرخونو سرچینه',
      'sarafi': 'سرای شهزاده',
      'khorasan': 'خراسان مارکیټ',
      'bank': 'د افغانستان بانک',
      'buy': 'پېرود',
      'sell': 'پلور',
      'currency': 'اسعار',
      'amount': 'اندازه',
      'result': 'پایله',
      'refresh': 'نرخونه تازه کړه',
      'favorites': 'خوښې شوې پیسې',
      'history': 'د نرخونو تاریخچه',
      'profile': 'د جوړوونکي عکس',
      'changePhoto': 'عکس بدل کړه',
      'removePhoto': 'عکس لرې کړه',
      'language': 'ژبه',
      'dark': 'تیاره بڼه',
      'updated': 'وروستی تازه کېدل',
      'loading': 'نرخونه ترلاسه کېږي...',
      'error': 'نرخونه ترلاسه نه شول. وروسته بیا هڅه وکړه.',
      'noRates': 'اوس مهال نرخونه نشته',
      'developer': 'جوړوونکی',
      'name': 'Abdullah Eman',
      'photoSaved': 'عکس خوندي شو',
      'photoError': 'عکس انتخاب نه شو',
    },
    'fa': {
      'title': 'افغانی اکسچنج پرو',
      'converter': 'تبدیل ارز',
      'markets': 'منبع نرخ‌ها',
      'sarafi': 'سرای شهزاده',
      'khorasan': 'مارکیت خراسان',
      'bank': 'د افغانستان بانک',
      'buy': 'خرید',
      'sell': 'فروش',
      'currency': 'ارز',
      'amount': 'مقدار',
      'result': 'نتیجه',
      'refresh': 'تازه‌سازی نرخ‌ها',
      'favorites': 'ارزهای مورد علاقه',
      'history': 'تاریخچه نرخ‌ها',
      'profile': 'عکس سازنده',
      'changePhoto': 'تغییر عکس',
      'removePhoto': 'حذف عکس',
      'language': 'زبان',
      'dark': 'حالت تاریک',
      'updated': 'آخرین به‌روزرسانی',
      'loading': 'دریافت نرخ‌ها...',
      'error': 'دریافت نرخ‌ها ناموفق بود.',
      'noRates': 'فعلاً نرخی موجود نیست',
      'developer': 'سازنده',
      'name': 'Abdullah Eman',
      'photoSaved': 'عکس ذخیره شد',
      'photoError': 'انتخاب عکس ناموفق بود',
    },
    'en': {
      'title': 'Afghani Exchange Pro',
      'converter': 'Currency Converter',
      'markets': 'Rate Source',
      'sarafi': 'Sarai Shahzada',
      'khorasan': 'Khorasan Market',
      'bank': 'Da Afghanistan Bank',
      'buy': 'Buy',
      'sell': 'Sell',
      'currency': 'Currency',
      'amount': 'Amount',
      'result': 'Result',
      'refresh': 'Refresh Rates',
      'favorites': 'Favorites',
      'history': 'Rate History',
      'profile': 'Developer Photo',
      'changePhoto': 'Change Photo',
      'removePhoto': 'Remove Photo',
      'language': 'Language',
      'dark': 'Dark Mode',
      'updated': 'Last Updated',
      'loading': 'Loading rates...',
      'error': 'Could not load rates. Try again later.',
      'noRates': 'No rates available',
      'developer': 'Developer',
      'name': 'Abdullah Eman',
      'photoSaved': 'Photo saved',
      'photoError': 'Could not select photo',
    },
  };

  String t(String key) => words[language]?[key] ?? key;

  String get marketUrl {
    if (market == 'khorasan') {
      return 'https://sarafi.af/en/exchange-rates/khorasan-market';
    }
    if (market == 'bank') {
      return 'https://sarafi.af/en/exchange-rates/da-afg-bank';
    }
    return 'https://sarafi.af/en/exchange-rates';
  }

  @override
  void initState() {
    super.initState();
    loadSavedData();
    fetchRates();

    refreshTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => fetchRates(),
    );
  }

  Future<void> loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      language = prefs.getString('language') ?? 'ps';
      market = prefs.getString('market') ?? 'sarafi';
      photoPath = prefs.getString('developer_photo');
      favorites = prefs.getStringList('favorites') ??
          ['USD', 'EUR', 'PKR'];
    });

    // که خوندي شوی عکس موجود وي، هماغه ښکاره کېږي.
    if (photoPath != null && !File(photoPath!).existsSync()) {
      await prefs.remove('developer_photo');
      if (mounted) {
        setState(() => photoPath = null);
      }
    }
  }

  Future<void> choosePhoto() async {
    try {
      final XFile? selected = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (selected == null) return;

      final directory = await getApplicationDocumentsDirectory();
      final savedFile = File(
        '${directory.path}/developer_photo.jpg',
      );

      await File(selected.path).copy(savedFile.path);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('developer_photo', savedFile.path);

      if (!mounted) return;

      setState(() {
        photoPath = savedFile.path;
      });

      showMessage(t('photoSaved'));
    } catch (_) {
      showMessage(t('photoError'));
    }
  }

  Future<void> removePhoto() async {
    final prefs = await SharedPreferences.getInstance();

    if (photoPath != null) {
      final file = File(photoPath!);
      if (await file.exists()) {
        await file.delete();
      }
    }

    await prefs.remove('developer_photo');

    if (!mounted) return;

    setState(() => photoPath = null);
  }

  Future<void> saveLanguage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', value);

    if (!mounted) return;
    setState(() => language = value);
  }

  Future<void> saveMarket(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('market', value);

    if (!mounted) return;

    setState(() => market = value);
    fetchRates();
  }

  Future<void> fetchRates() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      message = '';
    });

    try {
      final response = await http.get(
        Uri.parse(marketUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0',
          'Accept': 'text/html',
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception('Website response: ${response.statusCode}');
      }

      final document = html_parser.parse(
        utf8.decode(response.bodyBytes),
      );

      final rows = document.querySelectorAll('table tr');
      final List<CurrencyRate> found = [];

      for (final row in rows) {
        final cells = row.querySelectorAll('th, td');

        if (cells.length < 3) continue;

        final label = cells[0].text.trim().toUpperCase();
        final buyText = cells[1].text.replaceAll(',', '').trim();
        final sellText = cells[2].text.replaceAll(',', '').trim();

        final match = RegExp(r'\b([A-Z]{3})\b').firstMatch(label);

        if (match == null) continue;

        final code = match.group(1)!;
        final buy = double.tryParse(
          buyText.replaceAll(RegExp(r'[^0-9.]'), ''),
        );
        final sell = double.tryParse(
          sellText.replaceAll(RegExp(r'[^0-9.]'), ''),
        );

        if (buy == null || sell == null || buy <= 0 || sell <= 0) {
          continue;
        }

        if (!found.any((rate) => rate.code == code)) {
          found.add(
            CurrencyRate(code: code, buy: buy, sell: sell),
          );
        }
      }

      if (found.isEmpty) {
        throw Exception('No exchange-rate rows found');
      }

      if (!mounted) return;

      setState(() {
        rates = found;
        loading = false;
        lastUpdated = DateTime.now().toLocal().toString().substring(0, 16);
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
        message = t('error');
      });
    }
  }

  Future<void> toggleFavorite(String code) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      if (favorites.contains(code)) {
        favorites.remove(code);
      } else {
        favorites.add(code);
      }
    });

    await prefs.setStringList('favorites', favorites);
  }

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  double get convertedAmount {
    final amount = double.tryParse(amountController.text) ?? 0;
    final rate = rates.where((r) => r.code == selectedCurrency);

    if (rate.isEmpty) return 0;

    // نرخ په جدول کې د AFN پر وړاندې ښودل کېږي.
    return amount * rate.first.sell;
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedRate = rates.where(
      (r) => r.code == selectedCurrency,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(t('title')),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: t('dark'),
            onPressed: () {
              final isDark =
                  Theme.of(context).brightness == Brightness.dark;
              widget.onThemeChanged(!isDark);
            },
            icon: const Icon(Icons.brightness_6),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: saveLanguage,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'ps', child: Text('پښتو')),
              PopupMenuItem(value: 'fa', child: Text('دری')),
              PopupMenuItem(value: 'en', child: Text('English')),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchRates,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            developerCard(),
            const SizedBox(height: 18),
            marketCard(),
            const SizedBox(height: 18),
            converterCard(selectedRate),
            const SizedBox(height: 18),
            Text(
              t('favorites'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            favoriteChips(),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t('markets'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  onPressed: fetchRates,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            Text(
              '${t('updated')}: $lastUpdated',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            if (loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (message.isNotEmpty)
              Text(message, textAlign: TextAlign.center)
            else if (rates.isEmpty)
              Text(t('noRates'), textAlign: TextAlign.center)
            else
              ...rates.map(rateCard),
            const SizedBox(height: 25),
            Center(
              child: Text(
                'Afghani Exchange Pro',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget developerCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              t('developer'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            CircleAvatar(
              radius: 55,
              backgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
              backgroundImage: photoPath != null
                  ? FileImage(File(photoPath!))
                  : null,
              child: photoPath == null
                  ? const Icon(Icons.person, size: 65)
                  : null,
            ),
            const SizedBox(height: 10),
            Text(
              t('name'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: choosePhoto,
              icon: const Icon(Icons.photo_library),
              label: Text(t('changePhoto')),
            ),
            if (photoPath != null)
              TextButton.icon(
                onPressed: removePhoto,
                icon: const Icon(Icons.delete_outline),
                label: Text(t('removePhoto')),
              ),
          ],
        ),
      ),
    );
  }

  Widget marketCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t('markets'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: market,
              isExpanded: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: 'sarafi',
                  child: Text(t('sarafi')),
                ),
                DropdownMenuItem(
                  value: 'khorasan',
                  child: Text(t('khorasan')),
                ),
                DropdownMenuItem(
                  value: 'bank',
                  child: Text(t('bank')),
                ),
              ],
              onChanged: (value) {
                if (value != null) saveMarket(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget converterCard(Iterable<CurrencyRate> selectedRate) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t('converter'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(t('amount')),
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
            const SizedBox(height: 12),
            Text(t('currency')),
            DropdownButtonFormField<String>(
              value: selectedCurrency,
              isExpanded: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: rates.map((rate) {
                return DropdownMenuItem(
                  value: rate.code,
                  child: Text(
                    '${flags[rate.code] ?? '💱'}  ${rate.code}',
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedCurrency = value);
                }
              },
            ),
            const SizedBox(height: 14),
            Text(
              '${t('result')}: ${convertedAmount.toStringAsFixed(2)} AFN',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget favoriteChips() {
    if (favorites.isEmpty) {
      return const Text('—');
    }

    return Wrap(
      spacing: 8,
      children: favorites.map((code) {
        return Chip(
          label: Text('${flags[code] ?? '💱'} $code'),
          onDeleted: () => toggleFavorite(code),
        );
      }).toList(),
    );
  }

  Widget rateCard(CurrencyRate rate) {
    final isFavorite = favorites.contains(rate.code);

    return Card(
      child: ListTile(
        leading: Text(
          flags[rate.code] ?? '💱',
          style: const TextStyle(fontSize: 27),
        ),
        title: Text(rate.code),
        subtitle: Text(
          '${t('buy')}: ${rate.buy} AFN   |   '
          '${t('sell')}: ${rate.sell} AFN',
        ),
        trailing: IconButton(
          onPressed: () => toggleFavorite(rate.code),
          icon: Icon(
            isFavorite ? Icons.star : Icons.star_border,
            color: isFavorite ? Colors.amber : null,
          ),
        ),
      ),
    );
  }
}
