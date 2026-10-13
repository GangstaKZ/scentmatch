import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_strings.dart';

class ProScreen extends StatelessWidget {
  const ProScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          title: const Text('ScentMatch Pro'),
          leading: IconButton(
              tooltip: context.tr('Назад', 'Back'),
              icon: const Icon(Icons.arrow_back),
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/profile'))),
      body: ListView(padding: const EdgeInsets.all(28), children: [
        const SizedBox(height: 36),
        Icon(Icons.auto_awesome,
            size: 70, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 30),
        Text(
            context.tr(
                'Ещё ближе\nк своему аромату', 'Even closer\nto your scent'),
            style:
                const TextStyle(fontFamily: 'CormorantGaramond', fontSize: 42)),
        const SizedBox(height: 24),
        ...[
          context.tr('Расширенные ИИ-подборки', 'Advanced AI selections'),
          context.tr('Сравнение ароматов', 'Fragrance comparisons'),
          context.tr('Персональный парфюмерный гардероб',
              'Personal fragrance wardrobe')
        ].map((text) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.check_circle_outline),
            title: Text(text))),
        const SizedBox(height: 24),
        Card(
            child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                    context.tr(
                        'Pro скоро появится. Это предварительный обзор: подписки и платежи пока недоступны. Все функции текущего MVP бесплатны.',
                        'Pro is coming soon. This is a preview: subscriptions and payments are not available yet. All current MVP features are free.'),
                    style: const TextStyle(height: 1.6)))),
      ]));
}
