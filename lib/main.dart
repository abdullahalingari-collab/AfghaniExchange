import 'dart:async';
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
  runApp(const AfghanAsaarApp());
}

class AfghanAsaarApp extends StatefulWidget {
  const AfghanAsaarApp({super.key});

  @override
  State<AfghanAsaarApp> createState() => _AfghanAsaarAppState();
}

class _AfghanAsaarAppState extends State<AfghanAsaarApp> {
  String language = 'ps';
  bool darkMode = false;
  int page = 0;
  String selectedMarket = 'bank';

  bool loading = false;
  String? errorMessage;
  String? photoPath;

  Timer? timer;

  Map<String, List<Map<String, dynamic>>> markets = {
    'bank': [],
    'sarai': [],
    'khorasan': [],
  };

  List<Map<String, dynamic>> worldRates = [];
  List<Map<String, dynamic>> history = [];

  final Map<String, Map<String, String>> words = {
    'ps': {
      'markets': 'د اسعارو بازارونه',
      'bank': 'افغانستان بانک',
      'sarai': 'سرای شهزاده',
      'khorasan': 'خراسان مارکېټ',
      'world': 'نړیوال اسعار',
      'history': 'د نرخونو تاریخ',
      'developer': 'جوړوونکی',
      'buy': 'اخیستل',
      'sell': 'پلورل',
      'refresh': 'نرخونه تازه کړه',
      'noRates': 'اوس مهال نرخونه نشته',
      'loading': 'نرخونه ترلاسه کېږي...',
      'error': 'د نرخونو ترلاسه کولو کې ستونزه ده',
      'choosePhoto': 'عکس انتخاب کړه',
      'removePhoto': 'عکس لرې کړه',
      'language': 'ژبه',
      'dark': 'تیاره بڼه',
      'light': 'روښانه بڼه',
      'afn': 'افغانۍ',
      'updated': 'د معلوماتو وخت',
      'noHistory': 'تر اوسه تاریخ نشته',
      'worldInfo': 'نړیوال اسعار په افغانۍ',
      'appName': 'افغان اسعار',
      'developerName': 'Abdullah Eman',
    },
    'fa': {
      'markets': 'بازارهای اسعار',
      'bank': 'بانک افغانستان',
      'sarai': 'سرای شهزاده',
      'khorasan': 'مارکیت خراسان',
      'world': 'ارزهای جهان',
      'history': 'تاریخچه نرخ‌ها',
      'developer': 'سازنده',
      'buy': 'خرید',
      'sell': 'فروش',
      'refresh': 'تازه‌سازی نرخ‌ها',
      'noRates': 'فعلاً نرخی موجود نیست',
      'loading': 'دریافت نرخ‌ها...',
      'error': 'در دریافت نرخ‌ها مشکل پیش آمد',
      'choosePhoto': 'انتخاب عکس',
      'removePhoto': 'حذف عکس',
      'language': 'زبان',
      'dark': 'حالت تاریک',
      'light': 'حالت روشن',
      'afn': 'افغانی',
      'updated': 'زمان معلومات',
      'noHistory': 'هنوز تاریخچه موجود نیست',
      'worldInfo': 'ارزهای جهان به افغانی',
      'appName': 'افغان اسعار',
      'developerName': 'Abdullah Eman',
    },
    'en': {
      'markets': 'Currency Markets',
      'bank': 'Da Afghanistan Bank',
      'sarai': 'Sarai Shahzada',
      'khorasan': 'Khorasan Market',
      'world': 'World Currencies',
      'history': 'Rate History',
      'developer': 'Developer',
      'buy': 'Buy',
      'sell': 'Sell',
      'refresh': 'Refresh Rates',
      'noRates': 'No rates available',
      'loading': 'Loading rates...',
      'error': 'Unable to load rates',
      'choosePhoto': 'Choose Photo',
      'removePhoto': 'Remove Photo',
      'language': 'Language',
      'dark': 'Dark Mode',
      'light': 'Light Mode',
      'afn': 'Afghani',
      'updated': 'Information time',
      'noHistory': 'No history yet',
      'worldInfo': 'World currencies in AFN',
      'appName': 'Afghan Asaar',
      'developerName': 'Abdullah Eman',
    },
  };

  String tr(String key) => words[language]?[key] ?? key;

  final Map<String, String> flags = {
    'AFN': '🇦🇫',
    'USD': '🇺🇸',
    'EUR': '🇪🇺',
    'GBP': '🇬🇧',
    'INR': '🇮🇳',
    'PKR': '🇵🇰',
    'IRR': '🇮🇷',
    'CNY': '🇨🇳',
    'TRY': '🇹🇷',
    'AED': '🇦🇪',
    'SAR': '🇸🇦',
    'QAR': '🇶🇦',
    'KWD': '🇰🇼',
    'JPY': '🇯🇵',
    'CAD': '🇨🇦',
    'AUD': '🇦🇺',
    'CHF': '🇨🇭',
    'RUB': '🇷🇺',
    'BDT': '🇧🇩',
    'NPR': '🇳🇵',
    'SEK': '🇸🇪',
    'NOK': '🇳🇴',
    'DKK': '🇩🇰',
    'MYR': '🇲🇾',
    'IDR': '🇮🇩',
    'THB': '🇹🇭',
    'SGD': '🇸🇬',
    'ZAR': '🇿🇦',
    'NZD': '🇳🇿',
    'HKD': '🇭🇰',
    'EGP': '🇪🇬',
    'IQD': '🇮🇶',
    'OMR': '🇴🇲',
    'BHD': '🇧🇭',
    'JOD': '🇯🇴',
    'LKR': '🇱🇰',
    'KRW': '🇰🇷',
    'BRL': '🇧🇷',
    'MXN': '🇲🇽',
  };

  String currencyCode(String label) {
    final upper = label.toUpperCase();

    for (final code in flags.keys) {
      if (RegExp(r'\b' + code + r'\b').hasMatch(upper)) {
        return code;
      }
    }

    final lower = label.toLowerCase();

    if (lower.contains('pakistan') ||
        lower.contains('pakistani')) return 'PKR';
    if (lower.contains('indian')) return 'INR';
    if (lower.contains('iran') ||
        lower.contains('toman')) return 'IRR';
    if (lower.contains('dollar')) return 'USD';
    if (lower.contains('euro')) return 'EUR';
    if (lower.contains('pound')) return 'GBP';
    if (lower.contains('rupee')) return 'INR';
    if (lower.contains('yuan')) return 'CNY';
    if (lower.contains('dirham')) return 'AED';
    if (lower.contains('riyal')) return 'SAR';
    if (lower.contains('franc')) return 'CHF';

    return '';
  }

  String flagFor(String code) => flags[code] ?? '🌍';

  @override
  void initState() {
    super.initState();
    restoreSettings();
    refreshRates();

    timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => refreshRates(),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> restoreSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    List<Map<String, dynamic>> savedHistory = [];

    try {
      final decoded = jsonDecode(
        prefs.getString('history') ?? '[]',
      ) as List;

      savedHistory = decoded
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (_) {}

    setState(() {
      language = prefs.getString('language') ?? 'ps';
      darkMode = prefs.getBool('darkMode') ?? false;
      photoPath = prefs.getString('developerPhoto');
      history = savedHistory;
    });
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    await prefs.setBool('darkMode', darkMode);
  }

  Future<void> refreshRates() async {
    if (loading) return;

    if (mounted) {
      setState(() {
        loading = true;
        errorMessage = null;
      });
    }

    try {
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 25));

      if (response.statusCode != 200) {
        throw Exception('Server error');
      }

      final data =
          jsonDecode(response.body) as Map<String, dynamic>;

      final marketData =
          Map<String, dynamic>.from(data['markets'] ?? {});

      final newMarkets =
          <String, List<Map<String, dynamic>>>{};

      for (final key in ['bank', 'sarai', 'khorasan']) {
        final market = Map<String, dynamic>.from(
          marketData[key] ?? {},
        );

        final rows = (market['rows'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e))
            .where((row) =>
                row['buy'] is num &&
                row['sell'] is num)
            .toList();

        newMarkets[key] = rows;
      }

      final newWorld = (data['world'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      if (!mounted) return;

      setState(() {
        markets = newMarkets;
        worldRates = newWorld;
        loading = false;
      });

      await saveHistory();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = tr('error');
      });
    }
  }

  Future<void> saveHistory() async {
    final prefs = await SharedPreferences.getInstance();

    final entry = {
      'time': DateTime.now().toIso8601String(),
      'bank': markets['bank']?.length ?? 0,
      'sarai': markets['sarai']?.length ?? 0,
      'khorasan': markets['khorasan']?.length ?? 0,
    };

    history.insert(0, entry);

    if (history.length > 50) {
      history = history.take(50).toList();
    }

    await prefs.setString('history', jsonEncode(history));

    if (mounted) setState(() {});
  }

  Future<void> changeLanguage(String value) async {
    setState(() => language = value);
    await saveSettings();
  }

  Future<void> choosePhoto() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return;

    final directory = await getApplicationDocumentsDirectory();

    final saved = await File(image.path).copy(
      '${directory.path}/developer_profile.jpg',
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('developerPhoto', saved.path);

    if (!mounted) return;

    setState(() => photoPath = saved.path);
  }

  Future<void> removePhoto() async {
    final prefs = await SharedPreferences.getInstance();

    if (photoPath != null) {
      final file = File(photoPath!);
      if (await file.exists()) {
        await file.delete();
      }
    }

    await prefs.remove('developerPhoto');

    if (!mounted) return;

    setState(() => photoPath = null);
  }

  String formatRate(dynamic value) {
    if (value is num) {
      return value.toStringAsFixed(
        value >= 100 ? 2 : 4,
      );
    }
    return '—';
  }

  String marketTitle(String key) {
    if (key == 'bank') return tr('bank');
    if (key == 'sarai') return tr('sarai');
    return tr('khorasan');
  }

  Widget marketRow(Map<String, dynamic> row) {
    final label = (row['label'] ?? '').toString();
    final code = currencyCode(label);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Row(
          children: [
            Text(
              flagFor(code),
              style: const TextStyle(fontSize: 27),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            Column(
              children: [
                Text(
                  tr('buy'),
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  formatRate(row['buy']),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 18),
            Column(
              children: [
                Text(
                  tr('sell'),
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  formatRate(row['sell']),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget marketsPage() {
    final rows = markets[selectedMarket] ?? [];

    return RefreshIndicator(
      onRefresh: refreshRates,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          SegmentedButton<String>(
            segments: [
              ButtonSegment(
                value: 'bank',
                label: Text(tr('bank')),
              ),
              ButtonSegment(
                value: 'sarai',
                label: Text(tr('sarai')),
              ),
              ButtonSegment(
                value: 'khorasan',
                label: Text(tr('khorasan')),
              ),
            ],
            selected: {selectedMarket},
            onSelectionChanged: (value) {
              setState(() => selectedMarket = value.first);
            },
          ),
          const SizedBox(height: 15),
          Text(
            marketTitle(selectedMarket),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          if (loading)
            Padding(
              padding: const EdgeInsets.all(15),
              child: Center(child: Text(tr('loading'))),
            ),
          if (errorMessage != null)
            Center(
              child: Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          if (rows.isEmpty && !loading)
            Padding(
              padding: const EdgeInsets.all(25),
              child: Center(child: Text(tr('noRates'))),
            ),
          ...rows.map(marketRow),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: refreshRates,
            icon: const Icon(Icons.refresh),
            label: Text(tr('refresh')),
          ),
        ],
      ),
    );
  }

  Widget worldPage() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(
          tr('worldInfo'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (worldRates.isEmpty)
          Center(child: Text(tr('noRates'))),
        ...worldRates.map((rate) {
          final code = (rate['code'] ?? '').toString();
          final value = rate['afnPerUnit'];

          return Card(
            child: ListTile(
              leading: Text(
                flagFor(code),
                style: const TextStyle(fontSize: 27),
              ),
              title: Text(
                code,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                code == 'AFN' ? tr('afn') : '',
              ),
              trailing: Text(
                '${formatRate(value)} AFN',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget historyPage() {
    if (history.isEmpty) {
      return Center(child: Text(tr('noHistory')));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        final time = DateTime.tryParse(
          (item['time'] ?? '').toString(),
        );

        return Card(
          child: ListTile(
            leading: const Icon(Icons.history),
            title: Text(
              time?.toLocal().toString().substring(0, 16) ?? '',
            ),
            subtitle: Text(
              '${tr('bank')}: ${item['bank']}   '
              '${tr('sarai')}: ${item['sarai']}   '
              '${tr('khorasan')}: ${item['khorasan']}',
            ),
          ),
        );
      },
    );
  }

  Widget developerPage() {
    final hasPhoto =
        photoPath != null && File(photoPath!).existsSync();

    return Center(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(25),
        children: [
          CircleAvatar(
            radius: 65,
            backgroundImage:
                hasPhoto ? FileImage(File(photoPath!)) : null,
            child: hasPhoto
                ? null
                : const Icon(Icons.person, size: 65),
          ),
          const SizedBox(height: 15),
          Text(
            tr('developerName'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: choosePhoto,
            icon: const Icon(Icons.photo),
            label: Text(tr('choosePhoto')),
          ),
          if (hasPhoto)
            TextButton(
              onPressed: removePhoto,
              child: Text(tr('removePhoto')),
            ),
          const SizedBox(height: 20),
          const Divider(),
          Text(
            tr('appName'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'افغان اسعار',
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            tr('appName'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            DropdownButton<String>(
              value: language,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(
                  value: 'ps',
                  child: Text('پښتو'),
                ),
                DropdownMenuItem(
                  value: 'fa',
                  child: Text('دری'),
                ),
                DropdownMenuItem(
                  value: 'en',
                  child: Text('English'),
                ),
              ],
              onChanged: (value) {
                if (value != null) changeLanguage(value);
              },
            ),
            IconButton(
              onPressed: () {
                setState(() => darkMode = !darkMode);
                saveSettings();
              },
              icon: Icon(
                darkMode ? Icons.light_mode : Icons.dark_mode,
              ),
            ),
            IconButton(
              onPressed: refreshRates,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: IndexedStack(
          index: page,
          children: [
            marketsPage(),
            worldPage(),
            historyPage(),
            developerPage(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: page,
          onDestinationSelected: (value) {
            setState(() => page = value);
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
              icon: const Icon(Icons.history),
              label: tr('history'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person),
              label: tr('developer'),
            ),
          ],
        ),
      ),
    );
  }
}
