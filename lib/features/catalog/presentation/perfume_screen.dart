import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/app_config.dart';
import '../../../core/providers.dart';
import '../../../core/localization/app_strings.dart';
import '../../../shared/widgets/action_button.dart';
import '../../../shared/widgets/async_panel.dart';
import '../../../shared/widgets/perfume_card.dart';
import '../../collection/domain/collection_item.dart';
import '../../collection/presentation/item_editor.dart';
import '../../reviews/presentation/reviews_section.dart';
import '../domain/perfume.dart';

class PerfumeScreen extends ConsumerWidget {
  const PerfumeScreen({super.key, required this.id, this.heroTag});
  final String id;
  final String? heroTag;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
      appBar: AppBar(
          title: Text(context.tr('Об аромате', 'Fragrance details')),
          leading: IconButton(
              tooltip: context.tr('Назад', 'Back'),
              icon: const Icon(Icons.arrow_back),
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/home'))),
      body: ListView(padding: const EdgeInsets.all(24), children: [
        AsyncPanel(
            value: ref.watch(catalogProvider),
            retry: () => ref.invalidate(catalogProvider),
            builder: (catalog) {
              final matches = catalog.where((p) => p.id == id);
              if (matches.isEmpty) {
                return EmptyPanel(
                    icon: Icons.search_off,
                    title:
                        context.tr('Аромат не найден', 'Fragrance not found'),
                    subtitle: context.tr('Возможно, его удалили из каталога.',
                        'It may have been removed from the catalog.'));
              }
              final perfume = matches.first;
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                        tag: heroTag ?? 'bottle_${id}_detail',
                        child: BottleArt(perfume: perfume, height: 300)),
                    const SizedBox(height: 24),
                    Text(perfume.brand.toUpperCase(),
                        style: TextStyle(
                            letterSpacing: 2,
                            color: Theme.of(context).colorScheme.primary)),
                    const SizedBox(height: 8),
                    Text(perfume.name,
                        style: const TextStyle(
                            fontFamily: 'CormorantGaramond', fontSize: 38)),
                    const SizedBox(height: 16),
                    Wrap(spacing: 8, children: [
                      Chip(label: Text(context.label(perfume.family))),
                      Chip(label: Text(context.label(perfume.gender))),
                      Chip(label: Text(context.label(perfume.priceRange)))
                    ]),
                    const SizedBox(height: 12),
                    Text(
                        context.tr('Ориентир: ${perfume.price} ₽ / 50 мл',
                            'Guide price: ₽${perfume.price} / 50 ml'),
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 6),
                    Text(
                        context.tr(
                            'Демонстрационные цены и характеристики; звучание индивидуально.',
                            'Illustrative prices and characteristics; performance varies.'),
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 24),
                    AsyncPanel(
                        value: ref.watch(collectionProvider),
                        retry: () => ref.invalidate(collectionProvider),
                        builder: (items) {
                          final saved = items.where((i) => i.perfumeId == id);
                          final current = saved.isEmpty ? null : saved.first;
                          return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ActionButton(
                                    label: current?.type ==
                                            CollectionType.collection
                                        ? context.tr('В коллекции · изменить',
                                            'In collection · edit')
                                        : context.tr('Добавить в коллекцию',
                                            'Add to collection'),
                                    icon: Icons.inventory_2_outlined,
                                    action: () async {
                                      if (current?.type ==
                                          CollectionType.collection) {
                                        await editCollectionItem(
                                            context, current!);
                                        return;
                                      }
                                      await ref.read(actionsProvider).saveItem(
                                          CollectionItem(
                                              perfumeId: id,
                                              type: CollectionType.collection,
                                              addedAt: current?.addedAt ??
                                                  DateTime.now().toUtc(),
                                              rating: current?.rating ?? 0,
                                              note: current?.note ?? ''));
                                    }),
                                const SizedBox(height: 10),
                                ActionButton(
                                    tonal: true,
                                    icon:
                                        current?.type == CollectionType.wishlist
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                    label:
                                        current?.type == CollectionType.wishlist
                                            ? context.tr(
                                                'В Wishlist · изменить',
                                                'In Wishlist · edit')
                                            : context.tr(
                                                'Хочу попробовать · Wishlist',
                                                'Want to try · Wishlist'),
                                    action: () async {
                                      if (current?.type ==
                                          CollectionType.wishlist) {
                                        await editCollectionItem(
                                            context, current!);
                                        return;
                                      }
                                      await ref.read(actionsProvider).saveItem(
                                          CollectionItem(
                                              perfumeId: id,
                                              type: CollectionType.wishlist,
                                              addedAt: current?.addedAt ??
                                                  DateTime.now().toUtc(),
                                              rating: current?.rating ?? 0,
                                              note: current?.note ?? ''));
                                    }),
                                if (current != null)
                                  Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Text(
                                          context.tr(
                                              'Аромат находится на одной полке. Другая кнопка перенесёт его.',
                                              'A fragrance belongs to one shelf. The other button moves it.'),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall)),
                              ]);
                        }),
                    const SizedBox(height: 12),
                    ActionButton(
                        tonal: true,
                        icon: Icons.open_in_new,
                        label: context.tr('Где купить', 'Where to buy'),
                        action: () => _buy(context, ref, perfume)),
                    const SizedBox(height: 32),
                    Text(context.tr('Пирамида нот', 'Note pyramid'),
                        style: const TextStyle(
                            fontFamily: 'CormorantGaramond', fontSize: 28)),
                    const SizedBox(height: 16),
                    ...['top', 'middle', 'base'].map((level) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                  level == 'top'
                                      ? Icons.wb_sunny_outlined
                                      : level == 'middle'
                                          ? Icons.local_florist_outlined
                                          : Icons.forest_outlined,
                                  color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(
                                        context.tr(
                                            {
                                              'top': 'Верхние ноты',
                                              'middle': 'Сердце',
                                              'base': 'База'
                                            }[level]!,
                                            {
                                              'top': 'Top notes',
                                              'middle': 'Heart notes',
                                              'base': 'Base notes'
                                            }[level]!),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall),
                                    const SizedBox(height: 8),
                                    Wrap(
                                        spacing: 6,
                                        children: (perfume.notes[level] ?? [])
                                            .map((n) => Chip(
                                                label: Text(context.label(n))))
                                            .toList()),
                                  ]))
                            ]))),
                    const SizedBox(height: 16),
                    Card(
                        child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(children: [
                              _stat(
                                  context,
                                  Icons.schedule,
                                  context.tr('Стойкость', 'Longevity'),
                                  context.tr('Около ${perfume.longevity} часов',
                                      'About ${perfume.longevity} hours')),
                              const Divider(height: 28),
                              _stat(
                                  context,
                                  Icons.air,
                                  context.tr('Шлейф', 'Sillage'),
                                  context.tr(
                                      perfume.sillage == 'strong'
                                          ? 'Выраженный'
                                          : 'Умеренный',
                                      perfume.sillage == 'strong'
                                          ? 'Strong'
                                          : 'Moderate')),
                              const Divider(height: 28),
                              _stat(
                                  context,
                                  Icons.wb_sunny_outlined,
                                  context.tr('Сезон', 'Season'),
                                  perfume.season.map(context.label).join(', ')),
                            ]))),
                    const SizedBox(height: 32),
                    Text(context.tr('В том же настроении', 'In the same mood'),
                        style: const TextStyle(
                            fontFamily: 'CormorantGaramond', fontSize: 26)),
                    const SizedBox(height: 16),
                    PerfumeGrid(
                        perfumes: catalog
                            .where((p) =>
                                perfume.similarPerfumes.contains(p.id) &&
                                p.id != id)
                            .take(4)
                            .toList()),
                    const SizedBox(height: 30),
                    ReviewsSection(perfumeId: id),
                    const SizedBox(height: 30),
                  ]);
            })
      ]));
  Widget _stat(
          BuildContext context, IconData icon, String label, String value) =>
      Row(children: [
        Icon(icon, size: 22),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        const SizedBox(width: 10),
        Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: TextStyle(color: Theme.of(context).colorScheme.primary)))
      ]);
  Future<void> _buy(
      BuildContext context, WidgetRef ref, Perfume perfume) async {
    final base = Uri.tryParse(AppConfig.affiliateBase);
    if (base == null || base.scheme != 'https' || base.host.isEmpty) {
      await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
                  title: Text(context.tr(
                      'Магазины скоро появятся', 'Stores are coming soon')),
                  content: Text(context.tr(
                      'Партнёрские ссылки пока не подключены.',
                      'Affiliate links are not connected yet.')),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(context.tr('Понятно', 'Got it')))
                  ]));
      return;
    }
    final open = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: Text(context.tr('Перейти в магазин?', 'Open store?')),
                content: Text(context.tr(
                    'Партнёрская ссылка: ScentMatch может получить комиссию. Цена определяется магазином.',
                    'Affiliate link: ScentMatch may receive a commission. The store sets the price.')),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(context.tr('Отмена', 'Cancel'))),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(context.tr('Перейти', 'Open')))
                ]));
    if (open != true) return;
    final url = base.replace(queryParameters: {
      ...base.queryParameters,
      'perfume': perfume.id,
      'q': '${perfume.brand} ${perfume.name}'
    });
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw StateError('Cannot open store');
    }
    await ref
        .read(analyticsProvider)
        .event('affiliate_opened', {'perfume_id': perfume.id});
  }
}
