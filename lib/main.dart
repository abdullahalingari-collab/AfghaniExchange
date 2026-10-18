import 'package:flutter/material.dart';

void main() {
  runApp(const AfghaniExchangeApp());
}

const Color bg = Color(0xFF031329);
const Color panel = Color(0xFF08264A);
const Color blue = Color(0xFF087BFF);
const Color cyan = Color(0xFF08D9D0);

class Currency {
  final String code;
  final String name;
  final String flag;
  final double rate;

  const Currency(this.code, this.name, this.flag, this.rate);
}

const List<Currency> currencies = [
  Currency('AFN', 'Afghan Afghani', '🇦🇫', 1),
  Currency('USD', 'US Dollar', '🇺🇸', 68.50),
  Currency('EUR', 'Euro', '🇪🇺', 78.12),
  Currency('GBP', 'British Pound', '🇬🇧', 92.34),
  Currency('PKR', 'Pakistani Rupee', '🇵🇰', 0.25),
  Currency('INR', 'Indian Rupee', '🇮🇳', 0.78),
  Currency('AED', 'UAE Dirham', '🇦🇪', 18.64),
  Currency('SAR', 'Saudi Riyal', '🇸🇦', 18.25),
  Currency('IRR', 'Iranian Rial', '🇮🇷', 0.00016),
  Currency('TRY', 'Turkish Lira', '🇹🇷', 2.12),
  Currency('CNY', 'Chinese Yuan', '🇨🇳', 9.58),
  Currency('CAD', 'Canadian Dollar', '🇨🇦', 49.50),
  Currency('AUD', 'Australian Dollar', '🇦🇺', 44.70),
  Currency('JPY', 'Japanese Yen', '🇯🇵', 0.46),
  Currency('QAR', 'Qatari Riyal', '🇶🇦', 18.80),
];

class AfghaniExchangeApp extends StatelessWidget {
  const AfghaniExchangeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afghani Exchange',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const ExchangeHome(),
    );
  }
}

class ExchangeHome extends StatefulWidget {
  const ExchangeHome({super.key});

  @override
  State<ExchangeHome> createState() => _ExchangeHomeState();
}

class _ExchangeHomeState extends State<ExchangeHome> {
  Currency from = currencies[0];
  Currency to = currencies[1];

  final amountController =
      TextEditingController(text: '1000');

  final searchController = TextEditingController();

  int bottomIndex = 0;
  int categoryIndex = 0;

  String language = 'پښتو';
  String search = '';

  final Set<String> favorites = {'USD', 'EUR'};
  final List<String> history = [];

  double get amount =>
      double.tryParse(amountController.text.trim()) ?? 0;

  double get result => amount * from.rate / to.rate;

  String format(double value) {
    if (value != 0 && value.abs() < 0.01) {
      return value.toStringAsPrecision(4);
    }
    return value.toStringAsFixed(2);
  }

  @override
  void dispose() {
    amountController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void swapCurrencies() {
    setState(() {
      final old = from;
      from = to;
      to = old;
    });
  }

  void openCurrencyPicker({required bool isFrom}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: panel,
      builder: (sheetContext) {
        String query = '';

        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = currencies.where((c) {
              return c.code
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  c.name
                      .toLowerCase()
                      .contains(query.toLowerCase());
            }).toList();

            return SafeArea(
              child: SizedBox(
                height:
                    MediaQuery.of(context).size.height * 0.72,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(18),
                      child: Text(
                        'Select Currency / اسعار وټاکئ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: TextField(
                        onChanged: (v) {
                          setModalState(() => query = v);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search currency...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: bg,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final c = filtered[index];

                          return ListTile(
                            leading: Text(
                              c.flag,
                              style:
                                  const TextStyle(fontSize: 30),
                            ),
                            title: Text(
                              '${c.code} - ${c.name}',
                            ),
                            subtitle: Text(
                              '1 ${c.code} = ${c.rate} AFN',
                            ),
                            onTap: () {
                              Navigator.pop(sheetContext);

                              setState(() {
                                if (isFrom) {
                                  from = c;
                                } else {
                                  to = c;
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: bottomIndex,
          children: [
            homePage(),
            converterPage(),
            marketPage(),
            historyPage(),
            settingsPage(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF061B35),
        indicatorColor: blue.withOpacity(0.22),
        selectedIndex: bottomIndex,
        onDestinationSelected: (index) {
          setState(() => bottomIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: cyan),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz),
            label: 'Converter',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart),
            label: 'Market',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget homePage() {
    final visible = currencies.where((c) {
      final matches =
          c.code.toLowerCase().contains(search.toLowerCase()) ||
          c.name.toLowerCase().contains(search.toLowerCase());

      if (!matches) return false;
      if (categoryIndex == 1) return favorites.contains(c.code);
      if (categoryIndex == 2) {
        return ['EUR', 'GBP', 'USD'].contains(c.code);
      }
      if (categoryIndex == 3) {
        return ['PKR', 'INR', 'CNY', 'JPY'].contains(c.code);
      }
      if (categoryIndex == 4) {
        return !['AFN', 'USD', 'EUR', 'GBP'].contains(c.code);
      }
      return true;
    }).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: header()),
        SliverToBoxAdapter(child: converterCard()),
        SliverToBoxAdapter(child: searchBar()),
        SliverToBoxAdapter(child: categoryTabs()),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'World Currencies (${visible.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => currencyRow(visible[index]),
            childCount: visible.length,
          ),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(22),
            child: Center(
              child: Text(
                'Closer to the World 🌍',
                style: TextStyle(color: cyan, fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget header() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF104B8A),
            Color(0xFF06162F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const Wrap(
            alignment: WrapAlignment.center,
            children: [
              Text(
                'Afghani ',
                style: TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'Exchange',
                style: TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                  color: cyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'د نړۍ ټول اسعار په یو ځای کې',
            style: TextStyle(fontSize: 19),
          ),
          const SizedBox(height: 5),
          const Text(
            'All World Currencies in One Place',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 8,
            alignment: WrapAlignment.center,
            children: [
              languageButton('🇦🇫 پښتو'),
              languageButton('🇦🇫 دري'),
              languageButton('🇬🇧 English'),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '🌍 Created by Abdullah ALOKOZAI',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget languageButton(String label) {
    final selected = label.contains(language);

    return OutlinedButton(
      onPressed: () {
        setState(() {
          if (label.contains('پښتو')) {
            language = 'پښتو';
          } else if (label.contains('دري')) {
            language = 'دري';
          } else {
            language = 'English';
          }
        });
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor:
            selected ? cyan.withOpacity(0.15) : bg,
        side: BorderSide(
          color: selected ? cyan : blue,
        ),
      ),
      child: Text(label),
    );
  }
