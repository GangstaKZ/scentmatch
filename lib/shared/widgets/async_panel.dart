import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/app_strings.dart';

class AsyncPanel<T> extends StatelessWidget {
  const AsyncPanel(
      {super.key,
      required this.value,
      required this.builder,
      required this.retry});
  final AsyncValue<T> value;
  final Widget Function(T) builder;
  final VoidCallback retry;
  @override
  Widget build(BuildContext context) => value.when(
      data: builder,
      loading: () => const Padding(
          padding: EdgeInsets.all(48),
          child: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cloud_off_outlined, size: 40),
            const SizedBox(height: 16),
            Text(
                context.tr(
                    'Не удалось загрузить данные. Проверьте подключение.',
                    'Unable to load data. Check your connection.'),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton(
                onPressed: retry, child: Text(context.tr('Повторить', 'Retry')))
          ])));
}

class EmptyPanel extends StatelessWidget {
  const EmptyPanel(
      {super.key,
      required this.icon,
      required this.title,
      required this.subtitle,
      this.action});
  final IconData icon;
  final String title, subtitle;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 52, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 20),
        Text(title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(subtitle, textAlign: TextAlign.center),
        if (action != null) ...[const SizedBox(height: 20), action!]
      ]));
}
