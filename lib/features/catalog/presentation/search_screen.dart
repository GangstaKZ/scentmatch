import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/localization/app_strings.dart';
import '../../../shared/widgets/async_panel.dart';
import '../../../shared/widgets/perfume_card.dart';
import '../domain/search_filter.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final query = TextEditingController();
  String family = 'all', brand = 'all', gender = 'all', price = 'all';
  @override
  void dispose() {
    query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          title:
              Text(context.tr('Откройте свой аромат', 'Discover your scent'))),
      body: ListView(padding: const EdgeInsets.all(24), children: [
        TextField(
            controller: query,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
                hintText: context.tr(
                    'Например, Byredo или Sauvage', 'Try Byredo or Sauvage'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: query.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: context.tr('Очистить', 'Clear'),
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          query.clear();
                          setState(() {});
                        }))),
        const SizedBox(height: 18),
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: [
              'all',
              'woody',
              'floral',
              'fresh',
              'amber',
              'gourmand'
            ]
                    .map((f) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                            label: Text(context.label(f)),
                            selected: family == f,
                            onSelected: (_) => setState(() => family = f))))
                    .toList())),
        const SizedBox(height: 16),
        AsyncPanel(
            value: ref.watch(catalogProvider),
            retry: () => ref.invalidate(catalogProvider),
            builder: (catalog) {
              final brands = catalog.map((p) => p.brand).toSet().toList()
                ..sort();
              final filter = SearchFilter(
                  query: query.text,
                  family: family,
                  brand: brand,
                  gender: gender,
                  priceRange: price);
              final results = catalog.where(filter.matches).toList();
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(spacing: 10, runSpacing: 10, children: [
                      _dropdown(context.tr('Бренд', 'Brand'), brand,
                          ['all', ...brands], (v) => setState(() => brand = v),
                          raw: true),
                      _dropdown(
                          context.tr('Для кого', 'For whom'),
                          gender,
                          ['all', 'female', 'male', 'unisex'],
                          (v) => setState(() => gender = v)),
                      _dropdown(
                          context.tr('Бюджет', 'Budget'),
                          price,
                          ['all', 'budget', 'mid', 'luxury'],
                          (v) => setState(() => price = v)),
                    ]),
                    const SizedBox(height: 20),
                    Row(children: [
                      Expanded(
                          child: Text(
                              context.tr('Найдено: ${results.length}',
                                  '${results.length} results'),
                              style: Theme.of(context).textTheme.bodySmall)),
                      TextButton(
                          onPressed: () => setState(() {
                                family = brand = gender = price = 'all';
                                query.clear();
                              }),
                          child: Text(context.tr('Сбросить', 'Reset')))
                    ]),
                    const SizedBox(height: 12),
                    if (results.isEmpty)
                      EmptyPanel(
                          icon: Icons.search_off,
                          title: context.tr('Ничего не найдено', 'No matches'),
                          subtitle: context.tr(
                              'Попробуйте другой запрос или снимите фильтры.',
                              'Try another search or clear your filters.'))
                    else
                      PerfumeGrid(perfumes: results),
                  ]);
            }),
        const SizedBox(height: 24),
      ]));
  Widget _dropdown(String label, String value, List<String> options,
          ValueChanged<String> changed, {bool raw = false}) =>
      SizedBox(
          width: 190,
          child: DropdownButtonFormField<String>(
              value: options.contains(value) ? value : 'all',
              isExpanded: true,
              decoration: InputDecoration(labelText: label),
              items: options
                  .map((o) => DropdownMenuItem(
                      value: o,
                      child: Text(raw && o != 'all' ? o : context.label(o),
                          overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (v) => changed(v!)));
}
