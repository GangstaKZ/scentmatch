import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/providers.dart';
import '../../../core/localization/app_strings.dart';
import '../../../shared/widgets/action_button.dart';
import '../../../shared/widgets/async_panel.dart';
import '../../onboarding/presentation/quiz_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return Scaffold(
        appBar: AppBar(title: Text(context.tr('Мой профиль', 'My profile'))),
        body: ListView(padding: const EdgeInsets.all(24), children: [
          AsyncPanel(
              value: ref.watch(profileProvider),
              retry: () => ref.invalidate(profileProvider),
              builder: (profile) {
                if (profile == null) return const SizedBox.shrink();
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        CircleAvatar(
                            radius: 34,
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            child: const Icon(Icons.person_outline, size: 36)),
                        const SizedBox(width: 18),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(
                                  !AppConfig.firebase
                                      ? context.tr('Исследователь', 'Explorer')
                                      : profile.name.isEmpty
                                          ? context.tr(
                                              'Мой аккаунт', 'My account')
                                          : profile.name,
                                  style: const TextStyle(
                                      fontFamily: 'CormorantGaramond',
                                      fontSize: 27)),
                              const SizedBox(height: 6),
                              Text(profile.email.isEmpty
                                  ? context.tr('Локальный демопрофиль',
                                      'Local demo profile')
                                  : profile.email),
                            ]))
                      ]),
                      const SizedBox(height: 28),
                      Card(
                          child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(children: [
                                      Expanded(
                                          child: Text('ScentMatch Pro',
                                              style: TextStyle(
                                                  fontFamily:
                                                      'CormorantGaramond',
                                                  fontSize: 27))),
                                      Icon(Icons.auto_awesome)
                                    ]),
                                    const SizedBox(height: 12),
                                    Text(profile.isPro
                                        ? context.tr('Подписка активна',
                                            'Subscription active')
                                        : context.tr(
                                            'Больше возможностей для ваших открытий',
                                            'More room for your discoveries')),
                                    const SizedBox(height: 16),
                                    FilledButton(
                                        onPressed: () => context.push('/pro'),
                                        child: Text(context.tr(
                                            'Узнать о Pro', 'Explore Pro'))),
                                  ]))),
                      const SizedBox(height: 28),
                      Row(children: [
                        Expanded(
                            child: Text(
                                context.tr('Мой парфюмерный портрет',
                                    'My scent portrait'),
                                style: const TextStyle(
                                    fontFamily: 'CormorantGaramond',
                                    fontSize: 24))),
                        IconButton(
                            tooltip:
                                context.tr('Изменить ответы', 'Edit answers'),
                            onPressed: () => context.push('/quiz'),
                            icon: const Icon(Icons.edit_outlined))
                      ]),
                      const SizedBox(height: 12),
                      ...quizQuestions.map((q) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(q.icon),
                          title: Text(context.tr(q.ru, q.en),
                              style: Theme.of(context).textTheme.bodySmall),
                          subtitle: Text(context
                              .label(profile.quizAnswers[q.key] ?? 'any')))),
                    ]);
              }),
          const SizedBox(height: 24),
          Text(context.tr('Настройки', 'Settings'),
              style: const TextStyle(
                  fontFamily: 'CormorantGaramond', fontSize: 26)),
          SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.dark_mode_outlined),
              title: Text(context.tr('Тёмная тема', 'Dark theme')),
              value: settings.dark,
              onChanged: (value) =>
                  ref.read(settingsProvider.notifier).update(dark: value)),
          ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.language),
              title: Text(context.tr('Язык', 'Language')),
              trailing: DropdownButton<String>(
                  value: settings.locale,
                  items: const [
                    DropdownMenuItem(value: 'ru', child: Text('Русский')),
                    DropdownMenuItem(value: 'en', child: Text('English'))
                  ],
                  onChanged: (value) => ref
                      .read(settingsProvider.notifier)
                      .update(locale: value))),
          const SizedBox(height: 20),
          if (AppConfig.firebase)
            ActionButton(
                tonal: true,
                icon: Icons.logout,
                label: context.tr('Выйти', 'Sign out'),
                action: () async {
                  await ref.read(authRepositoryProvider).signOut();
                  await ref.read(subscriptionProvider).signOut();
                }),
          const SizedBox(height: 24),
          Text(
              context.tr('ScentMatch 1.0 · Ваш личный парфюмерный ассистент',
                  'ScentMatch 1.0 · Your personal fragrance companion'),
              style: Theme.of(context).textTheme.bodySmall),
        ]));
  }
}
