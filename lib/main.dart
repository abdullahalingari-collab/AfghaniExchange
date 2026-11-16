import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

void main() => runApp(const AfghaniExchange());

const bg = Color(0xFF061426);
const panel = Color(0xFF0D2340);
const panel2 = Color(0xFF102B4D);
const blue = Color(0xFF087DF5);
const cyan = Color(0xFF18C9E8);
const green = Color(0xFF19D68B);
const gold = Color(0xFFFFC83D);

const currencyNames = <String, String>{
  'AFN':'Afghan Afghani','USD':'US Dollar','EUR':'Euro',
  'GBP':'British Pound','PKR':'Pakistani Rupee','INR':'Indian Rupee',
  'AED':'UAE Dirham','SAR':'Saudi Riyal','TRY':'Turkish Lira',
  'CNY':'Chinese Yuan','JPY':'Japanese Yen','CAD':'Canadian Dollar',
  'AUD':'Australian Dollar','CHF':'Swiss Franc','RUB':'Russian Ruble',
  'IRR':'Iranian Rial','BDT':'Bangladeshi Taka','KWD':'Kuwaiti Dinar',
  'QAR':'Qatari Riyal','OMR':'Omani Rial','MYR':'Malaysian Ringgit',
  'SGD':'Singapore Dollar','THB':'Thai Baht','KRW':'South Korean Won',
  'BRL':'Brazilian Real','ZAR':'South African Rand','EGP':'Egyptian Pound',
  'NPR':'Nepalese Rupee','LKR':'Sri Lankan Rupee','SEK':'Swedish Krona',
  'NOK':'Norwegian Krone','DKK':'Danish Krone','NZD':'New Zealand Dollar',
  'MXN':'Mexican Peso','HKD':'Hong Kong Dollar','IDR':'Indonesian Rupiah',
  'IQD':'Iraqi Dinar','BHD':'Bahraini Dinar','JOD':'Jordanian Dinar',
  'ALL':'Albanian Lek','AMD':'Armenian Dram','ARS':'Argentine Peso',
  'AZN':'Azerbaijani Manat','BGN':'Bulgarian Lev','CLP':'Chilean Peso',
  'COP':'Colombian Peso','CZK':'Czech Koruna','DZD':'Algerian Dinar',
  'GEL':'Georgian Lari','GHS':'Ghanaian Cedi','HUF':'Hungarian Forint',
  'KES':'Kenyan Shilling','KZT':'Kazakhstani Tenge','MAD':'Moroccan Dirham',
  'MMK':'Myanmar Kyat','MNT':'Mongolian Tugrik','NGN':'Nigerian Naira',
  'PHP':'Philippine Peso','PLN':'Polish Zloty','RON':'Romanian Leu',
  'RSD':'Serbian Dinar','TWD':'Taiwan Dollar','TZS':'Tanzanian Shilling',
  'UAH':'Ukrainian Hryvnia','UGX':'Ugandan Shilling','UYU':'Uruguayan Peso',
  'VND':'Vietnamese Dong','XAF':'Central African CFA Franc',
  'XOF':'West African CFA Franc','XPF':'CFP Franc',
};

const flags = <String, String>{
  'AFN':'🇦🇫','USD':'🇺🇸','EUR':'🇪🇺','GBP':'🇬🇧','PKR':'🇵🇰',
  'INR':'🇮🇳','AED':'🇦🇪','SAR':'🇸🇦','TRY':'🇹🇷','CNY':'🇨🇳',
  'JPY':'🇯🇵','CAD':'🇨🇦','AUD':'🇦🇺','CHF':'🇨🇭','RUB':'🇷🇺',
  'IRR':'🇮🇷','BDT':'🇧🇩','KWD':'🇰🇼','QAR':'🇶🇦','OMR':'🇴🇲',
  'MYR':'🇲🇾','SGD':'🇸🇬','THB':'🇹🇭','KRW':'🇰🇷','BRL':'🇧🇷',
  'ZAR':'🇿🇦','EGP':'🇪🇬','NPR':'🇳🇵','LKR':'🇱🇰','SEK':'🇸🇪',
  'NOK':'🇳🇴','DKK':'🇩🇰','NZD':'🇳🇿','MXN':'🇲🇽','HKD':'🇭🇰',
  'IDR':'🇮🇩','IQD':'🇮🇶','BHD':'🇧🇭','JOD':'🇯🇴','ALL':'🇦🇱',
  'AMD':'🇦🇲','ARS':'🇦🇷','AZN':'🇦🇿','BGN':'🇧🇬','CLP':'🇨🇱',
  'COP':'🇨🇴','CZK':'🇨🇿','DZD':'🇩🇿','GEL':'🇬🇪','GHS':'🇬🇭',
  'HUF':'🇭🇺','KES':'🇰🇪','KZT':'🇰🇿','MAD':'🇲🇦','MMK':'🇲🇲',
  'MNT':'🇲🇳','NGN':'🇳🇬','PHP':'🇵🇭','PLN':'🇵🇱','RON':'🇷🇴',
  'RSD':'🇷🇸','TWD':'🇹🇼','TZS':'🇹🇿','UAH':'🇺🇦','UGX':'🇺🇬',
  'UYU':'🇺🇾','VND':'🇻🇳',
};

const words = {
  'ps': {
    'home':'کور','currencies':'اسعار','favorites':'خوښې',
    'history':'تاریخچه','more':'نور','convert':'د پیسو تبدیلول',
    'amount':'د پیسو اندازه','from':'له کوم اسعارو','to':'کوم اسعارو ته',
    'result':'د تبدیل پایله','rates':'د اسعارو نرخونه',
    'search':'اسعار ولټوئ','updated':'وروستی تازه کېدل',
    'refresh':'تازه کول','loading':'نرخونه ترلاسه کېږي...',
    'afghan':'افغانۍ','creator':'د اپ جوړوونکی',
    'about':'د اپ په اړه','language':'ژبه',
    'afghanHistory':'د افغانستان تاریخ','worldHistory':'د نړۍ تاریخ',
    'quote':'افغانستان زموږ ویاړ دی، تاریخ زموږ هویت دی او راتلونکی زموږ په لاس کې دی.',
    'afghanText':'افغانستان د لرغوني تاریخ او بډایه کلتور لرونکی هېواد دی. کابل، بلخ، هرات، غزني او کندهار د دې خاورې له مشهورو تاریخي ښارونو څخه دي. افغانستان د ورېښمو لارې پر مهمه برخه پروت و او د بېلابېلو تمدنونو د تګ راتګ مرکز پاتې شوی دی.',
    'worldText':'د نړۍ تاریخ د لرغونو تمدنونو، علمي پرمختګونو، سوداګرۍ او د ملتونو د اړیکو کیسې رانغاړي. د مصر، یونان، روم، چین او هند تمدنونو د نړۍ په تاریخ کې مهم رول لوبولی دی.',
    'empty':'تر اوسه معلومات نشته','saved':'ثبت شو',
    'clear':'پاکول','source':'د نرخونو سرچینه: ExchangeRate-API',
  },
  'fa': {
    'home':'خانه','currencies':'ارزها','favorites':'علاقه‌مندی',
    'history':'تاریخچه','more':'بیشتر','convert':'تبدیل پول',
    'amount':'مقدار پول','from':'از کدام ارز','to':'به کدام ارز',
    'result':'نتیجه تبدیل','rates':'نرخ ارزها',
    'search':'جستجوی ارز','updated':'آخرین بروزرسانی',
    'refresh':'تازه کردن','loading':'دریافت نرخ‌ها...',
    'afghan':'افغانی','creator':'سازنده برنامه',
    'about':'درباره برنامه','language':'زبان',
    'afghanHistory':'تاریخ افغانستان','worldHistory':'تاریخ جهان',
    'quote':'افغانستان افتخار ماست، تاریخ هویت ما و آینده در دستان ماست.',
    'afghanText':'افغانستان کشوری با تاریخ کهن و فرهنگ غنی است. کابل، بلخ، هرات، غزنی و قندهار از شهرهای تاریخی مشهور این سرزمین هستند. افغانستان در مسیر مهم جاده ابریشم قرار داشت و مرکز رفت‌وآمد تمدن‌های گوناگون بوده است.',
    'worldText':'تاریخ جهان داستان تمدن‌های باستانی، پیشرفت علمی، تجارت و روابط ملت‌ها را در بر می‌گیرد. تمدن‌های مصر، یونان، روم، چین و هند نقش مهمی در تاریخ جهان داشته‌اند.',
    'empty':'هنوز معلوماتی موجود نیست','saved':'ذخیره شد',
    'clear':'پاک کردن','source':'منبع نرخ‌ها: ExchangeRate-API',
  },
  'en': {
    'home':'Home','currencies':'Currencies','favorites':'Favorites',
    'history':'History','more':'More','convert':'Currency Converter',
    'amount':'Enter amount','from':'From currency','to':'To currency',
    'result':'Conversion result','rates':'Exchange rates',
    'search':'Search currencies','updated':'Last updated',
    'refresh':'Refresh','loading':'Loading rates...',
    'afghan':'Afghani','creator':'App Creator',
    'about':'About app','language':'Language',
    'afghanHistory':'History of Afghanistan','worldHistory':'World History',
    'quote':'Afghanistan is our pride, history is our identity, and the future is in our hands.',
    'afghanText':'Afghanistan is a country with an ancient history and rich culture. Kabul, Balkh, Herat, Ghazni and Kandahar are among its famous historic cities. Afghanistan stood along an important part of the Silk Road and connected many civilizations.',
    'worldText':'World history includes ancient civilizations, scientific progress, trade and relationships between nations. The civilizations of Egypt, Greece, Rome, China and India played important roles in world history.',
    'empty':'Nothing here yet','saved':'Saved',
    'clear':'Clear','source':'Rate source: ExchangeRate-API',
  },
};

class AfghaniExchange extends StatelessWidget {
  const AfghaniExchange({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afghani Exchange',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: blue,
          secondary: cyan,
          surface: panel,
        ),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int tab = 0;
  String lang = 'ps';
  String from = 'USD';
  String to = 'AFN';
  String search = '';

  final amount = TextEditingController(text: '100');

  Map<String, double> rates = {};
  bool loading = false;
  String error = '';
  DateTime? lastUpdate;
  Timer? timer;

  final Set<String> favorites = {'USD','EUR','GBP','PKR','SAR'};
  final List<String> history = [];

  String t(String key) => words[lang]![key] ?? key;
  String flag(String code) => flags[code] ?? '🌐';
  String name(String code) => currencyNames[code] ?? code;

  @override
  void initState() {
    super.initState();
    fetchRates();
    timer = Timer.periodic(
      const Duration(hours: 12),
      (_) => fetchRates(),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    amount.dispose();
    super.dispose();
  }

  Future<void> fetchRates() async {
    if (loading) return;
    setState(() {
      loading = true;
      error = '';
    });

    HttpClient? client;

    try {
      client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 20);

      final request = await client.getUrl(
        Uri.parse('https://open.er-api.com/v6/latest/AFN'),
      );

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final data = jsonDecode(body) as Map<String, dynamic>;

      if (data['result'] != 'success') {
        throw Exception('API error');
      }

      final raw = data['rates'] as Map<String, dynamic>;
      final updatedRates = <String, double>{'AFN': 1};

      for (final item in raw.entries) {
        if (item.value is num && (item.value as num) > 0) {
          updatedRates[item.key] =
              (item.value as num).toDouble();
        }
      }

      if (!mounted) return;

      setState(() {
        rates = updatedRates;
        lastUpdate = DateTime.now();
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'Could not load rates';
      });
    } finally {
      client?.close(force: true);
    }
  }

  double get converted {
    final value = double.tryParse(amount.text) ?? 0;
    final a = rates[from];
    final b = rates[to];

    if (a == null || b == null || a == 0) return 0;
    return value / a * b;
  }

  // اصلاح شوې برخه: num د double پر ځای کارول شوی.
  String number(num value) {
    if (!value.isFinite) return '0';

    if (value.abs() < 0.00001 && value != 0) {
      return value.toStringAsPrecision(5);
    }

    return value.toStringAsFixed(2);
  }

  List<String> get allCodes {
    final list = rates.keys.toList()..sort();

    if (search.isEmpty) return list;

    return list.where((c) =>
      c.toLowerCase().contains(search.toLowerCase()) ||
      name(c).toLowerCase().contains(search.toLowerCase())
    ).toList();
  }

  BoxDecoration cardDecoration({Color color = panel}) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(19),
      border: Border.all(color: const Color(0xFF1C4770)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.18),
          blurRadius: 12,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  Widget sectionTitle(String text, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Expanded(
          child: Text(text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (trailing != null) trailing,
      ]),
    );
  }

  Widget currencyButton(String code, bool isFrom) {
    return InkWell(
      onTap: () => chooseCurrency(isFrom),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: cardDecoration(color: panel2),
        child: Row(children: [
          Text(flag(code),
            style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(code,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(name(code),
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, color: cyan),
        ]),
      ),
    );
  }

  Future<void> chooseCurrency(bool isFrom) async {
    String query = '';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: panel,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, modalSet) {
          final list = rates.keys.where((c) =>
            c.toLowerCase().contains(query.toLowerCase()) ||
            name(c).toLowerCase().contains(query.toLowerCase())
          ).toList()..sort();

          return SafeArea(
            child: SizedBox(
              height: MediaQuery.of(ctx).size.height * .8,
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    onChanged: (v) => modalSet(() => query = v),
                    decoration: InputDecoration(
                      hintText: t('search'),
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: panel2,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final c = list[i];

                      return ListTile(
                        leading: Text(flag(c),
                          style: const TextStyle(fontSize: 27)),
                        title: Text(name(c)),
                        subtitle: Text(c),
                        onTap: () {
                          setState(() {
                            if (isFrom) {
                              from = c;
                            } else {
                              to = c;
                            }
                          });
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget converterCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.currency_exchange, color: cyan),
            const SizedBox(width: 9),
            Text(t('convert'),
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
          ]),
          const SizedBox(height: 15),
          Text(t('amount'),
            style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 7),
          TextField(
            controller: amount,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              filled: true,
              fillColor: panel2,
              prefixIcon: const Icon(
                Icons.payments_outlined,
                color: cyan,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 13),
          Text(t('from'),
            style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          currencyButton(from, true),
          Center(
            child: IconButton.filled(
              onPressed: () => setState(() {
                final old = from;
                from = to;
                to = old;
              }),
              icon: const Icon(Icons.swap_vert),
              style: IconButton.styleFrom(
                backgroundColor: blue,
              ),
            ),
          ),
          Text(t('to'),
            style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          currencyButton(to, false),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0758B9), Color(0xFF087DF5)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(children: [
              Text(t('result'),
                style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 7),
              Text('${number(converted)} $to',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                setState(() {
                  history.insert(
                    0,
                    '${number(double.tryParse(amount.text) ?? 0)} $from → ${number(converted)} $to',
                  );
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t('saved'))),
                );
              },
              icon: const Icon(Icons.calculate),
              label: Text(t('convert')),
            ),
          ),
        ],
      ),
    );
  }

  Widget rateTile(String code) {
    final r = rates[code] ?? 0;
    final oneUnitAfghani =
        code == 'AFN' ? 1.0 : (r == 0 ? 0.0 : 1 / r);

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: cardDecoration(),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 4,
        ),
        leading: Text(flag(code),
          style: const TextStyle(fontSize: 30)),
        title: Text(code,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(name(code),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 12,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${number(oneUnitAfghani)} AFN',
              style: const TextStyle(
                color: green,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('1 $code =',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
              ),
            ),
          ],
        ),
        onTap: () {
          setState(() {
            from = code;
            to = 'AFN';
            tab = 0;
          });
        },
        onLongPress: () => toggleFavorite(code),
      ),
    );
  }

  void toggleFavorite(String code) {
    setState(() {
      if (!favorites.add(code)) {
        favorites.remove(code);
      }
    });
  }

  Widget homePage() {
    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF092C53), Color(0xFF075CA6)],
            ),
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: cyan.withOpacity(.35)),
          ),
          child: Row(children: [
            Container(
              width: 53,
              height: 53,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.public,
                color: blue,
                size: 35,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Afghani Exchange',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text('Live Exchange Rates',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: loading ? null : fetchRates,
              icon: const Icon(Icons.refresh, color: cyan),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(13),
          decoration: cardDecoration(),
          child: Row(children: [
            const Icon(Icons.circle, color: green, size: 11),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                lastUpdate == null
                    ? (loading ? t('loading') : error)
                    : '${t('updated')}: ${lastUpdate!.toLocal().toString().substring(0, 16)}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            if (loading)
              const SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ]),
        ),
        const SizedBox(height: 14),
        converterCard(),
        sectionTitle(t('rates')),
        Wrap(
          spacing: 7,
          children: [
            for (final c in ['USD','GBP','EUR','SAR','PKR','AED'])
              ActionChip(
                avatar: Text(flag(c)),
                label: Text(c),
                onPressed: () => setState(() {
                  from = c;
                  to = 'AFN';
                }),
              ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          onChanged: (v) => setState(() => search = v),
          decoration: InputDecoration(
            hintText: t('search'),
            prefixIcon: const Icon(Icons.search, color: cyan),
            filled: true,
            fillColor: panel,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (rates.isEmpty && loading)
          const Center(child: CircularProgressIndicator())
        else if (allCodes.isEmpty)
          Center(child: Text(t('empty')))
        else
          ...allCodes.map(rateTile),
        const SizedBox(height: 15),
        Center(
          child: Text(t('source'),
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget currenciesPage() {
    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        sectionTitle(t('currencies')),
        TextField(
          onChanged: (v) => setState(() => search = v),
          decoration: InputDecoration(
            hintText: t('search'),
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: panel,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...allCodes.map(rateTile),
      ],
    );
  }

  Widget favoritesPage() {
    final list = favorites
        .where((c) => rates.containsKey(c))
        .toList()
      ..sort();

    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        sectionTitle(t('favorites')),
        if (list.isEmpty) Center(child: Text(t('empty'))),
        ...list.map((c) => Row(children: [
          Expanded(child: rateTile(c)),
          IconButton(
            onPressed: () => toggleFavorite(c),
            icon: const Icon(Icons.star, color: gold),
          ),
        ])),
      ],
    );
  }

  Widget historyPage() {
    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        sectionTitle(
          t('history'),
          trailing: TextButton(
            onPressed: () => setState(() => history.clear()),
            child: Text(t('clear')),
          ),
        ),
        if (history.isEmpty) Center(child: Text(t('empty'))),
        ...history.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 9),
          decoration: cardDecoration(),
          child: ListTile(
            leading: const Icon(Icons.swap_horiz, color: cyan),
            title: Text(item),
          ),
        )),
      ],
    );
  }

  Widget morePage() {
    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: cardDecoration(color: panel2),
          child: Column(children: [
            const CircleAvatar(
              radius: 34,
              backgroundColor: blue,
              child: Icon(
                Icons.person,
                size: 38,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text('Abdullah ALOKOZAI',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(t('creator'),
              style: const TextStyle(color: cyan)),
          ]),
        ),
        const SizedBox(height: 15),
        sectionTitle(t('language')),
        for (final item in [
          ('ps', 'پښتو'),
          ('fa', 'دری'),
          ('en', 'English'),
        ])
          Card(
            color: panel,
            child: RadioListTile<String>(
              value: item.$1,
              groupValue: lang,
              title: Text(item.$2),
              onChanged: (v) {
                if (v != null) {
                  setState(() => lang = v);
                }
              },
            ),
          ),
        sectionTitle(t('about')),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: cardDecoration(),
          child: Column(children: [
            const Icon(Icons.public, size: 42, color: cyan),
            const SizedBox(height: 10),
            const Text('Afghani Exchange',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(t('quote'), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(t('source'),
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Version 1.0.0',
              style: TextStyle(color: Colors.white54)),
          ]),
        ),
        sectionTitle(t('afghanHistory')),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: cardDecoration(),
          child: Text(t('afghanText'),
            style: const TextStyle(height: 1.8)),
        ),
        sectionTitle(t('worldHistory')),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: cardDecoration(),
          child: Text(t('worldText'),
            style: const TextStyle(height: 1.8)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      homePage(),
      currenciesPage(),
      favoritesPage(),
      historyPage(),
      morePage(),
    ];

    return Directionality(
      textDirection:
          lang == 'en' ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: bg,
          title: const Text(
            'Afghani Exchange',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: const Padding(
            padding: EdgeInsets.all(10),
            child: Icon(Icons.public, color: cyan, size: 27),
          ),
        ),
        body: IndexedStack(
          index: tab,
          children: pages,
        ),
        bottomNavigationBar: NavigationBar(
          backgroundColor: const Color(0xFF081B30),
          indicatorColor: blue.withOpacity(.25),
          selectedIndex: tab,
          onDestinationSelected: (v) {
            setState(() {
              tab = v;
              search = '';
            });
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home, color: cyan),
              label: t('home'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.currency_exchange),
              selectedIcon: const Icon(
                Icons.currency_exchange,
                color: cyan,
              ),
              label: t('currencies'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.star_border),
              selectedIcon: const Icon(Icons.star, color: gold),
              label: t('favorites'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.history),
              selectedIcon: const Icon(Icons.history, color: cyan),
              label: t('history'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.grid_view),
              selectedIcon: const Icon(Icons.grid_view, color: cyan),
              label: t('more'),
            ),
          ],
        ),
      ),
    );
  }
}
