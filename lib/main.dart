@override
  Widget build(BuildContext context) {
    final labels = [
      tr(widget.lang, 'بازارونه', 'بازارها', 'Markets'),
      tr(widget.lang, 'نړیوال اسعار', 'ارزهای جهان', 'World'),
      tr(widget.lang, 'بدلون', 'تبدیل', 'Convert'),
      tr(widget.lang, 'تنظیمات', 'تنظیمات', 'Settings'),
      tr(widget.lang, 'جوړوونکی', 'سازنده', 'Developer'),
      tr(widget.lang, 'په اړه', 'درباره', 'About'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Afghani Exchange Pro',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: loading ? null : () => fetchRates(),
            icon: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: pageBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: page,
        onDestinationSelected: (v) => setState(() => page = v),
        destinations: [
          for (int i = 0; i < labels.length; i++)
            NavigationDestination(
              icon: Icon([
                Icons.storefront,
                Icons.public,
                Icons.currency_exchange,
                Icons.settings,
                Icons.person,
                Icons.info_outline,
              ][i]),
              label: labels[i],
            ),
        ],
      ),
    );
  }

  Widget marketsPage() {
    final rows = selectedRows();
    final marketData =
        Map<String, dynamic>.from(markets[market] ?? {});

    return RefreshIndicator(
      onRefresh: fetchRates,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          if (error != null) _notice(error!, Colors.red),
          _statusCard(),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: market,
            decoration: InputDecoration(
              labelText: tr(
                widget.lang,
                'بازار او سرچینه',
                'بازار و منبع',
                'Market / Source',
              ),
              border: const OutlineInputBorder(),
            ),
            items: [
              'bank',
              'sarai',
              'khorasan',
              'kandahar',
              'nangarhar',
            ].map((k) {
              return DropdownMenuItem(
                value: k,
                child: Text(marketName(k)),
              );
            }).toList(),
            onChanged: (v) {
              if (v != null) setState(() => market = v);
            },
          ),

          if (market == 'bank') ...[
            const SizedBox(height: 10),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'cash',
                  label: Text(
                    tr(widget.lang, 'نغدې', 'نقدی', 'Cash'),
                  ),
                ),
                ButtonSegment(
                  value: 'transfer',
                  label: Text(
                    tr(widget.lang, 'حواله', 'حواله', 'Transfer'),
                  ),
                ),
                ButtonSegment(
                  value: 'average',
                  label: Text(
                    tr(widget.lang, 'اوسط', 'اوسط', 'Average'),
                  ),
                ),
              ],
              selected: {bankType},
              onSelectionChanged: (s) {
                setState(() => bankType = s.first);
              },
            ),
          ],

          const SizedBox(height: 12),

          if (marketData['rateType'] == 'indicative')
            _notice(
              tr(
                widget.lang,
                'دا نرخونه اټکلي/بازاري دي؛ رسمي بانکي نرخونه نه دي.',
                'این نرخ‌ها تقریبی/بازاری‌اند و نرخ رسمی بانکی نیستند.',
                'These are indicative market rates, not official bank-dealer quotes.',
              ),
              Colors.orange,
            ),

          if (marketData['error'] != null && rows.isEmpty)
            _notice(
              tr(
                widget.lang,
                'د دې سرچینې نرخونه اوس ونه لوستل شول. وروسته بیا هڅه وکړئ.',
                'نرخ‌های این منبع فعلاً خوانده نشد. بعداً دوباره تلاش کنید.',
                'Rates from this source could not be read right now. Please try again later.',
              ),
              Colors.orange,
            ),

          if (rows.isEmpty && loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),

          if (rows.isEmpty && !loading)
            _empty(
              tr(
                widget.lang,
                'اوس مهال نرخونه نشته.',
                'فعلاً نرخی موجود نیست.',
                'No rates currently available.',
              ),
            ),

          if (rows.isNotEmpty) _rateTable(rows),

          const SizedBox(height: 16),

          Text(
            tr(
              widget.lang,
              'یادونه: د بازار نرخونه د سرچینې د تازه کولو له وخت سره تړلي دي.',
              'یادداشت: نرخ بازار وابسته به زمان به‌روزرسانی منبع است.',
              'Note: market rates depend on when the source provider updates its data.',
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _rateTable(List<Map<String, dynamic>> rows) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    tr(widget.lang, 'اسعار', 'ارز', 'Currency'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    tr(widget.lang, 'اخیستل', 'خرید', 'Buy'),
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    tr(widget.lang, 'پلورل', 'فروش', 'Sell'),
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          for (final r in rows)
            Builder(
              builder: (context) {
                final label = r['label']?.toString() ?? '';
                final code = codeOf(label);

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 11,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Row(
                          children: [
                            Text(
                              currencyFlags[code] ?? '💱',
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    code.isEmpty ? label : code,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    label,
                                    style: Theme.of(context)
                                        .textTheme.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Text(
                          money(r['buy'] as num?),
                          textAlign: TextAlign.end,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          money(r['sell'] as num?),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget worldPage() {
    final list = [...world]
      ..sort(
        (a, b) => (a['code'] ?? '')
            .toString()
            .compareTo((b['code'] ?? '').toString()),
      );

    return RefreshIndicator(
      onRefresh: fetchRates,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          _statusCard(),

          if (worldStale)
            _notice(
              tr(
                widget.lang,
                'د نړیوالو اسعارو سرچینه زاړه معلومات لري؛ دا نرخونه ژوندۍ/ثانیه‌يي نه دي.',
                'منبع ارز جهانی اطلاعات قدیمی دارد؛ این نرخ‌ها لحظه‌ای نیستند.',
                'World-rate provider data is stale; these are not live tick-by-tick rates.',
              ),
              Colors.orange,
            ),

          if (list.isEmpty)
            _empty(
              tr(
                widget.lang,
                'نړیوال نرخونه نشته.',
                'نرخ جهانی موجود نیست.',
                'World rates are unavailable.',
              ),
            ),

          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final item in list)
                  ListTile(
                    dense: true,
                    leading: Text(
                      currencyFlags[item['code']] ?? '🌐',
                      style: const TextStyle(fontSize: 23),
                    ),
                    title: Text(
                      '${item['code']}  ${currencyName(item['code'].toString(), widget.lang)}',
                    ),
                    trailing: Text(
                      '${money((item['afnPerUnit'] as num?)?.toDouble())} AFN',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget converterPage() {
    final codes = <String>{
      'AFN',
      ...world.map((e) => e['code'].toString()),
      ...selectedRows().map(
        (e) => codeOf(e['label']?.toString() ?? ''),
      ),
    }.where((e) => e.length == 3).toList()
      ..sort();

    if (!codes.contains(from)) from = 'USD';
    if (!codes.contains(to)) to = 'AFN';

    final result = converted();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _statusCard(),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  tr(
                    widget.lang,
                    'د اسعارو بدلون',
                    'تبدیل ارز',
                    'Currency Converter',
                  ),
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: amount,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: tr(
                      widget.lang,
                      'اندازه',
                      'مقدار',
                      'Amount',
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),

                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: from,
                  decoration: InputDecoration(
                    labelText: tr(widget.lang, 'له', 'از', 'From'),
                    border: const OutlineInputBorder(),
                  ),
                  items: codes.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Text('${currencyFlags[c] ?? '🌐'} $c'),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => from = v);
                  },
                ),

                IconButton(
                  onPressed: () {
                    setState(() {
                      final x = from;
                      from = to;
                      to = x;
                    });
                  },
                  icon: const Icon(Icons.swap_vert, size: 30),
                ),

                DropdownButtonFormField<String>(
                  value: to,
                  decoration: InputDecoration(
                    labelText: tr(widget.lang, 'ته', 'به', 'To'),
                    border: const OutlineInputBorder(),
                  ),
                  items: codes.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Text('${currencyFlags[c] ?? '🌐'} $c'),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => to = v);
                  },
                ),

                const SizedBox(height: 16),

                Text(
                  '${money(result)} $to',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),

                const SizedBox(height: 6),

                Text(
                  tr(
                    widget.lang,
                    'د ټاکل شوي بازار د نرخ له مخې؛ که نرخ نه وي، نړیوال مرجع نرخ کارېږي.',
                    'بر اساس نرخ بازار انتخاب‌شده؛ در نبود نرخ، نرخ مرجع جهانی استفاده می‌شود.',
                    'Uses the selected market rate where available; otherwise uses the world reference rate.',
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        DropdownButtonFormField<String>(
          value: market,
          decoration: InputDecoration(
            labelText: tr(
              widget.lang,
              'د محاسبې بازار',
              'بازار محاسبه',
              'Calculation market',
            ),
            border: const OutlineInputBorder(),
          ),
          items: [
            'bank',
            'sarai',
            'khorasan',
            'kandahar',
            'nangarhar',
          ].map((k) {
            return DropdownMenuItem(
              value: k,
              child: Text(marketName(k)),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) setState(() => market = v);
          },
        ),
      ],
    );
  }

  Widget settingsPage() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Text(
        tr(widget.lang, 'تنظیمات', 'تنظیمات', 'Settings'),
        style: Theme.of(context).textTheme.titleLarge,
      ),

      SwitchListTile(
        title: Text(
          tr(widget.lang, 'تیاره بڼه', 'حالت تاریک', 'Dark mode'),
        ),
        value: widget.dark,
        onChanged: widget.onTheme,
        secondary: const Icon(Icons.dark_mode),
      ),

      const SizedBox(height: 10),

      Text(
        tr(widget.lang, 'ژبه', 'زبان', 'Language'),
        style: Theme.of(context).textTheme.titleMedium,
      ),

      RadioListTile(
        value: 'ps',
        groupValue: widget.lang,
        title: const Text('پښتو'),
        onChanged: (v) => widget.onLanguage(v!),
      ),

      RadioListTile(
        value: 'fa',
        groupValue: widget.lang,
        title: const Text('دری'),
        onChanged: (v) => widget.onLanguage(v!),
      ),

      RadioListTile(
        value: 'en',
        groupValue: widget.lang,
        title: const Text('English'),
        onChanged: (v) => widget.onLanguage(v!),
      ),
    ],
  );

  Widget developerPage() => ListView(
    padding: const EdgeInsets.all(18),
    children: [
      const SizedBox(height: 12),

      Center(
        child: GestureDetector(
          onTap: choosePhoto,
          child: CircleAvatar(
            radius: 66,
            backgroundImage: photoPath != null
                ? FileImage(File(photoPath!))
                : null,
            child: photoPath == null
                ? const Icon(Icons.add_a_photo, size: 42)
                : null,
          ),
        ),
      ),

      const SizedBox(height: 12),

      Center(
        child: Text(
          'Abdullah Eman',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),

      Center(
        child: Text(
          tr(
            widget.lang,
            'د اپلیکیشن جوړوونکی',
            'سازنده اپلیکیشن',
            'App Developer',
          ),
        ),
      ),

      const SizedBox(height: 14),

      OutlinedButton.icon(
        onPressed: choosePhoto,
        icon: const Icon(Icons.photo_library),
        label: Text(
          tr(
            widget.lang,
            'عکس بدلول',
            'تغییر عکس',
            'Change Photo',
          ),
        ),
      ),

      Text(
        tr(
          widget.lang,
          'عکس یوازې په همدې موبایل کې ساتل کېږي او د اپ له بندېدو وروسته هم پاتې کېږي.',
          'عکس فقط در همین موبایل ذخیره می‌شود و پس از بستن برنامه باقی می‌ماند.',
          'The photo is stored locally on this device and remains after the app closes.',
        ),
      ),
    ],
  );

  Widget aboutPage() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Text(
        tr(
          widget.lang,
          'د Afghani Exchange Pro په اړه',
          'درباره Afghani Exchange Pro',
          'About Afghani Exchange Pro',
        ),
        style: Theme.of(context).textTheme.titleLarge,
      ),

      const SizedBox(height: 12),

      Text(
        tr(
          widget.lang,
          'دا اپ د افغانستان د بېلابېلو بازارونو او نړیوالو اسعارو د معلوماتو د کتلو او د اسعارو د بدلون لپاره جوړ شوی دی.',
          'این برنامه برای مشاهده نرخ بازارهای مختلف افغانستان، ارزهای جهانی و تبدیل ارز ساخته شده است.',
          'This app displays rates from several Afghan market sources, world reference currencies, and currency conversions.',
        ),
      ),

      const SizedBox(height: 12),

      const Text('Version 7'),

      const SizedBox(height: 8),

      Text(
        tr(
          widget.lang,
          'د نرخونو دقت او تازه‌والی د اصلي سرچینو په معلوماتو پورې تړلی دی. د معاملې مخکې نرخ له صراف سره تایید کړئ.',
          'دقت و تازگی نرخ‌ها به اطلاعات منابع اصلی بستگی دارد. پیش از معامله نرخ را با صراف تأیید کنید.',
          'Accuracy and freshness depend on upstream providers. Confirm a rate with the exchange dealer before making a transaction.',
        ),
      ),
    ],
  );

  Widget _statusCard() => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(
            worldStale ? Icons.warning_amber : Icons.check_circle,
            color: worldStale ? Colors.orange : Colors.green,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(
                    widget.lang,
                    'د معلوماتو حالت',
                    'وضعیت اطلاعات',
                    'Data status',
                  ),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                Text(
                  worldUpdated == null
                      ? tr(
                          widget.lang,
                          'د نړیوالو سرچینو وخت معلوم نه دی',
                          'زمان منبع جهانی نامشخص است',
                          'World source time unavailable',
                        )
                      : '${tr(widget.lang, 'د نړیوالو سرچینو تازه کېدل', 'به‌روزرسانی منبع جهانی', 'World source update')}: ${worldUpdated!.toLocal()}',
                ),

                if (worldAge != null)
                  Text(
                    '${tr(widget.lang, 'د معلوماتو عمر', 'سن اطلاعات', 'Data age')}: ${worldAge! ~/ 60}h ${worldAge! % 60}m',
                  ),

                if (checkedAt != null)
                  Text(
                    '${tr(widget.lang, 'API کتلی', 'بررسی API', 'API checked')}: ${checkedAt!.toLocal()}',
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _notice(String text, Color color) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withOpacity(.12),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(text),
  );

  Widget _empty(String text) => Padding(
    padding: const EdgeInsets.all(24),
    child: Center(
      child: Text(text, textAlign: TextAlign.center),
    ),
  );
}
