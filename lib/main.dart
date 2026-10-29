import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const AfghaniExchangeApp());
}

class Currency {
  final String code;
  final String name;
  final String flag;

  const Currency(this.code, this.name, this.flag);
}

const currencies = <Currency>[
  Currency('AFN', 'افغانۍ', '🇦🇫'),
  Currency('USD', 'امریکايي ډالر', '🇺🇸'),
  Currency('EUR', 'یورو', '🇪🇺'),
  Currency('PKR', 'پاکستانۍ روپۍ', '🇵🇰'),
  Currency('INR', 'هندي روپۍ', '🇮🇳'),
  Currency('AED', 'اماراتي درهم', '🇦🇪'),
  Currency('SAR', 'سعودي ریال', '🇸🇦'),
  Currency('TRY', 'ترکي لیره', '🇹🇷'),
  Currency('CNY', 'چینایي یوان', '🇨🇳'),
  Currency('GBP', 'برتانوي پونډ', '🇬🇧'),
  Currency('CAD', 'کاناډایي ډالر', '🇨🇦'),
  Currency('AUD', 'اسټرالیايي ډالر', '🇦🇺'),
  Currency('JPY', 'جاپاني ین', '🇯🇵'),
  Currency('CHF', 'سویسي فرانک', '🇨🇭'),
  Currency('QAR', 'قطري ریال', '🇶🇦'),
  Currency('KWD', 'کویتي دینار', '🇰🇼'),
  Currency('OMR', 'عماني ریال', '🇴🇲'),
  Currency('BHD', 'بحریني دینار', '🇧🇭'),
  Currency('IRR', 'ایراني ریال', '🇮🇷'),
  Currency('RUB', 'روسي روبل', '🇷🇺'),
  Currency('MYR', 'مالیزیايي رینګټ', '🇲🇾'),
  Currency('THB', 'تایلنډي بات', '🇹🇭'),
  Currency('IDR', 'اندونیزیایي روپیه', '🇮🇩'),
  Currency('BDT', 'بنګله دېشي ټکه', '🇧🇩'),
  Currency('NPR', 'نېپالي روپۍ', '🇳🇵'),
  Currency('LKR', 'سریلانکایي روپۍ', '🇱🇰'),
  Currency('EGP', 'مصري پونډ', '🇪🇬'),
  Currency('ZAR', 'سویلي افریقایي رنډ', '🇿🇦'),
  Currency('SEK', 'سویډني کرونا', '🇸🇪'),
  Currency('NOK', 'ناروېژي کرونا', '🇳🇴'),
  Currency('DKK', 'ډنمارکي کرونا', '🇩🇰'),
  Currency('NZD', 'نیوزیلنډي ډالر', '🇳🇿'),
  Currency('SGD', 'سنګاپوري ډالر', '🇸🇬'),
  Currency('HKD', 'هانګ کانګي ډالر', '🇭🇰'),
  Currency('KRW', 'کوریایي وان', '🇰🇷'),
  Currency('UZS', 'ازبکستاني سوم', '🇺🇿'),
  Currency('TJS', 'تاجکستاني سوموني', '🇹🇯'),
  Currency('KZT', 'قزاقستاني ټینګي', '🇰🇿'),
  Currency('AZN', 'اذربایجاني منات', '🇦🇿'),
  Currency('GEL', 'ګرجستاني لاري', '🇬🇪'),
];

class AfghaniExchangeApp extends StatefulWidget {
  const AfghaniExchangeApp({super.key});

  @override
  State<AfghaniExchangeApp> createState() => _AfghaniExchangeAppState();
}

class _AfghaniExchangeAppState extends State<AfghaniExchangeApp> {
  ThemeMode themeMode = ThemeMode.light;
  String language = 'پښتو';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afghani Exchange',
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        brightness: Brightness.dark,
      ),
      home: HomePage(
        language: language,
        onLanguageChanged: (value) {
          setState(() => language = value);
        },
        onThemeChanged: (dark) {
          setState(() {
            themeMode = dark ? ThemeMode.dark : ThemeMode.light;
          });
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String language;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<bool> onThemeChanged;

  const HomePage({
    super.key,
    required this.language,
    required this.onLanguageChanged,
    required this.onThemeChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String from = 'AFN';
  String to = 'USD';

  double rate = 0;
  double amount = 1;

  bool loading = false;
  String? error;
  DateTime? lastUpdated;

  final TextEditingController amountController =
      TextEditingController(text: '1');

  final TextEditingController searchController = TextEditingController();

  Timer? refreshTimer;

  final Set<String> favorites = {'USD', 'PKR', 'INR', 'AED', 'SAR'};

  final List<String> history = [];

  @override
  void initState() {
    super.initState();

    loadRate();

    refreshTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => loadRate(),
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    amountController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadRate() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      /*
       * IMPORTANT:
       * Do NOT put your private FXRatesAPI key here.
       *
       * Later we will connect this app to a secure server endpoint.
       */

      final url = Uri.parse(
        'https://api.fxratesapi.com/latest'
        '?base=$from'
        '&currencies=$to'
        '&resolution=1m'
        '&amount=1'
        '&places=8'
        '&format=json',
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final data = jsonDecode(response.body);

      if (data['rates'] == null) {
        throw Exception('نرخ ترلاسه نه شو');
      }

      final rates = data['rates'] as Map<String, dynamic>;

      if (!rates.containsKey(to)) {
        throw Exception('د $to نرخ موجود نه دی');
      }

      final newRate = (rates[to] as num).toDouble();

      setState(() {
        rate = newRate;
        lastUpdated = DateTime.now();
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = 'د نرخ ترلاسه کولو ستونزه ده';
      });
    }
  }

  void swapCurrencies() {
    setState(() {
      final oldFrom = from;
      from = to;
      to = oldFrom;
    });

    loadRate();
  }

  void convertAmount(String value) {
    final parsed = double.tryParse(value.replaceAll(',', ''));

    if (parsed != null) {
      setState(() {
        amount = parsed;
      });
    }
  }

  String resultText() {
    final result = amount * rate;

    if (result >= 1000000) {
      return result.toStringAsFixed(2);
    }

    if (result >= 1000) {
      return result.toStringAsFixed(2);
    }

    if (result >= 1) {
      return result.toStringAsFixed(4);
    }

    return result.toStringAsFixed(6);
  }

  void addHistory() {
    final text =
        '${amount.toStringAsFixed(2)} $from = ${resultText()} $to';

    setState(() {
      history.insert(0, text);

      if (history.length > 20) {
        history.removeLast();
      }
    });
  }

  String currencyName(Currency currency) {
    if (widget.language == 'English') {
      return currency.code;
    }

    if (widget.language == 'دری') {
      return currency.code;
    }

    return currency.name;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = currencies.where((currency) {
      final search = searchController.text.toLowerCase();

      return currency.code.toLowerCase().contains(search) ||
          currency.name.toLowerCase().contains(search);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Afghani Exchange',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: widget.onLanguageChanged,
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'پښتو',
                child: Text('🇦🇫 پښتو'),
              ),
              PopupMenuItem(
                value: 'دری',
                child: Text('🇦🇫 دری'),
              ),
              PopupMenuItem(
                value: 'English',
                child: Text('🇬🇧 English'),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadRate,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTopCard(),

            const SizedBox(height: 16),

            _buildConverter(),

            const SizedBox(height: 20),

            _buildCurrencySearch(),

            const SizedBox(height: 10),

            Text(
              widget.language == 'English'
                  ? 'Currencies'
                  : widget.language == 'دری'
                      ? 'ارزها'
                      : 'اسعار',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            ...filtered.map(
              (currency) => _currencyTile(currency),
            ),

            const SizedBox(height: 20),

            if (history.isNotEmpty) _buildHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCard() {
    return Card(
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.secondaryContainer,
            ],
          ),
        ),
        child: Column(
          children: [
            const Text(
              '🇦🇫',
              style: TextStyle(fontSize: 44),
            ),

            const SizedBox(height: 8),

            Text(
              widget.language == 'English'
                  ? 'Afghani Exchange'
                  : widget.language == 'دری'
                      ? 'تبدیل اسعار'
                      : 'د اسعارو تبدیل',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              loading
                  ? 'د نرخ تازه کول روان دي...'
                  : lastUpdated == null
                      ? 'د نرخ ترلاسه کول'
                      : 'هره دقیقه تازه کېږي',
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.circle,
                  size: 10,
                  color: loading ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 6),
                Text(
                  loading ? 'Loading' : 'Live',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConverter() {
    final fromCurrency =
        currencies.firstWhere((c) => c.code == from);

    final toCurrency =
        currencies.firstWhere((c) => c.code == to);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _currencySelector(
                    fromCurrency,
                    true,
                  ),
                ),

                const SizedBox(width: 8),

                IconButton.filledTonal(
                  onPressed: swapCurrencies,
                  icon: const Icon(Icons.swap_horiz),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: _currencySelector(
                    toCurrency,
                    false,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            TextField(
              controller: amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: convertAmount,
              decoration: InputDecoration(
                labelText: 'مقدار',
                prefixIcon: const Icon(Icons.calculate_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
              ),
              child: Column(
                children: [
                  Text(
                    '$amount $fromCurrency.flag $from',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Icon(Icons.arrow_downward),

                  const SizedBox(height: 8),

                  Text(
                    '${resultText()} ${toCurrency.flag} $to',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (error != null)
                    Text(
                      error!,
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      loadRate();
                      addHistory();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('تازه کول'),
                  ),
                ),
              ],
            ),

            if (lastUpdated != null) ...[
              const SizedBox(height: 8),
              Text(
                'Last update: ${lastUpdated!.hour.toString().padLeft(2, '0')}:'
                '${lastUpdated!.minute.toString().padLeft(2, '0')}:'
                '${lastUpdated!.second.toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _currencySelector(
    Currency currency,
    bool isFrom,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        _showCurrencyPicker(isFrom);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).dividerColor,
          ),
        ),
        child: Column(
          children: [
            Text(
              currency.flag,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 4),
            Text(
              currency.code,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencySearch() {
    return TextField(
      controller: searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'د اسعارو لټون...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: searchController.text.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  searchController.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.clear),
              ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }

  Widget _currencyTile(Currency currency) {
    final isFavorite = favorites.contains(currency.code);
    final selected =
        currency.code == from || currency.code == to;

    return Card(
      elevation: 0,
      child: ListTile(
        leading: Text(
          currency.flag,
          style: const TextStyle(fontSize: 30),
        ),
        title: Text(
          currency.code,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          currencyName(currency),
        ),
        trailing: IconButton(
          onPressed: () {
            setState(() {
              if (isFavorite) {
                favorites.remove(currency.code);
              } else {
                favorites.add(currency.code);
              }
            });
          },
          icon: Icon(
            isFavorite
                ? Icons.star
                : Icons.star_border,
          ),
        ),
        selected: selected,
        onTap: () {
          setState(() {
            if (from == 'AFN') {
              to = currency.code;
            } else {
              from = currency.code;
            }
          });

          loadRate();
        },
      ),
    );
  }

  Widget _buildHistory() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history),
                const SizedBox(width: 8),
                const Text(
                  'د تبدیل تاریخچه',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    setState(() {
                      history.clear();
                    });
                  },
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const Divider(),
            ...history.map(
              (item) => ListTile(
                dense: true,
                leading: const Icon(
                  Icons.currency_exchange,
                ),
                title: Text(item),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(bool isFrom) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        String search = '';

        return StatefulBuilder(
          builder: (context, setModalState) {
            final list = currencies.where((currency) {
              return currency.code
                      .toLowerCase()
                      .contains(search.toLowerCase()) ||
                  currency.name
                      .toLowerCase()
                      .contains(search.toLowerCase());
            }).toList();

            return SizedBox(
              height: MediaQuery.of(context).size.height * .75,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      autofocus: true,
                      onChanged: (value) {
                        setModalState(() {
                          search = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'د اسعارو لټون...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (_, index) {
                        final currency = list[index];

                        return ListTile(
                          leading: Text(
                            currency.flag,
                            style:
                                const TextStyle(fontSize: 28),
                          ),
                          title: Text(
                            currency.code,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(currency.name),
                          onTap: () {
                            setState(() {
                              if (isFrom) {
                                from = currency.code;
                              } else {
                                to = currency.code;
                              }
                            });

                            Navigator.pop(context);
                            loadRate();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
