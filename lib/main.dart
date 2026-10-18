import 'package:flutter/material.dart';

void main() {
  runApp(const ExchangeApp());
}

class Currency {
  final String code;
  final String name;
  final String flag;
  final double rate;

  const Currency({
    required this.code,
    required this.name,
    required this.flag,
    required this.rate,
  });
}

const List<Currency> currencies = [
  Currency(code: 'AFN', name: 'Afghan Afghani', flag: '🇦🇫', rate: 70.0),
  Currency(code: 'USD', name: 'US Dollar', flag: '🇺🇸', rate: 1.0),
  Currency(code: 'EUR', name: 'Euro', flag: '🇪🇺', rate: 0.86),
  Currency(code: 'GBP', name: 'British Pound', flag: '🇬🇧', rate: 0.75),
  Currency(code: 'PKR', name: 'Pakistani Rupee', flag: '🇵🇰', rate: 280.0),
  Currency(code: 'IRR', name: 'Iranian Rial', flag: '🇮🇷', rate: 42000.0),
  Currency(code: 'INR', name: 'Indian Rupee', flag: '🇮🇳', rate: 88.0),
  Currency(code: 'CNY', name: 'Chinese Yuan', flag: '🇨🇳', rate: 7.1),
  Currency(code: 'TRY', name: 'Turkish Lira', flag: '🇹🇷', rate: 42.0),
  Currency(code: 'SAR', name: 'Saudi Riyal', flag: '🇸🇦', rate: 3.75),
  Currency(code: 'AED', name: 'UAE Dirham', flag: '🇦🇪', rate: 3.67),
  Currency(code: 'QAR', name: 'Qatari Riyal', flag: '🇶🇦', rate: 3.64),
  Currency(code: 'KWD', name: 'Kuwaiti Dinar', flag: '🇰🇼', rate: 0.31),
  Currency(code: 'CAD', name: 'Canadian Dollar', flag: '🇨🇦', rate: 1.38),
  Currency(code: 'AUD', name: 'Australian Dollar', flag: '🇦🇺', rate: 1.52),
  Currency(code: 'JPY', name: 'Japanese Yen', flag: '🇯🇵', rate: 150.0),
  Currency(code: 'CHF', name: 'Swiss Franc', flag: '🇨🇭', rate: 0.80),
  Currency(code: 'RUB', name: 'Russian Ruble', flag: '🇷🇺', rate: 82.0),
  Currency(code: 'BDT', name: 'Bangladeshi Taka', flag: '🇧🇩', rate: 122.0),
  Currency(code: 'LKR', name: 'Sri Lankan Rupee', flag: '🇱🇰', rate: 300.0),
  Currency(code: 'NPR', name: 'Nepalese Rupee', flag: '🇳🇵', rate: 140.0),
  Currency(code: 'MYR', name: 'Malaysian Ringgit', flag: '🇲🇾', rate: 4.25),
  Currency(code: 'IDR', name: 'Indonesian Rupiah', flag: '🇮🇩', rate: 16500.0),
  Currency(code: 'THB', name: 'Thai Baht', flag: '🇹🇭', rate: 33.0),
  Currency(code: 'SGD', name: 'Singapore Dollar', flag: '🇸🇬', rate: 1.29),
  Currency(code: 'NZD', name: 'New Zealand Dollar', flag: '🇳🇿', rate: 1.75),
  Currency(code: 'HKD', name: 'Hong Kong Dollar', flag: '🇭🇰', rate: 7.8),
  Currency(code: 'KRW', name: 'South Korean Won', flag: '🇰🇷', rate: 1400.0),
  Currency(code: 'EGP', name: 'Egyptian Pound', flag: '🇪🇬', rate: 48.0),
  Currency(code: 'IQD', name: 'Iraqi Dinar', flag: '🇮🇶', rate: 1310.0),
  Currency(code: 'KWD', name: 'Kuwaiti Dinar', flag: '🇰🇼', rate: 0.31),
  Currency(code: 'OMR', name: 'Omani Rial', flag: '🇴🇲', rate: 0.38),
  Currency(code: 'BHD', name: 'Bahraini Dinar', flag: '🇧🇭', rate: 0.38),
  Currency(code: 'JOD', name: 'Jordanian Dinar', flag: '🇯🇴', rate: 0.71),
  Currency(code: 'ZAR', name: 'South African Rand', flag: '🇿🇦', rate: 17.5),
  Currency(code: 'BRL', name: 'Brazilian Real', flag: '🇧🇷', rate: 5.4),
  Currency(code: 'MXN', name: 'Mexican Peso', flag: '🇲🇽', rate: 18.5),
  Currency(code: 'ARS', name: 'Argentine Peso', flag: '🇦🇷', rate: 1200.0),
  Currency(code: 'SEK', name: 'Swedish Krona', flag: '🇸🇪', rate: 9.5),
  Currency(code: 'NOK', name: 'Norwegian Krone', flag: '🇳🇴', rate: 10.0),
  Currency(code: 'DKK', name: 'Danish Krone', flag: '🇩🇰', rate: 6.4),
];

class ExchangeApp extends StatelessWidget {
  const ExchangeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afghani Exchange',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00C9A7),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF071521),
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
  int _page = 0;
  int _fromIndex = 0;
  int _toIndex = 1;
  double _amount = 1000;
  String _search = '';
  final TextEditingController _amountController =
      TextEditingController(text: '1000');
  final TextEditingController _searchController = TextEditingController();
  final List<String> _history = [];
  final Set<String> _favorites = {'USD', 'EUR', 'PKR'};

  Currency get _from => currencies[_fromIndex];
  Currency get _to => currencies[_toIndex];

  double get _result => _amount / _from.rate * _to.rate;

  @override
  void dispose() {
    _amountController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _swap() {
    setState(() {
      final old = _fromIndex;
      _fromIndex = _toIndex;
      _toIndex = old;
    });
  }

  void _convert() {
    setState(() {
      _history.insert(
        0,
        '${_amount.toStringAsFixed(2)} ${_from.code} = '
        '${_result.toStringAsFixed(2)} ${_to.code}',
      );
      _page = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2231),
        title: const Row(
          children: [
            Icon(Icons.currency_exchange, color: Color(0xFF00D6AE)),
            SizedBox(width: 10),
            Text(
              'Afghani Exchange',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() => _page = 3),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: IndexedStack(
        index: _page,
        children: [
          _homePage(),
          _currenciesPage(),
          _historyPage(),
          _settingsPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _page,
        onDestinationSelected: (value) => setState(() => _page = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.swap_horiz),
            label: 'تبادله',
          ),
          NavigationDestination(
            icon: Icon(Icons.public),
            label: 'پیسې',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'تاریخچه',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'تنظیمات',
          ),
        ],
      ),
    );
  }

  Widget _homePage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF123C4C), Color(0xFF087E80)],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'د اسعارو تبادله',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'خپل اسعار په اسانۍ بدل کړئ',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'د خپلې خوښې اسعار وټاکئ او اندازه ولیکئ.',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _sectionTitle('د تبادلې حساب'),
        const SizedBox(height: 12),
        _currencyCard(
          title: 'له دې اسعارو',
          index: _fromIndex,
          onChanged: (value) => setState(() => _fromIndex = value),
          child: TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'اندازه ولیکئ',
            ),
            onChanged: (value) {
              setState(() {
                _amount = double.tryParse(value) ?? 0;
              });
            },
          ),
        ),
        Center(
          child: IconButton.filled(
            onPressed: _swap,
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF00BFA5),
              foregroundColor: Colors.black,
            ),
            icon: const Icon(Icons.swap_vert, size: 28),
          ),
        ),
        _currencyCard(
          title: 'دې اسعارو ته',
          index: _toIndex,
          onChanged: (value) => setState(() => _toIndex = value),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _result.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00D6AE),
                ),
              ),
              Text(
                '${_to.code} — ${_to.name}',
                style: const TextStyle(color: Colors.white60),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: _convert,
            icon: const Icon(Icons.currency_exchange),
            label: const Text(
              'تبادله حساب کړه',
              style: TextStyle(fontSize: 17),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF00BFA5),
              foregroundColor: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 22),
        _sectionTitle('د خوښې اسعار'),
        const SizedBox(height: 8),
        ...currencies
            .where((c) => _favorites.contains(c.code))
            .map(_currencyTile),
        const SizedBox(height: 20),
        const Text(
          'یادونه: د تبادلې نرخونه د نمونې لپاره دي، ژوندی بازار نرخونه نه دي.',
          style: TextStyle(color: Colors.orangeAccent, fontSize: 12),
        ),
      ],
    );
  }

  Widget _currencyCard({
    required String title,
    required int index,
    required ValueChanged<int> onChanged,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF102635),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white60)),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: index,
            isExpanded: true,
            dropdownColor: const Color(0xFF102635),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            items: List.generate(currencies.length, (i) {
              final c = currencies[i];
              return DropdownMenuItem(
                value: i,
                child: Text('${c.flag}  ${c.code} — ${c.name}'),
              );
            }),
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
          ),
          const Divider(color: Colors.white12),
          child,
        ],
      ),
    );
  }

  Widget _currenciesPage() {
    final filtered = currencies.where((c) {
      final query = _search.toLowerCase();
      return c.name.toLowerCase().contains(query) ||
          c.code.toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'د اسعارو لټون...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: const Color(0xFF102635),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) => setState(() => _search = value),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) => _currencyTile(filtered[index]),
          ),
        ),
      ],
    );
  }

  Widget _currencyTile(Currency currency) {
    final isFavorite = _favorites.contains(currency.code);

    return Card(
      color: const Color(0xFF102635),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: ListTile(
        leading: Text(currency.flag, style: const TextStyle(fontSize: 28)),
        title: Text(
          currency.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(currency.code),
        trailing: IconButton(
          onPressed: () {
            setState(() {
              if (isFavorite) {
                _favorites.remove(currency.code);
              } else {
                _favorites.add(currency.code);
              }
            });
          },
          icon: Icon(
            isFavorite ? Icons.star : Icons.star_border,
            color: isFavorite ? Colors.amber : Colors.white54,
          ),
        ),
      ),
    );
  }

  Widget _historyPage() {
    if (_history.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 65, color: Colors.white30),
            SizedBox(height: 12),
            Text(
              'تر اوسه د تبادلې تاریخچه نشته',
              style: TextStyle(color: Colors.white60),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionTitle('د تبادلې تاریخچه'),
            TextButton(
              onPressed: () => setState(() => _history.clear()),
              child: const Text('پاکول'),
            ),
          ],
        ),
        ..._history.map(
          (item) => Card(
            color: const Color(0xFF102635),
            child: ListTile(
              leading: const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF00D6AE),
              ),
              title: Text(item),
            ),
          ),
        ),
      ],
    );
  }

  Widget _settingsPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 10),
        const CircleAvatar(
          radius: 42,
          backgroundColor: Color(0xFF123C4C),
          child: Icon(
            Icons.currency_exchange,
            size: 45,
            color: Color(0xFF00D6AE),
          ),
        ),
        const SizedBox(height: 14),
        const Center(
          child: Text(
            'Afghani Exchange',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 24),
        _settingTile(Icons.language, 'ژبه', 'پښتو'),
        _settingTile(Icons.palette_outlined, 'بڼه', 'تیاره بڼه'),
        _settingTile(Icons.notifications_outlined, 'خبرتیاوې', 'فعالې'),
        _settingTile(Icons.info_outline, 'د اپلیکیشن په اړه', 'نسخه 1.0.0'),
        const SizedBox(height: 20),
        const Text(
          'دا اپلیکیشن د اسعارو د تبادلې د نمونې لپاره جوړ شوی دی.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54),
        ),
      ],
    );
  }

  Widget _settingTile(IconData icon, String title, String subtitle) {
    return Card(
      color: const Color(0xFF102635),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF00D6AE)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
