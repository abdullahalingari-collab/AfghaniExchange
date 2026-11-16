import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AfghaniExchange());
}

class AfghaniExchange extends StatefulWidget {
  const AfghaniExchange({super.key});

  @override
  State<AfghaniExchange> createState() => _AfghaniExchangeState();
}

class _AfghaniExchangeState extends State<AfghaniExchange> {
  bool dark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afghani Exchange',
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF07866B),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF1F7F5),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF07866B),
          brightness: Brightness.dark,
        ),
      ),
      home: HomePage(
        onThemeChanged: (v) => setState(() => dark = v),
        dark: dark,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final bool dark;

  const HomePage({
    super.key,
    required this.onThemeChanged,
    required this.dark,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic> rates = {};
  bool loading = true;
  String error = '';
  String language = 'ps';
  int page = 0;
  String selectedProvince = 'کابل';
  String from = 'USD';
  String to = 'AFN';
  double amount = 1;
  String? creatorPhoto;
  final amountController = TextEditingController(text: '1');
  final searchController = TextEditingController();
  final history = <String>[];
  final favorites = <String>{'USD', 'EUR', 'PKR'};
  final picker = ImagePicker();

  final provinces = [
    'کابل', 'کندهار', 'هرات', 'بلخ', 'ننګرهار',
    'لغمان', 'کنړ', 'نورستان', 'پنجشېر', 'پروان',
    'کاپیسا', 'بغلان', 'کندز', 'تخار', 'بدخشان',
    'سمنګان', 'سرپل', 'جوزجان', 'فاریاب', 'بادغیس',
    'غور', 'دایکندی', 'بامیان', 'میدان وردګ',
    'لوګر', 'پکتیا', 'پکتیکا', 'خوست', 'غزني',
    'ارزګان', 'زابل', 'هلمند', 'فراه', 'نیمروز'
  ];

  final flags = {
    'AFN':'🇦🇫','USD':'🇺🇸','EUR':'🇪🇺','GBP':'🇬🇧',
    'PKR':'🇵🇰','INR':'🇮🇳','IRR':'🇮🇷','CNY':'🇨🇳',
    'AED':'🇦🇪','SAR':'🇸🇦','TRY':'🇹🇷','JPY':'🇯🇵',
    'CAD':'🇨🇦','AUD':'🇦🇺','CHF':'🇨🇭','RUB':'🇷🇺',
    'QAR':'🇶🇦','KWD':'🇰🇼','OMR':'🇴🇲','BDT':'🇧🇩',
    'NPR':'🇳🇵','MYR':'🇲🇾','THB':'🇹🇭','SGD':'🇸🇬',
    'NZD':'🇳🇿','SEK':'🇸🇪','NOK':'🇳🇴','DKK':'🇩🇰',
    'ZAR':'🇿🇦','BRL':'🇧🇷','KRW':'🇰🇷','IDR':'🇮🇩',
    'LKR':'🇱🇰','EGP':'🇪🇬','IQD':'🇮🇶','HKD':'🇭🇰',
    'UAH':'🇺🇦','PLN':'🇵🇱','MXN':'🇲🇽','ARS':'🇦🇷',
    'BHD':'🇧🇭','JOD':'🇯🇴','ILS':'🇮🇱','KES':'🇰🇪',
    'NGN':'🇳🇬','GEL':'🇬🇪','AZN':'🇦🇿','UZS':'🇺🇿',
    'KZT':'🇰🇿','TJS':'🇹🇯','TMT':'🇹🇲',
  };

  final names = {
    'AFN': ['افغانستان','افغانستان','Afghanistan'],
    'USD': ['امریکا','آمریکا','United States'],
    'EUR': ['اروپايي ټولنه','اتحادیه اروپا','European Union'],
    'GBP': ['بریتانیا','بریتانیا','United Kingdom'],
    'PKR': ['پاکستان','پاکستان','Pakistan'],
    'INR': ['هند','هند','India'],
    'IRR': ['ایران','ایران','Iran'],
    'CNY': ['چین','چین','China'],
    'AED': ['متحده عربي امارات','امارات متحده عربی','United Arab Emirates'],
    'SAR': ['سعودي عربستان','عربستان سعودی','Saudi Arabia'],
    'TRY': ['ترکیه','ترکیه','Turkey'],
    'JPY': ['جاپان','جاپان','Japan'],
    'CAD': ['کاناډا','کانادا','Canada'],
    'AUD': ['استرالیا','استرالیا','Australia'],
    'CHF': ['سویس','سوئیس','Switzerland'],
    'RUB': ['روسیه','روسیه','Russia'],
    'QAR': ['قطر','قطر','Qatar'],
    'KWD': ['کویټ','کویت','Kuwait'],
    'OMR': ['عمان','عمان','Oman'],
    'BDT': ['بنګله دېش','بنگلادش','Bangladesh'],
    'NPR': ['نیپال','نپال','Nepal'],
    'MYR': ['مالیزیا','مالزی','Malaysia'],
    'THB': ['تایلنډ','تایلند','Thailand'],
    'SGD': ['سنګاپور','سنگاپور','Singapore'],
    'NZD': ['نیوزیلنډ','نیوزیلند','New Zealand'],
    'SEK': ['سویډن','سوئد','Sweden'],
    'NOK': ['ناروې','نروژ','Norway'],
    'DKK': ['ډنمارک','دانمارک','Denmark'],
    'ZAR': ['سویلي افریقا','آفریقای جنوبی','South Africa'],
    'BRL': ['برازیل','برزیل','Brazil'],
    'KRW': ['جنوبي کوریا','کوریای جنوبی','South Korea'],
    'IDR': ['اندونیزیا','اندونزی','Indonesia'],
    'LKR': ['سریلانکا','سریلانکا','Sri Lanka'],
    'EGP': ['مصر','مصر','Egypt'],
    'IQD': ['عراق','عراق','Iraq'],
    'HKD': ['هانګ کانګ','هنگ کنگ','Hong Kong'],
    'UAH': ['اوکراین','اوکراین','Ukraine'],
    'PLN': ['پولنډ','لهستان','Poland'],
    'MXN': ['مکسیکو','مکزیک','Mexico'],
    'ARS': ['ارجنټاین','آرژانتین','Argentina'],
    'BHD': ['بحرین','بحرین','Bahrain'],
    'JOD': ['اردن','اردن','Jordan'],
    'ILS': ['اسرائیل','اسرائیل','Israel'],
    'KES': ['کینیا','کنیا','Kenya'],
    'NGN': ['نایجیریا','نیجریه','Nigeria'],
    'GEL': ['ګرجستان','گرجستان','Georgia'],
    'AZN': ['اذربایجان','آذربایجان','Azerbaijan'],
    'UZS': ['ازبکستان','ازبکستان','Uzbekistan'],
    'KZT': ['قزاقستان','قزاقستان','Kazakhstan'],
    'TJS': ['تاجکستان','تاجیکستان','Tajikistan'],
    'TMT': ['ترکمنستان','ترکمنستان','Turkmenistan'],
  };

  String tr(String ps, String fa, String en) {
    if (language == 'fa') return fa;
    if (language == 'en') return en;
    return ps;
  }

  String flag(String code) => flags[code] ?? '🌐';

  String country(String code) {
    final n = names[code];
    if (n == null) return code;
    return n[language == 'ps' ? 0 : language == 'fa' ? 1 : 2];
  }

  List<String> get currencies {
    final list = rates.keys.where((e) => e is String).cast<String>().toList();
    list.sort();
    return list;
  }

  @override
  void initState() {
    super.initState();
    loadSavedPhoto();
    fetchRates();
  }

  @override
  void dispose() {
    amountController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadSavedPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('creator_photo');
    if (path != null && File(path).existsSync()) {
      if (mounted) setState(() => creatorPhoto = path);
    }
  }

  Future<void> chooseCreatorPhoto() async {
    try {
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (image == null) return;

      final directory = await getApplicationDocumentsDirectory();
      final saved = await File(image.path).copy(
        '${directory.path}/creator_profile.jpg',
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('creator_photo', saved.path);

      if (mounted) {
        setState(() => creatorPhoto = saved.path);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr(
            'عکس خوندي شو',
            'عکس ذخیره شد',
            'Photo saved',
          ))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Photo error: $e')),
        );
      }
    }
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
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      client.close();

      final data = jsonDecode(body);
      if (response.statusCode != 200 ||
          data['result'] != 'success' ||
          data['rates'] is! Map) {
        throw Exception('Rates unavailable');
      }

      if (!mounted) return;
      setState(() {
        rates = Map<String, dynamic>.from(data['rates']);
        rates['AFN'] = 1;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = tr(
          'د نرخونو ترلاسه کولو کې ستونزه ده',
          'دریافت نرخ‌ها با مشکل روبرو شد',
          'Could not load rates',
        );
      });
    }
  }

  double convert() {
    if (rates[from] == null || rates[to] == null) return 0;
    return amount /
        (rates[from] as num) *
        (rates[to] as num);
  }

  String rateFor(String code) {
    final v = rates[code];
    if (v == null || (v as num) == 0) return '---';
    return (1 / v).toStringAsFixed(2);
  }

  void swap() {
    setState(() {
      final old = from;
      from = to;
      to = old;
    });
  }

  Future<void> openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget heading(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF07866B), size: 27),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget panel({required Widget child}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Widget currencyPicker(
    String value,
    ValueChanged<String?> changed,
  ) {
    return DropdownButtonFormField<String>(
      value: currencies.contains(value) ? value : 'AFN',
      isExpanded: true,
      decoration: InputDecoration(
        labelText: tr('اسعار', 'واحد پول', 'Currency'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      items: currencies.map((code) {
        return DropdownMenuItem(
          value: code,
          child: Text(
            '${flag(code)}  $code - ${country(code)}',
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: changed,
    );
  }

  Widget converterPage() {
    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        panel(
          child: Column(
            children: [
              heading(
                tr('د اسعارو بدلون', 'تبدیل اسعار', 'Currency Converter'),
                Icons.currency_exchange,
              ),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: tr('اندازه ولیکئ', 'مقدار را وارد کنید', 'Enter amount'),
                  prefixIcon: const Icon(Icons.payments),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onChanged: (v) {
                  setState(() => amount = double.tryParse(v) ?? 0);
                },
              ),
              const SizedBox(height: 15),
              currencyPicker(from, (v) {
                if (v != null) setState(() => from = v);
              }),
              const SizedBox(height: 8),
              IconButton.filled(
                onPressed: swap,
                icon: const Icon(Icons.swap_vert),
                iconSize: 30,
              ),
              const SizedBox(height: 8),
              currencyPicker(to, (v) {
                if (v != null) setState(() => to = v);
              }),
              const SizedBox(height: 22),
              Text(
                tr('د تبادلې پایله', 'نتیجه تبدیل', 'Conversion result'),
              ),
              const SizedBox(height: 7),
              Text(
                '${convert().toStringAsFixed(3)} $to',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF07866B),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () {
                  setState(() {
                    history.insert(
                      0,
                      '${amount.toString()} $from = ${convert().toStringAsFixed(3)} $to',
                    );
                  });
                },
                icon: const Icon(Icons.save),
                label: Text(tr(
                  'تاریخچه کې وساته',
                  'ذخیره در تاریخچه',
                  'Save conversion',
                )),
              ),
            ],
          ),
        ),
        panel(
          child: ListTile(
            leading: const Icon(Icons.update),
            title: Text(tr(
              'وروستي موجود نرخونه',
              'آخرین نرخ‌های موجود',
              'Latest available rates',
            )),
            subtitle: Text(loading ? 'Loading...' : error.isEmpty
                ? tr('نرخونه تازه دي', 'نرخ‌ها دریافت شد', 'Rates loaded')
                : error),
            trailing: IconButton(
              onPressed: loading ? null : fetchRates,
              icon: const Icon(Icons.refresh),
            ),
          ),
        ),
      ],
    );
  }

  void showProvince(String province) {
    setState(() => selectedProvince = province);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * .83,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  '🇦🇫 $province',
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(tr(
                'د ټولو هېوادونو اسعار او ملي مرجع نرخ',
                'ارزهای کشورها و نرخ مرجع ملی',
                'World currencies and national reference rates',
              )),
              const SizedBox(height: 10),
              Expanded(
                child: currencies.isEmpty
                    ? Center(child: Text(error.isEmpty ? 'Loading...' : error))
                    : ListView.builder(
                        itemCount: currencies.length,
                        itemBuilder: (context, i) {
                          final code = currencies[i];
                          return ListTile(
                            leading: Text(
                              flag(code),
                              style: const TextStyle(fontSize: 27),
                            ),
                            title: Text(country(code)),
                            subtitle: Text(code),
                            trailing: Text(
                              '1 $code = ${rateFor(code)} AFN',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
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

  Widget provincesPage() {
    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        heading(
          tr('د افغانستان ۳۴ ولایتونه', '۳۴ ولایت افغانستان', 'Afghanistan Provinces'),
          Icons.location_city,
        ),
        panel(
          child: Text(tr(
            'هر ولایت پرانیزئ؛ د نړۍ د اسعارو بشپړ لیست او د ملي مرجع نرخ به وګورئ. دا د ولایت ځانګړی صرافي نرخ نه دی.',
            'هر ولایت را باز کنید؛ فهرست ارزهای جهان و نرخ مرجع ملی را می‌بینید. این نرخ جداگانه بازار محلی نیست.',
            'Open any province to see world currencies and the national reference rate. These are not separate local market quotes.',
          )),
        ),
        ...provinces.map((p) => Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF087E65),
              child: Text('🇦🇫', style: TextStyle(fontSize: 22)),
            ),
            title: Text(
              p,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(tr(
              'د اسعارو لیست پرانیزئ',
              'فهرست ارزها را باز کنید',
              'Open currency list',
            )),
            trailing: const Icon(Icons.arrow_forward_ios, size: 17),
            onTap: () => showProvince(p),
          ),
        )),
      ],
    );
  }

  Widget ratesPage() {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (rates.isEmpty) return Center(child: Text(error));

    final q = searchController.text.toLowerCase();
    final filtered = currencies.where((c) {
      return c.toLowerCase().contains(q) ||
          country(c).toLowerCase().contains(q);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(13),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: tr('هېواد یا اسعار ولټوئ', 'جستجوی کشور یا ارز', 'Search country or currency'),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, i) {
              final code = filtered[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  leading: Text(
                    flag(code),
                    style: const TextStyle(fontSize: 28),
                  ),
                  title: Text(
                    country(code),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(code),
                  trailing: Text(
                    '${rateFor(code)} AFN',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    setState(() {
                      from = code;
                      to = 'AFN';
                      page = 0;
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget historyPage() {
    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        heading(
          tr('د افغانستان تاریخ', 'تاریخ افغانستان', 'Afghanistan History'),
          Icons.account_balance,
        ),
        panel(
          child: Text(
            tr(
              'افغانستان په ۱۹۱۹ میلادي کال کې د امان الله خان په مشرۍ خپلواکي ترلاسه کړه. د زمري ۲۸مه د خپلواکۍ ورځ ده.',
              'افغانستان در سال ۱۹۱۹ میلادی به رهبری امان‌الله خان استقلال خود را به دست آورد. ۲۸ اسد روز استقلال است.',
              'Afghanistan regained its independence in 1919 under King Amanullah Khan. August 19 is celebrated as Independence Day.',
            ),
            style: const TextStyle(fontSize: 16, height: 1.8),
          ),
        ),
        heading(
          tr('د افغانیو تاریخ', 'تاریخ افغانی', 'History of the Afghani'),
          Icons.payments,
        ),
        panel(
          child: Text(
            tr(
              'افغاني په ۱۹۲۵ میلادي کال کې د افغانستان ملي پیسه شوه. دا د امان الله خان د واکمنۍ پر مهال د پیسو د نظام د اصلاحاتو برخه وه. نړیوال کوډ یې AFN دی.',
              'افغانی در سال ۱۹۲۵ میلادی پول ملی افغانستان شد. این بخشی از اصلاحات نظام پولی در دوره امان‌الله خان بود. کد بین‌المللی آن AFN است.',
              'The Afghani became Afghanistan’s national currency in 1925 during monetary reforms under Amanullah Khan. Its international code is AFN.',
            ),
            style: const TextStyle(fontSize: 16, height: 1.8),
          ),
        ),
        heading(
          tr('د تبادلې تاریخچه', 'تاریخچه تبدیل', 'Conversion History'),
          Icons.history,
        ),
        if (history.isEmpty)
          Text(tr('تاریخچه نشته', 'تاریخچه‌ای نیست', 'No history yet')),
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
      padding: const EdgeInsets.all(15),
      children: [
        heading(
          tr('زما خوښې اسعار', 'ارزهای مورد علاقه', 'Favorite currencies'),
          Icons.favorite,
        ),
        ...favorites.map((code) => Card(
          child: ListTile(
            leading: Text(flag(code), style: const TextStyle(fontSize: 27)),
            title: Text(country(code)),
            subtitle: Text(code),
            trailing: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () => setState(() => favorites.remove(code)),
            ),
          ),
        )),
        const Divider(),
        ...currencies.where((c) => !favorites.contains(c)).take(40).map(
          (code) => ListTile(
            leading: Text(flag(code)),
            title: Text('${country(code)} ($code)'),
            trailing: IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: () => setState(() => favorites.add(code)),
            ),
          ),
        ),
      ],
    );
  }

  Widget creatorPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        panel(
          child: Column(
            children: [
              heading(
                tr('د اپ جوړوونکی', 'سازنده برنامه', 'App Creator'),
                Icons.person,
              ),
              GestureDetector(
                onTap: chooseCreatorPhoto,
                child: CircleAvatar(
                  radius: 75,
                  backgroundColor: const Color(0xFF07866B),
                  backgroundImage: creatorPhoto != null
                      ? FileImage(File(creatorPhoto!))
                      : null,
                  child: creatorPhoto == null
                      ? const Icon(Icons.add_a_photo,
                          size: 48, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'ABDULLAH ALOKOZAI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: chooseCreatorPhoto,
                icon: const Icon(Icons.photo_library),
                label: Text(tr(
                  'عکس انتخاب یا بدل کړه',
                  'انتخاب یا تغییر عکس',
                  'Choose or change photo',
                )),
              ),
              Text(tr(
                'عکس ستا په موبایل کې خوندي کېږي.',
                'عکس در موبایل شما ذخیره می‌شود.',
                'Your photo is saved on this device.',
              )),
            ],
          ),
        ),
        heading(
          tr('زما ټولنیزې شبکې', 'شبکه‌های اجتماعی', 'Social Media'),
          Icons.share,
        ),
        socialTile('Facebook', Icons.facebook, 'https://www.facebook.com/'),
        socialTile('TikTok', Icons.music_note, 'https://www.tiktok.com/'),
        socialTile('WhatsApp', Icons.chat, 'https://www.whatsapp.com/'),
        socialTile('YouTube', Icons.play_circle, 'https://www.youtube.com/'),
        socialTile('Instagram', Icons.camera_alt, 'https://www.instagram.com/'),
      ],
    );
  }

  Widget socialTile(String title, IconData icon, String url) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF087E65),
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.open_in_new),
        onTap: () => openLink(url),
      ),
    );
  }

  Widget settingsPage() {
    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        heading(
          tr('تنظیمات', 'تنظیمات', 'Settings'),
          Icons.settings,
        ),
        panel(
          child: Column(
            children: [
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
                value: widget.dark,
                onChanged: widget.onThemeChanged,
              ),
              const Divider(),
              const ListTile(
                leading: Icon(Icons.person),
                title: Text(
                  'ABDULLAH ALOKOZAI',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text('Afghani Exchange'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      tr('کور', 'خانه', 'Home'),
      tr('اسعار', 'ارزها', 'Rates'),
      tr('ولایتونه', 'ولایت‌ها', 'Provinces'),
      tr('تاریخ', 'تاریخ', 'History'),
      tr('خوښې', 'علاقه‌مندی', 'Favorites'),
      tr('جوړوونکی', 'سازنده', 'Creator'),
      tr('تنظیمات', 'تنظیمات', 'Settings'),
    ];

    final pages = [
      converterPage(),
      ratesPage(),
      provincesPage(),
      historyPage(),
      favoritesPage(),
      creatorPage(),
      settingsPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF087E65),
        foregroundColor: Colors.white,
        title: const Text(
          '🇦🇫 Afghani Exchange',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            onPressed: loading ? null : fetchRates,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(child: pages[page]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: page,
        onDestinationSelected: (i) => setState(() => page = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home),
            label: titles[0],
          ),
          NavigationDestination(
            icon: const Icon(Icons.public),
            label: titles[1],
          ),
          NavigationDestination(
            icon: const Icon(Icons.location_city),
            label: titles[2],
          ),
          NavigationDestination(
            icon: const Icon(Icons.history),
            label: titles[3],
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite),
            label: titles[4],
          ),
          NavigationDestination(
            icon: const Icon(Icons.person),
            label: titles[5],
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings),
            label: titles[6],
          ),
        ],
      ),
    );
  }
}
