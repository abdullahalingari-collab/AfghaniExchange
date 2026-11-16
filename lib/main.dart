import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

void main() {
  runApp(const AfghaniExchange());
}

class AfghaniExchange extends StatelessWidget {
  const AfghaniExchange({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afghani Exchange',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF087E65),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF087E65),
          brightness: Brightness.dark,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic> rates = {};
  bool loading = true;
  String error = '';
  String language = 'ps';
  bool dark = false;
  int tab = 0;

  String from = 'USD';
  String to = 'AFN';
  double amount = 1;

  final TextEditingController amountController =
      TextEditingController(text: '1');

  final List<String> history = [];
  final Set<String> favorites = {'USD', 'EUR', 'PKR'};

  final List<String> provinces = [
    'کابل', 'کندهار', 'هرات', 'بلخ', 'ننګرهار',
    'لغمان', 'کنړ', 'نورستان', 'پنجشېر', 'پروان',
    'کاپیسا', 'بغلان', 'کندز', 'تخار', 'بدخشان',
    'سمنګان', 'سرپل', 'جوزجان', 'فاریاب', 'بادغیس',
    'غور', 'دایکندی', 'بامیان', 'میدان وردګ',
    'لوګر', 'پکتیا', 'پکتیکا', 'خوست', 'غزني',
    'ارزګان', 'زابل', 'هلمند', 'فراه', 'نیمروز'
  ];

  final Map<String, String> flags = {
    'AFN': '🇦🇫', 'USD': '🇺🇸', 'EUR': '🇪🇺',
    'GBP': '🇬🇧', 'PKR': '🇵🇰', 'INR': '🇮🇳',
    'IRR': '🇮🇷', 'CNY': '🇨🇳', 'AED': '🇦🇪',
    'SAR': '🇸🇦', 'TRY': '🇹🇷', 'JPY': '🇯🇵',
    'CAD': '🇨🇦', 'AUD': '🇦🇺', 'CHF': '🇨🇭',
    'RUB': '🇷🇺', 'QAR': '🇶🇦', 'KWD': '🇰🇼',
    'OMR': '🇴🇲', 'BDT': '🇧🇩', 'NPR': '🇳🇵',
    'MYR': '🇲🇾', 'THB': '🇹🇭', 'SGD': '🇸🇬',
    'NZD': '🇳🇿', 'SEK': '🇸🇪', 'NOK': '🇳🇴',
    'DKK': '🇩🇰', 'ZAR': '🇿🇦', 'BRL': '🇧🇷',
    'KRW': '🇰🇷', 'IDR': '🇮🇩', 'LKR': '🇱🇰',
    'EGP': '🇪🇬', 'IQD': '🇮🇶', 'HKD': '🇭🇰',
    'UAH': '🇺🇦', 'PLN': '🇵🇱', 'MXN': '🇲🇽',
    'ARS': '🇦🇷', 'BHD': '🇧🇭', 'JOD': '🇯🇴',
    'ILS': '🇮🇱', 'KES': '🇰🇪', 'NGN': '🇳🇬',
    'GEL': '🇬🇪', 'AZN': '🇦🇿', 'UZS': '🇺🇿',
    'KZT': '🇰🇿', 'TJS': '🇹🇯', 'TMT': '🇹🇲',
  };

  final Map<String, Map<String, String>> countryNames = {
    'AFN': {'ps': 'افغانستان', 'fa': 'افغانستان', 'en': 'Afghanistan'},
    'USD': {'ps': 'امریکا', 'fa': 'آمریکا', 'en': 'United States'},
    'EUR': {'ps': 'اروپايي ټولنه', 'fa': 'اتحادیه اروپا', 'en': 'European Union'},
    'GBP': {'ps': 'بریتانیا', 'fa': 'بریتانیا', 'en': 'United Kingdom'},
    'PKR': {'ps': 'پاکستان', 'fa': 'پاکستان', 'en': 'Pakistan'},
    'INR': {'ps': 'هند', 'fa': 'هند', 'en': 'India'},
    'IRR': {'ps': 'ایران', 'fa': 'ایران', 'en': 'Iran'},
    'CNY': {'ps': 'چین', 'fa': 'چین', 'en': 'China'},
    'AED': {'ps': 'متحده عربي امارات', 'fa': 'امارات متحده عربی', 'en': 'United Arab Emirates'},
    'SAR': {'ps': 'سعودي عربستان', 'fa': 'عربستان سعودی', 'en': 'Saudi Arabia'},
    'TRY': {'ps': 'ترکیه', 'fa': 'ترکیه', 'en': 'Turkey'},
    'JPY': {'ps': 'جاپان', 'fa': 'جاپان', 'en': 'Japan'},
    'CAD': {'ps': 'کاناډا', 'fa': 'کانادا', 'en': 'Canada'},
    'AUD': {'ps': 'استرالیا', 'fa': 'استرالیا', 'en': 'Australia'},
    'CHF': {'ps': 'سویس', 'fa': 'سوئیس', 'en': 'Switzerland'},
    'RUB': {'ps': 'روسیه', 'fa': 'روسیه', 'en': 'Russia'},
    'QAR': {'ps': 'قطر', 'fa': 'قطر', 'en': 'Qatar'},
    'KWD': {'ps': 'کویټ', 'fa': 'کویت', 'en': 'Kuwait'},
    'OMR': {'ps': 'عمان', 'fa': 'عمان', 'en': 'Oman'},
    'BDT': {'ps': 'بنګله دېش', 'fa': 'بنگلادش', 'en': 'Bangladesh'},
    'NPR': {'ps': 'نیپال', 'fa': 'نپال', 'en': 'Nepal'},
    'MYR': {'ps': 'مالیزیا', 'fa': 'مالزی', 'en': 'Malaysia'},
    'THB': {'ps': 'تایلنډ', 'fa': 'تایلند', 'en': 'Thailand'},
    'SGD': {'ps': 'سنګاپور', 'fa': 'سنگاپور', 'en': 'Singapore'},
    'NZD': {'ps': 'نیوزیلنډ', 'fa': 'نیوزیلند', 'en': 'New Zealand'},
    'SEK': {'ps': 'سویډن', 'fa': 'سوئد', 'en': 'Sweden'},
    'NOK': {'ps': 'ناروې', 'fa': 'نروژ', 'en': 'Norway'},
    'DKK': {'ps': 'ډنمارک', 'fa': 'دانمارک', 'en': 'Denmark'},
    'ZAR': {'ps': 'سویلي افریقا', 'fa': 'آفریقای جنوبی', 'en': 'South Africa'},
    'BRL': {'ps': 'برازیل', 'fa': 'برزیل', 'en': 'Brazil'},
    'KRW': {'ps': 'جنوبي کوریا', 'fa': 'کوریای جنوبی', 'en': 'South Korea'},
    'IDR': {'ps': 'اندونیزیا', 'fa': 'اندونزی', 'en': 'Indonesia'},
    'LKR': {'ps': 'سریلانکا', 'fa': 'سریلانکا', 'en': 'Sri Lanka'},
    'EGP': {'ps': 'مصر', 'fa': 'مصر', 'en': 'Egypt'},
    'IQD': {'ps': 'عراق', 'fa': 'عراق', 'en': 'Iraq'},
    'HKD': {'ps': 'هانګ کانګ', 'fa': 'هنگ کنگ', 'en': 'Hong Kong'},
    'UAH': {'ps': 'اوکراین', 'fa': 'اوکراین', 'en': 'Ukraine'},
    'PLN': {'ps': 'پولنډ', 'fa': 'لهستان', 'en': 'Poland'},
    'MXN': {'ps': 'مکسیکو', 'fa': 'مکزیک', 'en': 'Mexico'},
    'ARS': {'ps': 'ارجنټاین', 'fa': 'آرژانتین', 'en': 'Argentina'},
    'BHD': {'ps': 'بحرین', 'fa': 'بحرین', 'en': 'Bahrain'},
    'JOD': {'ps': 'اردن', 'fa': 'اردن', 'en': 'Jordan'},
    'ILS': {'ps': 'اسرائیل', 'fa': 'اسرائیل', 'en': 'Israel'},
    'KES': {'ps': 'کینیا', 'fa': 'کنیا', 'en': 'Kenya'},
    'NGN': {'ps': 'نایجیریا', 'fa': 'نیجریه', 'en': 'Nigeria'},
    'GEL': {'ps': 'ګرجستان', 'fa': 'گرجستان', 'en': 'Georgia'},
    'AZN': {'ps': 'اذربایجان', 'fa': 'آذربایجان', 'en': 'Azerbaijan'},
    'UZS': {'ps': 'ازبکستان', 'fa': 'ازبکستان', 'en': 'Uzbekistan'},
    'KZT': {'ps': 'قزاقستان', 'fa': 'قزاقستان', 'en': 'Kazakhstan'},
    'TJS': {'ps': 'تاجکستان', 'fa': 'تاجیکستان', 'en': 'Tajikistan'},
    'TMT': {'ps': 'ترکمنستان', 'fa': 'ترکمنستان', 'en': 'Turkmenistan'},
  };

  String tr(String ps, String fa, String en) {
    if (language == 'fa') return fa;
    if (language == 'en') return en;
    return ps;
  }

  @override
  void initState() {
    super.initState();
    fetchRates();
  }

  Future<void> fetchRates() async {
    setState(() {
      loading = true;
      error = '';
    });

    try {
      final client = HttpClient();
      final request = await client.getUrl(
        Uri.parse('https://open.er-api.com/v6/latest/AFN'),
      );
      request.headers.set('Accept', 'application/json');
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      client.close();

      final data = jsonDecode(body);
      if (response.statusCode == 200 &&
          data['result'] == 'success' &&
          data['rates'] is Map) {
        setState(() {
          rates = Map<String, dynamic>.from(data['rates']);
          rates['AFN'] = 1;
          loading = false;
        });
      } else {
        throw Exception('Rates unavailable');
      }
    } catch (_) {
      setState(() {
        loading = false;
        error = tr(
          'د نرخونو ترلاسه کولو کې ستونزه ده',
          'دریافت نرخ‌ها با مشکل روبرو شد',
          'Could not load exchange rates',
        );
      });
    }
  }

  double convert() {
    if (rates[from] == null || rates[to] == null) return 0;
    return amount / (rates[from] as num) * (rates[to] as num);
  }

  String countryName(String code) {
    return countryNames[code]?[language] ?? code;
  }

  String flag(String code) => flags[code] ?? '🌐';

  List<String> get currencies {
    final list = rates.keys.toList()..sort();
    return list;
  }

  void swap() {
    setState(() {
      final old = from;
      from = to;
      to = old;
    });
  }

  void saveHistory() {
    final result = convert();
    setState(() {
      history.insert(
        0,
        '${amount.toString()} $from = ${result.toStringAsFixed(3)} $to',
      );
    });
  }

  Widget currencySelector(String selected, Function(String?) changed) {
    return DropdownButtonFormField<String>(
      value: currencies.contains(selected) ? selected : 'AFN',
      isExpanded: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        labelText: tr('اسعار', 'واحد پول', 'Currency'),
      ),
      items: currencies.map((code) {
        return DropdownMenuItem(
          value: code,
          child: Text('${flag(code)}  $code - ${countryName(code)}'),
        );
      }).toList(),
      onChanged: changed,
    );
  }

  Widget converterPage() {
    final result = convert();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Text(
                  tr('د اسعارو بدلون', 'تبدیل اسعار', 'Currency Converter'),
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 22),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: tr('اندازه ولیکئ', 'مقدار را وارد کنید', 'Enter amount'),
                    prefixIcon: const Icon(Icons.payments),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (v) {
                    setState(() {
                      amount = double.tryParse(v) ?? 0;
                    });
                  },
                ),
                const SizedBox(height: 16),
                currencySelector(from, (v) {
                  if (v != null) setState(() => from = v);
                }),
                const SizedBox(height: 10),
                IconButton.filled(
                  onPressed: swap,
                  icon: const Icon(Icons.swap_vert),
                  iconSize: 30,
                ),
                const SizedBox(height: 10),
                currencySelector(to, (v) {
                  if (v != null) setState(() => to = v);
                }),
                const SizedBox(height: 22),
                Text(
                  tr('پایله', 'نتیجه', 'Result'),
                  style: const TextStyle(fontSize: 17),
                ),
                const SizedBox(height: 8),
                Text(
                  '${result.toStringAsFixed(3)} $to',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF087E65),
                  ),
                ),
                const SizedBox(height: 15),
                FilledButton.icon(
                  onPressed: saveHistory,
                  icon: const Icon(Icons.save),
                  label: Text(tr('تاریخچه کې وساته', 'ذخیره در تاریخچه', 'Save to history')),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(tr(
              'نرخونه د نړیوالې سرچینې څخه دي',
              'نرخ‌ها از منبع بین‌المللی است',
              'Rates are from an international source',
            )),
            subtitle: Text(tr(
              'د نرخونو د تازه کولو لپاره تڼۍ کېکاږئ',
              'برای تازه‌سازی نرخ‌ها دکمه را بزنید',
              'Tap refresh to load the latest available rates',
            )),
            trailing: IconButton(
              onPressed: loading ? null : fetchRates,
              icon: const Icon(Icons.refresh),
            ),
          ),
        ),
      ],
    );
  }

  Widget ratesPage() {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (rates.isEmpty) return Center(child: Text(error));

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(
          tr('د نړۍ اسعار', 'ارزهای جهان', 'World currencies'),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...currencies.map((code) {
          final value = rates[code] as num;
          final afnValue = value == 0 ? 0 : 1 / value;
          return Card(
            child: ListTile(
              leading: Text(flag(code), style: const TextStyle(fontSize: 28)),
              title: Text(countryName(code)),
              subtitle: Text(code),
              trailing: Text(
                '${afnValue.toStringAsFixed(2)} AFN',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                setState(() {
                  from = code;
                  to = 'AFN';
                  tab = 0;
                });
              },
            ),
          );
        }),
      ],
    );
  }

  Widget provincesPage() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(
          tr('د افغانستان ۳۴ ولایتونه', '۳۴ ولایت افغانستان', '34 Provinces of Afghanistan'),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(tr(
          'د هر ولایت لپاره د افغانستان ملي مرجع نرخ ښودل کېږي. دا د ولایت ځانګړی صرافي نرخ نه دی.',
          'برای هر ولایت نرخ مرجع ملی افغانستان نمایش داده می‌شود؛ این نرخ جداگانه صرافی ولایت نیست.',
          'Each province displays the national reference rate, not a separate local exchange-market quote.',
        )),
        const SizedBox(height: 12),
        ...provinces.map((p) => Card(
          child: ListTile(
            leading: const Text('🇦🇫', style: TextStyle(fontSize: 26)),
            title: Text(p),
            subtitle: Text(tr(
              'ملي مرجع نرخ',
              'نرخ مرجع ملی',
              'National reference rate',
            )),
            trailing: Text(
              rates['USD'] == null
                  ? '---'
                  : '1 USD = ${(1 / (rates['USD'] as num)).toStringAsFixed(2)} AFN',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        )),
      ],
    );
  }

  Widget historyPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          tr('د افغانستان تاریخ', 'تاریخ افغانستان', 'History of Afghanistan'),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'افغانستان په ۱۹۱۹ میلادي کال کې د امان الله خان په مشرۍ خپلواکي ترلاسه کړه. د زمري ۲۸مه د افغانستان د خپلواکۍ ورځ ده.\n\n'
              'افغانستان په ۱۹۲۵ میلادي کال کې افغاني د ملي پیسو په توګه معرفي کړه. د افغانیو د پیسو اصلاحات د امان الله خان د واکمنۍ پر مهال ترسره شول.',
              style: TextStyle(fontSize: 16, height: 1.8),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          tr('د افغانیو تاریخ', 'تاریخ افغانی', 'History of the Afghani'),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              tr(
                'افغاني په ۱۹۲۵ میلادي کال کې د افغانستان ملي پیسه شوه. دا د امان الله خان د واکمنۍ پر مهال د پیسو د نظام د اصلاحاتو برخه وه. افغاني د AFN نړیوال کوډ لري.',
                'افغانی در سال ۱۹۲۵ میلادی به پول ملی افغانستان تبدیل شد. این کار بخشی از اصلاحات نظام پولی در زمان امان‌الله خان بود. کد بین‌المللی آن AFN است.',
                'The Afghani became Afghanistan’s national currency in 1925 during the monetary reforms under Amanullah Khan. Its international currency code is AFN.',
              ),
              style: const TextStyle(fontSize: 16, height: 1.8),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          tr('د تبادلې تاریخچه', 'تاریخچه تبدیل', 'Conversion history'),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        if (history.isEmpty)
          Text(tr('تر اوسه تاریخچه نشته', 'هنوز تاریخچه‌ای نیست', 'No conversion history yet')),
        ...history.map((h) => Card(
          child: ListTile(
            leading: const Icon(Icons.history),
            title: Text(h),
          ),
        )),
      ],
    );
  }

  Widget favoritesPage() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(
          tr('زما خوښې اسعار', 'ارزهای مورد علاقه', 'Favorite currencies'),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        ...favorites.map((code) => Card(
          child: ListTile(
            leading: Text(flag(code), style: const TextStyle(fontSize: 27)),
            title: Text(countryName(code)),
            subtitle: Text(code),
            trailing: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () => setState(() => favorites.remove(code)),
            ),
          ),
        )),
        const SizedBox(height: 12),
        Text(tr('نور اسعار', 'ارزهای دیگر', 'Add currencies')),
        ...currencies.where((c) => !favorites.contains(c)).take(30).map(
          (code) => ListTile(
            leading: Text(flag(code)),
            title: Text('$code - ${countryName(code)}'),
            trailing: IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: () => setState(() => favorites.add(code)),
            ),
          ),
        ),
      ],
    );
  }

  Widget settingsPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          tr('تنظیمات', 'تنظیمات', 'Settings'),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(tr('ژبه', 'زبان', 'Language')),
          trailing: DropdownButton<String>(
            value: language,
            items: const [
              DropdownMenuItem(value: 'ps', child: Text('پښتو')),
              DropdownMenuItem(value: 'fa', child: Text('دری')),
              DropdownMenuItem(value: 'en', child: Text('English')),
            ],
            onChanged: (v) {
              if (v != null) setState(() => language = v);
            },
          ),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.dark_mode),
          title: Text(tr('تیاره بڼه', 'حالت تاریک', 'Dark mode')),
          value: dark,
          onChanged: (v) {
            setState(() => dark = v);
          },
        ),
        const Divider(),
        const ListTile(
          leading: Icon(Icons.person),
          title: Text('Abdullah ALOKOZAI'),
          subtitle: Text('App Creator'),
        ),
        const ListTile(
          leading: Icon(Icons.info),
          title: Text('Afghani Exchange'),
          subtitle: Text('Currency Converter'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      converterPage(),
      ratesPage(),
      provincesPage(),
      historyPage(),
      favoritesPage(),
      settingsPage(),
    ];

    final labels = [
      tr('بدلون', 'تبدیل', 'Convert'),
      tr('اسعار', 'ارزها', 'Rates'),
      tr('ولایتونه', 'ولایت‌ها', 'Provinces'),
      tr('تاریخ', 'تاریخ', 'History'),
      tr('خوښې', 'علاقه‌مندی', 'Favorites'),
      tr('تنظیمات', 'تنظیمات', 'Settings'),
    ];

    return Theme(
      data: dark
          ? ThemeData.dark(useMaterial3: true).copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF087E65),
                brightness: Brightness.dark,
              ),
            )
          : ThemeData.light(useMaterial3: true).copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF087E65),
              ),
            ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            '🇦🇫 Afghani Exchange',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            if (loading)
              const Padding(
                padding: EdgeInsets.all(15),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              IconButton(
                onPressed: fetchRates,
                icon: const Icon(Icons.refresh),
              ),
          ],
        ),
        body: SafeArea(
          child: pages[tab],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (i) => setState(() => tab = i),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.currency_exchange),
              label: labels[0],
            ),
            NavigationDestination(
              icon: const Icon(Icons.public),
              label: labels[1],
            ),
            NavigationDestination(
              icon: const Icon(Icons.location_city),
              label: labels[2],
            ),
            NavigationDestination(
              icon: const Icon(Icons.history),
              label: labels[3],
            ),
            NavigationDestination(
              icon: const Icon(Icons.favorite),
              label: labels[4],
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings),
              label: labels[5],
            ),
          ],
        ),
      ),
    );
  }
}
