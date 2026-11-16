import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AfghaniExchange());
}

const teal = Color(0xFF12C99A);
const bg = Color(0xFF081525);
const card = Color(0xFF172A40);

class AfghaniExchange extends StatefulWidget {
  const AfghaniExchange({super.key});

  @override
  State<AfghaniExchange> createState() => _AfghaniExchangeState();
}

class _AfghaniExchangeState extends State<AfghaniExchange> {
  bool dark = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afghani Exchange',
      theme: ThemeData(
        useMaterial3: true,
        brightness: dark ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: dark ? bg : const Color(0xFFF3F7FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: teal,
          brightness: dark ? Brightness.dark : Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: HomePage(
        dark: dark,
        onTheme: () => setState(() => dark = !dark),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final bool dark;
  final VoidCallback onTheme;

  const HomePage({
    super.key,
    required this.dark,
    required this.onTheme,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;
  String language = 'ps';
  String from = 'AFN';
  String to = 'USD';

  double amount = 1000;
  double result = 0;

  bool loading = false;
  bool use24Hour = true;

  Map<String, dynamic> rates = {'AFN': 1.0};
  DateTime? lastUpdate;
  Timer? refreshTimer;
  Timer? clockTimer;
  DateTime now = DateTime.now();

  String? photoPath;

  final amountController = TextEditingController(text: '1000');

  final Map<String, String> flags = {
    'AFN': '🇦🇫', 'USD': '🇺🇸', 'EUR': '🇪🇺',
    'GBP': '🇬🇧', 'PKR': '🇵🇰', 'INR': '🇮🇳',
    'IRR': '🇮🇷', 'CNY': '🇨🇳', 'TRY': '🇹🇷',
    'AED': '🇦🇪', 'SAR': '🇸🇦', 'QAR': '🇶🇦',
    'KWD': '🇰🇼', 'JPY': '🇯🇵', 'CAD': '🇨🇦',
    'AUD': '🇦🇺', 'CHF': '🇨🇭', 'RUB': '🇷🇺',
    'BDT': '🇧🇩', 'LKR': '🇱🇰', 'NPR': '🇳🇵',
    'MYR': '🇲🇾', 'IDR': '🇮🇩', 'THB': '🇹🇭',
    'KRW': '🇰🇷', 'SEK': '🇸🇪', 'NOK': '🇳🇴',
    'DKK': '🇩🇰', 'NZD': '🇳🇿', 'SGD': '🇸🇬',
    'HKD': '🇭🇰', 'OMR': '🇴🇲', 'BHD': '🇧🇭',
    'EGP': '🇪🇬', 'IQD': '🇮🇶', 'KZT': '🇰🇿',
    'UZS': '🇺🇿', 'TJS': '🇹🇯', 'UAH': '🇺🇦',
    'BRL': '🇧🇷', 'ZAR': '🇿🇦', 'MXN': '🇲🇽',
  };

  final Map<String, String> names = {
    'AFN': 'Afghan Afghani',
    'USD': 'US Dollar',
    'EUR': 'Euro',
    'GBP': 'British Pound',
    'PKR': 'Pakistani Rupee',
    'INR': 'Indian Rupee',
    'IRR': 'Iranian Rial',
    'CNY': 'Chinese Yuan',
    'TRY': 'Turkish Lira',
    'AED': 'UAE Dirham',
    'SAR': 'Saudi Riyal',
    'QAR': 'Qatari Riyal',
    'KWD': 'Kuwaiti Dinar',
    'JPY': 'Japanese Yen',
    'CAD': 'Canadian Dollar',
    'AUD': 'Australian Dollar',
    'CHF': 'Swiss Franc',
    'RUB': 'Russian Ruble',
    'BDT': 'Bangladeshi Taka',
    'LKR': 'Sri Lankan Rupee',
    'NPR': 'Nepalese Rupee',
    'MYR': 'Malaysian Ringgit',
    'IDR': 'Indonesian Rupiah',
    'THB': 'Thai Baht',
    'KRW': 'South Korean Won',
    'SEK': 'Swedish Krona',
    'NOK': 'Norwegian Krone',
    'DKK': 'Danish Krone',
    'NZD': 'New Zealand Dollar',
    'SGD': 'Singapore Dollar',
    'HKD': 'Hong Kong Dollar',
    'OMR': 'Omani Rial',
    'BHD': 'Bahraini Dinar',
    'EGP': 'Egyptian Pound',
    'IQD': 'Iraqi Dinar',
    'KZT': 'Kazakhstani Tenge',
    'UZS': 'Uzbekistani Som',
    'TJS': 'Tajikistani Somoni',
    'UAH': 'Ukrainian Hryvnia',
    'BRL': 'Brazilian Real',
    'ZAR': 'South African Rand',
    'MXN': 'Mexican Peso',
  };

  final List<String> provinces = [
    'کابل','لغمان','ننګرهار','کونړ','نورستان','کاپیسا',
    'پروان','پنجشېر','بغلان','کندز','تخار','بدخشان',
    'بلخ','سمنګان','جوزجان','سرپل','فاریاب','بادغیس',
    'هرات','فراه','نیمروز','هلمند','کندهار','زابل',
    'ارزګان','دایکندي','غزني','پکتیا','پکتیکا','خوست',
    'لوګر','میدان وردګ','بامیان','غور'
  ];

  String tr(String ps, String dr, String en) {
    if (language == 'ps') return ps;
    if (language == 'dr') return dr;
    return en;
  }

  @override
  void initState() {
    super.initState();
    loadProfile();
    fetchRates();

    refreshTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => fetchRates(),
    );

    clockTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (mounted) setState(() => now = DateTime.now());
      },
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    clockTimer?.cancel();
    amountController.dispose();
    super.dispose();
  }

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      photoPath = prefs.getString('creator_photo');
      language = prefs.getString('app_language') ?? 'ps';
    });
  }

  Future<void> fetchRates() async {
    if (mounted) setState(() => loading = true);

    try {
      final response = await http.get(
        Uri.parse('https://open.er-api.com/v6/latest/AFN'),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception('Server error');
      }

      final data = jsonDecode(response.body);

      if (data['result'] != 'success') {
        throw Exception('Rate service unavailable');
      }

      final newRates = Map<String, dynamic>.from(data['rates']);

      if (!newRates.containsKey('AFN')) {
        newRates['AFN'] = 1.0;
      }

      if (!mounted) return;

      setState(() {
        rates = newRates;
        lastUpdate = DateTime.now();
        loading = false;
        calculate();
      });
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  void calculate() {
    final a = double.tryParse(amountController.text) ?? 0;
    final fromRate = (rates[from] as num?)?.toDouble();
    final toRate = (rates[to] as num?)?.toDouble();

    if (fromRate == null || toRate == null || fromRate == 0) {
      result = 0;
      return;
    }

    setState(() {
      amount = a;
      result = (a / fromRate) * toRate;
    });
  }

  String clockText() {
    final h = use24Hour
        ? now.hour.toString().padLeft(2, '0')
        : ((now.hour % 12 == 0 ? 12 : now.hour % 12))
            .toString().padLeft(2, '0');

    final m = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');

    return use24Hour
        ? '$h:$m:$s'
        : '$h:$m:$s ${now.hour >= 12 ? 'PM' : 'AM'}';
  }

  Future<void> chooseCurrency(bool isFrom) async {
    final currencies = rates.keys.toList()..sort();

    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * .75,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  'Select Currency',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: currencies.length,
                  itemBuilder: (context, i) {
                    final code = currencies[i];
                    return ListTile(
                      leading: Text(flags[code] ?? '🌐',
                          style: const TextStyle(fontSize: 25)),
                      title: Text(code),
                      subtitle: Text(names[code] ?? code),
                      onTap: () => Navigator.pop(context, code),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        if (isFrom) {
          from = selected;
        } else {
          to = selected;
        }
        calculate();
      });
    }
  }

  Widget currencyCard(String code, bool isFrom) {
    return Expanded(
      child: InkWell(
        onTap: () => chooseCurrency(isFrom),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: widget.dark ? card : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: teal.withOpacity(.25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isFrom
                    ? tr('له','له','From')
                    : tr('ته','به','To'),
                style: const TextStyle(color: teal),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(flags[code] ?? '🌐',
                      style: const TextStyle(fontSize: 27)),
                  const SizedBox(width: 8),
                  Text(code,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  const Spacer(),
                  const Icon(Icons.keyboard_arrow_down, color: teal),
                ],
              ),
              Text(
                names[code] ?? code,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget converter() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF087F70), Color(0xFF123D59)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text('🇦🇫', style: TextStyle(fontSize: 32)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Afghani Exchange',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                tr('د نړۍ د اسعارو تبادله',
                    'تبدیل اسعار جهان',
                    'World Currency Exchange'),
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              const Text(
                '🌍 150+ Currencies',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time,
                      color: Colors.white70, size: 18),
                  const SizedBox(width: 8),
                  Text(clockText(),
                      style: const TextStyle(color: Colors.white)),
                  const Spacer(),
                  TextButton(
                    onPressed: () =>
                        setState(() => use24Hour = !use24Hour),
                    child: Text(
                      use24Hour ? '12H' : '24H',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text(
          tr('د پیسو اندازه','مقدار پول','Amount'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => calculate(),
          decoration: InputDecoration(
            hintText: '1000',
            prefixIcon: const Icon(Icons.payments, color: teal),
            filled: true,
            fillColor: widget.dark ? card : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            currencyCard(from, true),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: IconButton.filled(
                style: IconButton.styleFrom(backgroundColor: teal),
                onPressed: () {
                  setState(() {
                    final old = from;
                    from = to;
                    to = old;
                    calculate();
                  });
                },
                icon: const Icon(Icons.swap_horiz, color: Colors.white),
              ),
            ),
            currencyCard(to, false),
          ],
        ),
        const SizedBox(height: 22),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF087F70), Color(0xFF123D59)],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              Text(
                tr('د تبادلې نتیجه','نتیجه تبدیل','Conversion Result'),
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              Text(
                '${result.toStringAsFixed(2)} $to',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${amountController.text} $from',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: widget.dark ? card : Colors.white,
          child: ListTile(
            leading: const Icon(Icons.update, color: teal),
            title: Text(
              lastUpdate == null
                  ? tr('د نرخونو انتظار','در انتظار نرخ','Waiting for rates')
                  : tr('وروستی تازه کول','آخرین بروزرسانی','Last update'),
            ),
            subtitle: Text(
              lastUpdate?.toLocal().toString().substring(0, 19) ?? '—',
            ),
            trailing: IconButton(
              onPressed: loading ? null : fetchRates,
              icon: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh, color: teal),
            ),
          ),
        ),
        if (rates.length <= 1)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'د نرخونو ترلاسه کولو لپاره انټرنېټ ته اړتیا ده.',
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 20),
        const Text(
          '🇦🇫 Afghanistan',
          textAlign: TextAlign.center,
          style: TextStyle(color: teal, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Made by ABDULLAH ALOKOZAI',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget provincesPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '🇦🇫 د افغانستان ۳۴ ولایتونه',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'د هر ولایت لپاره د هېواد ملي مرجع نرخ ښودل کېږي.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 12),
        ...provinces.map((p) => Card(
          color: widget.dark ? card : Colors.white,
          child: ListTile(
            leading: const Text('🇦🇫', style: TextStyle(fontSize: 25)),
            title: Text(p),
            subtitle: Text('AFN → $to'),
            trailing: const Icon(Icons.arrow_forward_ios,
                size: 16, color: teal),
            onTap: () {
              setState(() => tab = 0);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$p — ملي مرجع نرخ')),
              );
            },
          ),
        )),
      ],
    );
  }

  Widget historyPage() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text('🇦🇫 افغانستان او افغانۍ',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
        const SizedBox(height: 18),
        const Text(
          'د افغانستان پیسې افغانۍ نومېږي او نړیوال کوډ یې AFN دی. '
          'افغانۍ د افغانستان رسمي ملي اسعار دي. '
          'د افغانستان بانک د هېواد د پیسو او بانکي نظام په اداره کې مهم رول لري.',
          style: TextStyle(fontSize: 16, height: 1.8),
        ),
        const SizedBox(height: 20),
        const Card(
          color: card,
          child: ListTile(
            leading: Text('🇦🇫', style: TextStyle(fontSize: 35)),
            title: Text('Afghan Afghani'),
            subtitle: Text('Currency code: AFN'),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'یادونه: د اسعارو نرخونه د نړیوالې مرجع سرچینې له مخې دي؛ '
          'د صرافۍ بازار نرخونه ممکن توپیر ولري.',
          style: TextStyle(color: Colors.orange),
        ),
      ],
    );
  }

  Future<void> choosePhoto() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return;

    final directory = await getApplicationDocumentsDirectory();
    final saved = await File(image.path).copy(
      '${directory.path}/creator_photo.jpg',
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('creator_photo', saved.path);

    if (mounted) setState(() => photoPath = saved.path);
  }

  Widget profilePage() {
    final links = {
      'Facebook': 'https://facebook.com/',
      'TikTok': 'https://tiktok.com/',
      'WhatsApp': 'https://whatsapp.com/',
      'YouTube': 'https://youtube.com/',
      'Instagram': 'https://instagram.com/',
      'Telegram': 'https://telegram.org/',
      'Website': 'https://example.com/',
    };

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 20),
        Center(
          child: GestureDetector(
            onTap: choosePhoto,
            child: CircleAvatar(
              radius: 62,
              backgroundColor: teal,
              backgroundImage: photoPath != null &&
                      File(photoPath!).existsSync()
                  ? FileImage(File(photoPath!))
                  : null,
              child: photoPath == null
                  ? const Icon(Icons.person, size: 60, color: Colors.white)
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: choosePhoto,
          icon: const Icon(Icons.photo_library),
          label: const Text('Change Creator Photo'),
        ),
        const Center(
          child: Text(
            'ABDULLAH ALOKOZAI',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
        ),
        const Center(
          child: Text('Creator of Afghani Exchange',
              style: TextStyle(color: teal)),
        ),
        const SizedBox(height: 25),
        SwitchListTile(
          title: const Text('Dark Mode'),
          secondary: const Icon(Icons.dark_mode, color: teal),
          value: widget.dark,
          onChanged: (_) => widget.onTheme(),
        ),
        ListTile(
          leading: const Icon(Icons.language, color: teal),
          title: const Text('Language / ژبه / زبان'),
          trailing: DropdownButton<String>(
            value: language,
            items: const [
              DropdownMenuItem(value: 'ps', child: Text('پښتو')),
              DropdownMenuItem(value: 'dr', child: Text('دری')),
              DropdownMenuItem(value: 'en', child: Text('English')),
            ],
            onChanged: (v) async {
              if (v == null) return;
              setState(() => language = v);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('app_language', v);
            },
          ),
        ),
        const Divider(),
        const Text('Social Media',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ...links.entries.map((entry) => ListTile(
          leading: const Icon(Icons.link, color: teal),
          title: Text(entry.key),
          trailing: const Icon(Icons.open_in_new),
          onTap: () async {
            final uri = Uri.parse(entry.value);
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          },
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      converter(),
      provincesPage(),
      historyPage(),
      profilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Afghani Exchange',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: const Padding(
          padding: EdgeInsets.all(10),
          child: Center(child: Text('🇦🇫', style: TextStyle(fontSize: 25))),
        ),
        actions: [
          IconButton(
            onPressed: fetchRates,
            icon: const Icon(Icons.refresh, color: teal),
          ),
        ],
      ),
      body: IndexedStack(
        index: tab,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.currency_exchange),
            label: tr('تبادله','تبدیل','Exchange'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.map),
            label: tr('ولایتونه','ولایات','Provinces'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.history),
            label: tr('تاریخچه','تاریخچه','History'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person),
            label: tr('پروفایل','پروفایل','Profile'),
          ),
        ],
      ),
    );
  }
}
