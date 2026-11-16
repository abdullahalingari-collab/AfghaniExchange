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

const Color appGreen = Color(0xFF13A875);
const String creatorName = 'ABDULLAH ALOKOZAI';

class AfghaniExchange extends StatefulWidget {
  const AfghaniExchange({super.key});

  @override
  State<AfghaniExchange> createState() => _AfghaniExchangeState();
}

class _AfghaniExchangeState extends State<AfghaniExchange> {
  bool darkMode = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afghani Exchange',
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: appGreen,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7F6),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: appGreen,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF101820),
      ),
      home: HomePage(
        darkMode: darkMode,
        onThemeChanged: (value) => setState(() => darkMode = value),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final bool darkMode;
  final ValueChanged<bool> onThemeChanged;

  const HomePage({
    super.key,
    required this.darkMode,
    required this.onThemeChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController amountController =
      TextEditingController(text: '1000');

  final List<String> provinces = const [
    'کابل', 'هرات', 'کندهار', 'بلخ', 'ننګرهار', 'لغمان',
    'کنړ', 'نورستان', 'بدخشان', 'تخار', 'کندز', 'بغلان',
    'سمنګان', 'جوزجان', 'فاریاب', 'سرپل', 'غور', 'بادغیس',
    'فراه', 'نیمروز', 'هلمند', 'ارزګان', 'زابل', 'غزني',
    'پکتیا', 'پکتیکا', 'خوست', 'لوګر', 'میدان وردګ',
    'بامیان', 'دایکندي', 'پروان', 'کاپیسا', 'پنجشیر',
  ];

  final Map<String, String> flags = {
    'AFN': '🇦🇫', 'USD': '🇺🇸', 'EUR': '🇪🇺',
    'GBP': '🇬🇧', 'PKR': '🇵🇰', 'INR': '🇮🇳',
    'IRR': '🇮🇷', 'AED': '🇦🇪', 'SAR': '🇸🇦',
    'TRY': '🇹🇷', 'CNY': '🇨🇳', 'JPY': '🇯🇵',
    'CAD': '🇨🇦', 'AUD': '🇦🇺', 'CHF': '🇨🇭',
    'RUB': '🇷🇺', 'QAR': '🇶🇦', 'KWD': '🇰🇼',
    'BDT': '🇧🇩', 'LKR': '🇱🇰', 'NPR': '🇳🇵',
    'MYR': '🇲🇾', 'THB': '🇹🇭', 'SGD': '🇸🇬',
    'SEK': '🇸🇪', 'NOK': '🇳🇴', 'DKK': '🇩🇰',
    'NZD': '🇳🇿', 'ZAR': '🇿🇦', 'EGP': '🇪🇬',
    'IQD': '🇮🇶', 'OMR': '🇴🇲', 'BHD': '🇧🇭',
    'KRW': '🇰🇷', 'HKD': '🇭🇰', 'BRL': '🇧🇷',
    'MXN': '🇲🇽', 'UAH': '🇺🇦', 'KZT': '🇰🇿',
  };

  final Map<String, String> currencyNames = {
    'AFN': 'افغانۍ - افغانستان',
    'USD': 'امریکایي ډالر',
    'EUR': 'یورو',
    'GBP': 'برتانوي پونډ',
    'PKR': 'پاکستانۍ روپۍ',
    'INR': 'هندي روپۍ',
    'IRR': 'ایراني تومان/ریال',
    'AED': 'اماراتي درهم',
    'SAR': 'سعودي ریال',
    'TRY': 'ترکي لیره',
    'CNY': 'چینایي یوان',
    'JPY': 'جاپاني ین',
    'CAD': 'کاناډایي ډالر',
    'AUD': 'اسټرالیایي ډالر',
    'CHF': 'سویسي فرانک',
    'RUB': 'روسي روبل',
    'QAR': 'قطري ریال',
    'KWD': 'کویتي دینار',
    'BDT': 'بنګله دېشي ټکه',
    'LKR': 'سریلانکایي روپۍ',
    'NPR': 'نېپالي روپۍ',
    'MYR': 'مالیزیايي رینګټ',
    'THB': 'تایلنډي باټ',
    'SGD': 'سنګاپوري ډالر',
    'SEK': 'سویډني کرونا',
    'NOK': 'ناروېژي کرونا',
    'DKK': 'ډنمارکي کرونا',
    'NZD': 'نیوزیلنډي ډالر',
    'ZAR': 'د سویلي افریقا رنډ',
    'EGP': 'مصري پونډ',
    'IQD': 'عراقي دینار',
    'OMR': 'عماني ریال',
    'BHD': 'بحریني دینار',
    'KRW': 'کوریایي وان',
    'HKD': 'هانګ کانګي ډالر',
    'BRL': 'برازیلي ریال',
    'MXN': 'مکسیکويي پیسو',
    'UAH': 'اوکرایني هریونیا',
    'KZT': 'قزاقستاني ټینګ',
  };

  // خپل شخصي لینکونه وروسته دلته ولیکئ.
  // لینکونه د بېلګې په توګه تش پرېښودل شوي دي.
  final Map<String, String> socialLinks = {
    'Facebook': '',
    'TikTok': '',
    'WhatsApp': '',
    'YouTube': '',
    'Instagram': '',
    'Telegram': '',
    'Website': '',
    'Other App 1': '',
    'Other App 2': '',
    'Other App 3': '',
  };

  Map<String, double> rates = {'AFN': 1};
  List<String> currencies = ['AFN', 'USD', 'EUR', 'PKR', 'INR'];
  String fromCurrency = 'AFN';
  String toCurrency = 'USD';
  String selectedProvince = 'کابل';
  String? photoPath;
  String lastUpdated = 'لا تر اوسه تازه شوی نه دی';
  String clock = '';
  bool loading = false;
  String errorMessage = '';
  int pageIndex = 0;
  Timer? refreshTimer;
  Timer? clockTimer;

  double get convertedAmount {
    final amount = double.tryParse(amountController.text) ?? 0;
    final fromRate = rates[fromCurrency] ?? 1;
    final toRate = rates[toCurrency] ?? 1;
    if (fromRate == 0) return 0;
    return amount / fromRate * toRate;
  }

  @override
  void initState() {
    super.initState();
    loadSavedPhoto();
    fetchRates();
    updateClock();
    clockTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => updateClock(),
    );
    refreshTimer = Timer.periodic(
      const Duration(minutes: 10),
      (_) => fetchRates(),
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    clockTimer?.cancel();
    amountController.dispose();
    super.dispose();
  }

  void updateClock() {
    if (!mounted) return;
    final now = DateTime.now();
    setState(() {
      clock =
          '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}'
          '   ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    });
  }

  Future<void> fetchRates() async {
    if (loading) return;
    setState(() {
      loading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://open.er-api.com/v6/latest/AFN'),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception('د نرخونو سرچینه اوس ځواب نه ورکوي');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['result'] != 'success') {
        throw Exception('د نرخونو ترلاسه کول بریالي نه شول');
      }

      final rawRates = data['rates'] as Map<String, dynamic>;
      final newRates = <String, double>{'AFN': 1};

      for (final entry in rawRates.entries) {
        final value = entry.value;
        if (value is num && value > 0) {
          newRates[entry.key] = value.toDouble();
        }
      }

      if (!mounted) return;
      setState(() {
        rates = newRates;
        currencies = newRates.keys.toList()..sort();
        if (!currencies.contains(fromCurrency)) fromCurrency = 'AFN';
        if (!currencies.contains(toCurrency)) toCurrency = 'USD';
        lastUpdated = DateTime.now().toString().substring(0, 16);
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'د نرخونو په ترلاسه کولو کې ستونزه ده. انټرنېټ وګورئ.';
        });
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> loadSavedPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('creator_photo');
    if (saved != null && File(saved).existsSync() && mounted) {
      setState(() => photoPath = saved);
    }
  }

  Future<void> choosePhoto() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image == null) return;

      final directory = await getApplicationDocumentsDirectory();
      final newPath = '${directory.path}/creator_photo.jpg';
      await File(image.path).copy(newPath);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('creator_photo', newPath);

      if (mounted) setState(() => photoPath = newPath);
    } catch (_) {
      showMessage('عکس نه شو ساتل کېدای');
    }
  }

  Future<void> openSocial(String name) async {
    final link = socialLinks[name]?.trim() ?? '';
    if (link.isEmpty) {
      showMessage('د $name لینک لا نه دی اضافه شوی');
      return;
    }

    final uri = Uri.tryParse(link);
    if (uri == null || !uri.hasScheme) {
      showMessage('د $name لینک سم نه دی');
      return;
    }

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!opened) showMessage('دا لینک نه پرانیستل کېږي');
    } catch (_) {
      showMessage('د لینک په خلاصولو کې ستونزه ده');
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String currencyTitle(String code) {
    return '${flags[code] ?? '🌐'}  ${currencyNames[code] ?? code} ($code)';
  }

  void swapCurrencies() {
    setState(() {
      final oldFrom = fromCurrency;
      fromCurrency = toCurrency;
      toCurrency = oldFrom;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      buildConverterPage(),
      buildProvincesPage(),
      buildHistoryPage(),
      buildProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Afghani Exchange',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Dark Mode',
            onPressed: () => widget.onThemeChanged(!widget.darkMode),
            icon: Icon(
              widget.darkMode ? Icons.light_mode : Icons.dark_mode,
            ),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: fetchRates,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            buildTopBanner(),
            Expanded(child: pages[pageIndex]),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: pageIndex,
        onDestinationSelected: (index) {
          setState(() => pageIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.currency_exchange),
            label: 'تبادله',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_city),
            label: 'ولایتونه',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'تاریخ',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'زما پېژندنه',
          ),
        ],
      ),
    );
  }

  Widget buildTopBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(14, 4, 14, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF087C54), Color(0xFF18B77E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: appGreen.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🇦🇫', style: TextStyle(fontSize: 35)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'د نړۍ د اسعارو تبادله',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  clock,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.public, color: Colors.white, size: 30),
        ],
      ),
    );
  }

  Widget buildConverterPage() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 5, 16, 22),
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'د اسعارو حساب',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 18),
                const Text('څومره پیسې؟'),
                const SizedBox(height: 7),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'اندازه ولیکئ',
                    prefixIcon: const Icon(Icons.money),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                const Text('له کوم اسعارو څخه؟'),
                const SizedBox(height: 7),
                currencyDropdown(fromCurrency, (value) {
                  setState(() => fromCurrency = value!);
                }),
                Center(
                  child: IconButton.filled(
                    onPressed: swapCurrencies,
                    icon: const Icon(Icons.swap_vert),
                    tooltip: 'اسعار بدل کړئ',
                  ),
                ),
                const Text('کوم اسعارو ته؟'),
                const SizedBox(height: 7),
                currencyDropdown(toCurrency, (value) {
                  setState(() => toCurrency = value!);
                }),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: appGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Column(
                    children: [
                      const Text('د تبادلې نتیجه'),
                      const SizedBox(height: 8),
                      Text(
                        '${convertedAmount.toStringAsFixed(4)} $toCurrency',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: appGreen,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: fetchRates,
                  icon: const Icon(Icons.refresh),
                  label: const Text('نرخونه تازه کړه'),
                ),
                const SizedBox(height: 8),
                Text(
                  loading
                      ? 'نرخونه ترلاسه کېږي...'
                      : 'وروستی تازه کېدل: $lastUpdated',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: ListTile(
            leading: const Icon(Icons.timer, color: appGreen),
            title: const Text('اتومات تازه کېدل'),
            subtitle: const Text('هر ۱۰ دقیقې د نرخونو د تازه کولو هڅه کېږي'),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.info_outline, color: appGreen),
            title: const Text('د نرخ سرچینه'),
            subtitle: const Text(
              'نړیوال مرجع نرخونه؛ د محلي صرافیو ځانګړي نرخونه نه دي',
            ),
          ),
        ),
      ],
    );
  }

  Widget currencyDropdown(
    String value,
    ValueChanged<String?> onChanged,
  ) {
    final safeValue = currencies.contains(value) ? value : currencies.first;
    return DropdownButtonFormField<String>(
      value: safeValue,
      isExpanded: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
      ),
      items: currencies.map((code) {
        return DropdownMenuItem(
          value: code,
          child: Text(
            currencyTitle(code),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget buildProvincesPage() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const Text(
          'د افغانستان ۳۴ ولایتونه',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'ولایت وټاکئ او د اسعارو تبادله وګورئ',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        ...provinces.asMap().entries.map((entry) {
          final index = entry.key;
          final province = entry.value;
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: appGreen.withOpacity(0.13),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: appGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(province),
              subtitle: const Text('د افغانستان ملي مرجع نرخ'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                setState(() => selectedProvince = province);
                showProvinceRates(province);
              },
            ),
          );
        }),
      ],
    );
  }

  void showProvinceRates(String province) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.78,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  '$province - د اسعارو تبادله',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Text(
                'دا ملي مرجع نرخ دی، د دې ولایت ځانګړی بازار نرخ نه دی.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: currencies.length,
                  itemBuilder: (context, index) {
                    final code = currencies[index];
                    final rate = rates[code] ?? 0;
                    return ListTile(
                      leading: Text(
                        flags[code] ?? '🌐',
                        style: const TextStyle(fontSize: 25),
                      ),
                      title: Text(currencyTitle(code)),
                      subtitle: Text(
                        '۱ AFN = ${rate.toStringAsFixed(6)} $code',
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildHistoryPage() {
    final history = <Map<String, String>>[
      {
        'title': 'افغانۍ - افغانستان',
        'text':
            'افغانۍ په ۱۹۲۵ کال کې د افغانستان د ملي پیسو په توګه معرفي شوه. دا د افغانستان رسمي اسعار دي.',
      },
      {
        'title': 'امریکایي ډالر - USD',
        'text':
            'امریکایي ډالر په ۱۷۹۲ کال کې د متحده ایالاتو د پیسو د واحد په توګه رامنځته شو.',
      },
      {
        'title': 'برتانوي پونډ - GBP',
        'text':
            'پونډ د نړۍ له پخوانیو فعالو اسعارو څخه دی او د برتانیا رسمي پیسې دي.',
      },
      {
        'title': 'یورو - EUR',
        'text':
            'یورو په ۱۹۹۹ کال کې د حسابي پیسو په توګه پیل شو او په ۲۰۰۲ کال کې بانکنوټونه او سکې عامې شوې.',
      },
      {
        'title': 'پاکستانۍ روپۍ - PKR',
        'text':
            'پاکستانۍ روپۍ د پاکستان رسمي اسعار دي او په ۱۹۴۸ کال کې معرفي شوې.',
      },
      {
        'title': 'هندي روپۍ - INR',
        'text':
            'هندي روپۍ د هند رسمي اسعار دي او اوږد تاریخي شالید لري.',
      },
      {
        'title': 'چینایي یوان - CNY',
        'text':
            'یوان د چین د پیسو واحد دی او د چین د خلکو جمهوریت رسمي اسعار ګڼل کېږي.',
      },
      {
        'title': 'جاپاني ین - JPY',
        'text':
            'ین په ۱۸۷۱ کال کې د جاپان د پیسو په توګه معرفي شو.',
      },
      {
        'title': 'سعودي ریال - SAR',
        'text':
            'سعودي ریال د سعودي عربستان رسمي اسعار دي.',
      },
      {
        'title': 'اماراتي درهم - AED',
        'text':
            'درهم په ۱۹۷۳ کال کې د متحده عربي اماراتو رسمي اسعار شو.',
      },
      {
        'title': 'ایراني ریال - IRR',
        'text':
            'ایراني ریال د ایران رسمي اسعار دي؛ په ورځني بازار کې تومان هم ډېر کارېږي.',
      },
      {
        'title': 'ترکي لیره - TRY',
        'text':
            'ترکي لیره د ترکیې رسمي اسعار دي.',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const Text(
          'د افغانستان او نړۍ د پیسو تاریخ',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          color: appGreen.withOpacity(0.12),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🇦🇫 د افغانستان تاریخ',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'افغانستان په ۱۹۱۹ کال کې د امان الله خان په واکمنۍ کې خپل بشپړ خپلواک بهرنی سیاست ترلاسه کړ. افغانۍ په ۱۹۲۵ کال کې د ملي اسعارو په توګه معرفي شوه.',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        ...history.map((item) {
          return Card(
            child: ExpansionTile(
              leading: const Icon(Icons.monetization_on, color: appGreen),
              title: Text(
                item['title']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(item['text']!),
                ),
              ],
            ),
          );
        }),
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            'یادونه: د هر اسعارو بشپړ تاریخي معلومات په راتلونکو نسخو کې پراخېدای شي.',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget buildProfilePage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                GestureDetector(
                  onTap: choosePhoto,
                  child: CircleAvatar(
                    radius: 58,
                    backgroundColor: appGreen.withOpacity(0.2),
                    backgroundImage: photoPath != null
                        ? FileImage(File(photoPath!))
                        : null,
                    child: photoPath == null
                        ? const Icon(
                            Icons.add_a_photo,
                            size: 42,
                            color: appGreen,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  creatorName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: appGreen,
                  ),
                ),
                const SizedBox(height: 6),
                const Text('د Afghani Exchange جوړونکی'),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: choosePhoto,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('خپل عکس بدل کړئ'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'زما ټولنیزې شبکې او اپونه',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...socialLinks.keys.map((name) {
          final icons = <String, IconData>{
            'Facebook': Icons.facebook,
            'TikTok': Icons.music_note,
            'WhatsApp': Icons.chat,
            'YouTube': Icons.play_circle_fill,
            'Instagram': Icons.camera_alt,
            'Telegram': Icons.send,
            'Website': Icons.language,
            'Other App 1': Icons.apps,
            'Other App 2': Icons.apps,
            'Other App 3': Icons.apps,
          };
          return Card(
            child: ListTile(
              leading: Icon(
                icons[name] ?? Icons.link,
                color: appGreen,
                size: 27,
              ),
              title: Text(name),
              subtitle: Text(
                socialLinks[name]!.isEmpty ? 'لینک وروسته اضافه کېږي' : 'لینک چمتو دی',
              ),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => openSocial(name),
            ),
          );
        }),
        const SizedBox(height: 12),
        SwitchListTile(
          secondary: const Icon(Icons.dark_mode),
          title: const Text('تور رنګ / Dark Mode'),
          value: widget.darkMode,
          onChanged: widget.onThemeChanged,
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'Afghani Exchange  •  $creatorName',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}
