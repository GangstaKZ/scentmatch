import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/providers.dart';
import '../../../shared/widgets/action_button.dart';
import '../../../shared/widgets/async_panel.dart';
import '../../../shared/widgets/perfume_card.dart';
import '../domain/collection_item.dart';
import 'item_editor.dart';

class CollectionScreen extends ConsumerWidget {
  const CollectionScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
              title: Text(
                  context.tr('Моя парфюмерная полка', 'My fragrance shelf')),
              bottom: TabBar(tabs: [
                Tab(text: context.tr('Коллекция', 'Collection')),
                const Tab(text: 'Wishlist')
              ])),
          body: TabBarView(
              children: CollectionType.values
                  .map((type) =>
                      ListView(padding: const EdgeInsets.all(24), children: [
                        AsyncPanel(
                            value: ref.watch(collectionProvider),
                            retry: () => ref.invalidate(collectionProvider),
                            builder: (items) => AsyncPanel(
                                value: ref.watch(catalogProvider),
                                retry: () => ref.invalidate(catalogProvider),
                                builder: (catalog) {
                                  final filtered = items
                                      .where((i) => i.type == type)
                                      .toList()
                                    ..sort((a, b) =>
                                        b.addedAt.compareTo(a.addedAt));
                                  if (filtered.isEmpty) {
                                    return EmptyPanel(
                                        icon: type == CollectionType.collection
                                            ? Icons.inventory_2_outlined
                                            : Icons.favorite_border,
                                        title: context.tr(
                                            'Здесь начинается ваша история',
                                            'Your story starts here'),
                                        subtitle: context.tr(
                                            'Сохраните аромат из каталога — он появится на вашей полке.',
                                            'Save a fragrance from the catalog to add it to your shelf.'),
                                        action: FilledButton(
                                            onPressed: () =>
                                                context.go('/search'),
                                            child: Text(context.tr(
                                                'Исследовать ароматы',
                                                'Explore fragrances'))));
                                  }
                                  return Column(
                                      children: filtered.map((item) {
                                    final matches = catalog
                                        .where((p) => p.id == item.perfumeId);
                                    final perfume =
                                        matches.isEmpty ? null : matches.first;
                                    return Card(
                                        margin:
                                            const EdgeInsets.only(bottom: 14),
                                        child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  InkWell(
                                                      onTap: perfume == null
                                                          ? null
                                                          : () => context.push(
                                                              '/perfume/${perfume.id}'),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              18),
                                                      child: Row(children: [
                                                        if (perfume != null)
                                                          SizedBox(
                                                              width: 80,
                                                              child: BottleArt(
                                                                  perfume:
                                                                      perfume,
                                                                  height: 100)),
                                                        const SizedBox(
                                                            width: 16),
                                                        Expanded(
                                                            child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                              Text(
                                                                  perfume?.brand ??
                                                                      '',
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .bodySmall),
                                                              const SizedBox(
                                                                  height: 6),
                                                              Text(
                                                                  perfume?.name ??
                                                                      context.tr('Аромат недоступен',
                                                                          'Fragrance unavailable'),
                                                                  style: const TextStyle(
                                                                      fontFamily:
                                                                          'serif',
                                                                      fontSize:
                                                                          24)),
                                                              const SizedBox(
                                                                  height: 8),
                                                              Text(item.rating ==
                                                                      0
                                                                  ? context.tr(
                                                                      'Пока без оценки',
                                                                      'Not rated yet')
                                                                  : '${'★' * item.rating}${'☆' * (5 - item.rating)}'),
                                                            ]))
                                                      ])),
                                                  if (item.note.isNotEmpty)
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 14),
                                                        child: Text(item.note,
                                                            maxLines: 3,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis)),
                                                  const SizedBox(height: 14),
                                                  Wrap(
                                                      spacing: 10,
                                                      runSpacing: 10,
                                                      children: [
                                                        TextButton.icon(
                                                            onPressed: () =>
                                                                editCollectionItem(
                                                                    context,
                                                                    item),
                                                            icon: const Icon(
                                                                Icons
                                                                    .edit_outlined,
                                                                size: 18),
                                                            label: Text(context.tr(
                                                                'Оценка и заметка',
                                                                'Rating & note'))),
                                                        ActionButton(
                                                            tonal: true,
                                                            label: context.tr(
                                                                'Удалить',
                                                                'Remove'),
                                                            icon: Icons
                                                                .delete_outline,
                                                            action: () => ref
                                                                .read(
                                                                    actionsProvider)
                                                                .removeItem(item
                                                                    .perfumeId)),
                                                      ]),
                                                ])));
                                  }).toList());
                                })),
                      ]))
                  .toList())));
}
