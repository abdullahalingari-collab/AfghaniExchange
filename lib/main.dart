import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AfghaniExchangeApp());
}

const Color darkBg = Color(0xFF081525);
const Color cardColor = Color(0xFF172A40);
const Color teal = Color(0xFF12C99A);

class AfghaniExchangeApp extends StatelessWidget {
  const AfghaniExchangeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afghani Exchange',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class Currency {
  final String flag;
  final String name;
  final String code;

  const Currency(this.flag, this.name, this.code);
}

const currencies = [
  Currency('🇦🇫', 'افغانۍ', 'AFN'),
  Currency('🇺🇸', 'امریکایي ډالر', 'USD'),
  Currency('🇵🇰', 'پاکستانۍ روپۍ', 'PKR'),
  Currency('🇮🇳', 'هندي روپۍ', 'INR'),
  Currency('🇪🇺', 'یورو', 'EUR'),
  Currency('🇬🇧', 'برتانوي پونډ', 'GBP'),
  Currency('🇸🇦', 'سعودي ریال', 'SAR'),
  Currency('🇦🇪', 'اماراتي درهم', 'AED'),
  Currency('🇨🇳', 'چینایي یوان', 'CNY'),
  Currency('🇮🇷', 'ایراني ریال', 'IRR'),
  Currency('🇨🇦', 'کاناډایي ډالر', 'CAD'),
  Currency('🇦🇺', 'اسټرالیایي ډالر', 'AUD'),
  Currency('🇨🇭', 'سویسي فرانک', 'CHF'),
  Currency('🇹🇷', 'ترکي لیره', 'TRY'),
  Currency('🇯🇵', 'جاپاني ین', 'JPY'),
  Currency('🇷🇺', 'روسي روبل', 'RUB'),
  Currency('🇰🇼', 'کویتي دینار', 'KWD'),
  Currency('🇶🇦', 'قطري ریال', 'QAR'),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedTab = 0;

  final sources = const [
    {
      'name': 'سرای شهزاده',
      'url': 'https://sarafi.af/en/exchange-rates/sarai-shahzada',
      'flag': '🇦🇫',
    },
    {
      'name': 'خراسان مارکیټ',
      'url': 'https://sarafi.af/en/exchange-rates/khorasan-market',
      'flag': '🇦🇫',
    },
    {
      'name': 'د افغانستان بانک',
      'url': 'https://www.dab.gov.af/exchange-rates',
      'flag': '🏦',
    },
  ];

  void openSource(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SourcePage(
          title: sources[index]['name']!,
          url: sources[index]['url']!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkBg,
        title: const Row(
          children: [
            Text('🇦🇫', style: TextStyle(fontSize: 27)),
            SizedBox(width: 10),
            Text(
              'Afghani Exchange',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: teal,
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: selectedTab,
        children: [
          buildHome(),
          buildCurrencies(),
          buildSources(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: cardColor,
        indicatorColor: teal.withOpacity(0.2),
        selectedIndex: selectedTab,
        onDestinationSelected: (index) {
          setState(() => selectedTab = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: teal),
            label: 'کور',
          ),
          NavigationDestination(
            icon: Icon(Icons.currency_exchange),
            selectedIcon: Icon(Icons.currency_exchange, color: teal),
            label: 'اسعار',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance),
            selectedIcon: Icon(Icons.account_balance, color: teal),
            label: 'نرخونه',
          ),
        ],
      ),
    );
  }

  Widget buildHome() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF087F70), Color(0xFF123D59)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🇦🇫  افغانستان', style: TextStyle(fontSize: 18)),
              SizedBox(height: 12),
              Text(
                'Afghani Exchange',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text('د اسعارو د نرخونو معلومات په یوه ځای کې'),
              SizedBox(height: 15),
              Text(
                'ABDULLAH ALOKOZAI',
                style: TextStyle(
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'د اسعارو هېوادونه',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...currencies.take(8).map(currencyTile),
        const SizedBox(height: 20),
        const Text(
          'د نرخونو سرچینې',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...List.generate(sources.length, sourceTile),
      ],
    );
  }

  Widget buildCurrencies() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'د نړۍ اسعار او بیرغونه',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...currencies.map(currencyTile),
      ],
    );
  }

  Widget buildSources() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'د افغانستان د اسعارو نرخونه',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'د هرې سرچینې د پېر او پلور نرخونه په اصلي پاڼه کې وګوره.',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 16),
        ...List.generate(sources.length, sourceTile),
      ],
    );
  }

  Widget currencyTile(Currency currency) {
    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Text(
          currency.flag,
          style: const TextStyle(fontSize: 30),
        ),
        title: Text(
          currency.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: Text(
          currency.code,
          style: const TextStyle(
            color: teal,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget sourceTile(int index) {
    final source = sources[index];
    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Text(
          source['flag']!,
          style: const TextStyle(fontSize: 28),
        ),
        title: Text(
          source['name']!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('د پېر او پلور نرخونه وګوره'),
        trailing: const Icon(Icons.arrow_forward_ios, color: teal),
        onTap: () => openSource(index),
      ),
    );
  }
}

class SourcePage extends StatefulWidget {
  final String title;
  final String url;

  const SourcePage({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<SourcePage> createState() => _SourcePageState();
}

class _SourcePageState extends State<SourcePage> {
  late final WebViewController controller;
  bool loading = true;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (loading)
            const Center(
              child: CircularProgressIndicator(color: teal),
            ),
        ],
      ),
    );
  }
}
