import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/providers.dart';
import '../../../shared/widgets/action_button.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
      body: SafeArea(
          child: Center(
              child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: SingleChildScrollView(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const Icon(Icons.blur_on_rounded, size: 32),
                              const SizedBox(width: 10),
                              const Text('SCENTMATCH',
                                  style: TextStyle(
                                      letterSpacing: 3, fontSize: 13)),
                              const Spacer(),
                              TextButton(
                                  onPressed: () => ref
                                      .read(settingsProvider.notifier)
                                      .update(
                                          locale: ref
                                                      .read(settingsProvider)
                                                      .locale ==
                                                  'ru'
                                              ? 'en'
                                              : 'ru'),
                                  child: Text(context.tr('EN', 'RU')))
                            ]),
                            const SizedBox(height: 52),
                            Center(
                                child: Container(
                                    width: 240,
                                    height: 240,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(colors: [
                                          Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(.25),
                                          Colors.transparent
                                        ])),
                                    child: Icon(Icons.spa_outlined,
                                        size: 120,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary))),
                            const SizedBox(height: 32),
                            Text(
                                context.tr('Ваш аромат.\nВаша история.',
                                    'Your scent.\nYour story.'),
                                style: const TextStyle(
                                    fontFamily: 'CormorantGaramond',
                                    fontSize: 46,
                                    height: 1.12)),
                            const SizedBox(height: 20),
                            Text(
                                context.tr(
                                    'Находите ароматы, которые откликаются именно вам. Сохраняйте открытия и создавайте свою коллекцию.',
                                    'Discover fragrances that feel like you. Save your discoveries and build your collection.'),
                                style:
                                    const TextStyle(fontSize: 16, height: 1.7)),
                            const SizedBox(height: 36),
                            SizedBox(
                                width: double.infinity,
                                child: ActionButton(
                                    label: context.tr(
                                        'Найти свой аромат', 'Find my scent'),
                                    action: () => ref
                                        .read(settingsProvider.notifier)
                                        .update(welcomeSeen: true))),
                            const SizedBox(height: 14),
                            Text(
                                context.tr('7 вопросов · около 1 минуты',
                                    '7 questions · about 1 minute'),
                                style: Theme.of(context).textTheme.bodySmall),
                            if (!AppConfig.firebase)
                              Padding(
                                  padding: const EdgeInsets.only(top: 24),
                                  child: Text(
                                      context.tr(
                                          'Деморежим: данные сохраняются на этом устройстве. Рекомендации основаны на ваших ответах.',
                                          'Demo mode: data is saved on this device. Recommendations are based on your answers.'),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall)),
                          ]))))));
}
