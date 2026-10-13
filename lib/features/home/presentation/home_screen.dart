import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers.dart';
import '../../../core/localization/app_strings.dart';
import '../../../shared/widgets/async_panel.dart';
import '../../../shared/widgets/perfume_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
      body: SafeArea(
          child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(catalogProvider);
                ref.invalidate(recommendationsProvider);
                await ref.read(catalogProvider.future);
              },
              child: ListView(padding: const EdgeInsets.all(24), children: [
                Row(children: [
                  const Icon(Icons.blur_on, size: 28),
                  const SizedBox(width: 8),
                  const Text('SCENTMATCH',
                      style: TextStyle(letterSpacing: 3, fontSize: 12)),
                  const Spacer(),
                  IconButton(
                      tooltip: context.tr('Профиль', 'Profile'),
                      onPressed: () => context.go('/profile'),
                      icon: const Icon(Icons.person_outline))
                ]),
                const SizedBox(height: 24),
                Text(context.tr('Искусство быть собой', 'The art of being you'),
                    style: const TextStyle(
                        fontFamily: 'CormorantGaramond',
                        fontSize: 36,
                        height: 1.15)),
                const SizedBox(height: 10),
                Text(
                    context.tr(
                        'Ваш следующий любимый аромат — ближе, чем кажется.',
                        'Your next favorite scent is closer than you think.'),
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 26),
                TextField(
                    readOnly: true,
                    onTap: () => context.go('/search'),
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: context.tr(
                            'Название или бренд', 'Fragrance or brand'))),
                const SizedBox(height: 20),
                Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        gradient: const LinearGradient(
                            colors: [Color(0xFF354936), Color(0xFF223029)])),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(children: [
                            Icon(Icons.auto_awesome,
                                color: Color(0xFFDEDDAD), size: 18),
                            SizedBox(width: 8),
                            Text('SCENT DNA',
                                style: TextStyle(
                                    color: Color(0xFFDEDDAD),
                                    letterSpacing: 2,
                                    fontSize: 11))
                          ]),
                          const SizedBox(height: 16),
                          Text(
                              context.tr('Ароматы с вашим\nхарактером',
                                  'Scents with your\ncharacter'),
                              style: const TextStyle(
                                  fontFamily: 'CormorantGaramond',
                                  fontSize: 30,
                                  color: Color(0xFFF2EEDF))),
                          const SizedBox(height: 12),
                          Text(
                              context.tr(
                                  'Подборка по вашему парфюмерному портрету',
                                  'Curated for your scent portrait'),
                              style: const TextStyle(color: Color(0xFFCBD7C5))),
                          const SizedBox(height: 18),
                          OutlinedButton(
                              onPressed: () => context.push('/quiz'),
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFF2EEDF),
                                  side: const BorderSide(
                                      color: Color(0xFF84957D))),
                              child: Text(context.tr('Обновить мой портрет',
                                  'Update my portrait'))),
                        ])),
                const SizedBox(height: 30),
                _heading(context,
                    context.tr('Подобрано для вас', 'Selected for you')),
                Text(
                    context.tr(
                        'Процент — совпадение с ответами квиза, а не оценка ИИ.',
                        'The percentage measures quiz matching, not AI confidence.'),
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 16),
                AsyncPanel(
                    value: ref.watch(recommendationsProvider),
                    retry: () => ref.invalidate(recommendationsProvider),
                    builder: (recommendations) {
                      final catalog =
                          ref.watch(catalogProvider).valueOrNull ?? [];
                      final ids =
                          recommendations.map((r) => r.perfumeId).toList();
                      final selected = ids
                          .map((id) => catalog.where((p) => p.id == id))
                          .expand((p) => p)
                          .toList();
                      if (selected.isEmpty) {
                        return EmptyPanel(
                            icon: Icons.spa_outlined,
                            title: context.tr('Пока нет рекомендаций',
                                'No recommendations yet'),
                            subtitle: context.tr(
                                'Завершите квиз и проверьте каталог.',
                                'Complete the quiz and check the catalog.'));
                      }
                      return PerfumeGrid(perfumes: selected, scores: {
                        for (final r in recommendations) r.perfumeId: r.score
                      });
                    }),
                const SizedBox(height: 30),
                Row(children: [
                  Expanded(
                      child: _heading(
                          context,
                          context.tr(
                              'Сейчас в центре внимания', 'In the spotlight'))),
                  TextButton(
                      onPressed: () => context.go('/search'),
                      child: Text(context.tr('Все', 'View all')))
                ]),
                const SizedBox(height: 10),
                AsyncPanel(
                    value: ref.watch(catalogProvider),
                    retry: () => ref.invalidate(catalogProvider),
                    builder: (catalog) {
                      final sorted = [...catalog]
                        ..sort((a, b) => b.popularity.compareTo(a.popularity));
                      return PerfumeGrid(perfumes: sorted.take(4).toList());
                    }),
                const SizedBox(height: 24),
                Card(
                    child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const Icon(Icons.document_scanner_outlined),
                        title: Text(
                            context.tr('Сканировать флакон', 'Scan a bottle')),
                        subtitle: Text(context.tr(
                            'Скоро: распознавание по фото',
                            'Coming soon: photo recognition')),
                        trailing: const Icon(Icons.arrow_forward_rounded),
                        onTap: () => showDialog<void>(
                            context: context,
                            builder: (context) => AlertDialog(
                                    title: Text(context.tr(
                                        'Сканер скоро появится',
                                        'Scanner is coming soon')),
                                    content: Text(context.tr(
                                        'Распознавание флакона ещё не подключено. Пока найдите аромат по названию.',
                                        'Bottle recognition is not connected yet. Search by name for now.')),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text(
                                              context.tr('Понятно', 'Got it')))
                                    ])))),
                const SizedBox(height: 24),
              ]))));
  Widget _heading(BuildContext context, String text) => Text(text,
      style: const TextStyle(fontFamily: 'CormorantGaramond', fontSize: 25));
}
