import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/localization/app_strings.dart';
import '../../../shared/widgets/action_button.dart';
import '../../../shared/widgets/async_panel.dart';

class ReviewsSection extends ConsumerWidget {
  const ReviewsSection({super.key, required this.perfumeId});
  final String perfumeId;
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(context.tr('Впечатления', 'Reviews'),
                  style: const TextStyle(
                      fontFamily: 'CormorantGaramond', fontSize: 26))),
          TextButton(
              onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => ReviewEditor(perfumeId: perfumeId)),
              child: Text(context.tr('Написать', 'Write')))
        ]),
        AsyncPanel(
            value: ref.watch(reviewsProvider(perfumeId)),
            retry: () => ref.invalidate(reviewsProvider(perfumeId)),
            builder: (reviews) {
              if (reviews.isEmpty) {
                return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(context.tr(
                        'Будьте первым, кто поделится впечатлением.',
                        'Be the first to share your impressions.')));
              }
              return Column(
                  children: reviews
                      .map((r) => Card(
                          child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      const Icon(Icons.person_outline,
                                          size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                          child: Text(r.userId ==
                                                  ref
                                                      .watch(identityProvider)
                                                      .valueOrNull
                                                      ?.id
                                              ? context.tr(
                                                  'Ваш отзыв', 'Your review')
                                              : context.tr(
                                                  'Пользователь ScentMatch',
                                                  'ScentMatch member'))),
                                      Text('${r.rating} ★',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary))
                                    ]),
                                    const SizedBox(height: 12),
                                    Text(r.text),
                                    const SizedBox(height: 10),
                                    Text(
                                        '${r.createdAt.day.toString().padLeft(2, '0')}.${r.createdAt.month.toString().padLeft(2, '0')}.${r.createdAt.year}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall),
                                  ]))))
                      .toList());
            }),
      ]);
}

class ReviewEditor extends ConsumerStatefulWidget {
  const ReviewEditor({super.key, required this.perfumeId});
  final String perfumeId;
  @override
  ConsumerState<ReviewEditor> createState() => _ReviewEditorState();
}

class _ReviewEditorState extends ConsumerState<ReviewEditor> {
  final text = TextEditingController();
  int rating = 5;
  @override
  void initState() {
    super.initState();
    final mine = ref
        .read(reviewsProvider(widget.perfumeId))
        .valueOrNull
        ?.where((r) => r.userId == ref.read(identityProvider).valueOrNull?.id);
    if (mine != null && mine.isNotEmpty) {
      text.text = mine.first.text;
      rating = mine.first.rating;
    }
  }

  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
          title: Text(context.tr('Ваше впечатление', 'Your impression')),
          content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                Wrap(
                    children: List.generate(
                        5,
                        (i) => IconButton(
                            tooltip: '${i + 1}/5',
                            onPressed: () => setState(() => rating = i + 1),
                            icon: Icon(
                                i < rating
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color:
                                    Theme.of(context).colorScheme.primary)))),
                TextField(
                    controller: text,
                    maxLines: 5,
                    maxLength: 2000,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                        hintText: context.tr(
                            'Расскажите о звучании и стойкости',
                            'Share your thoughts on the scent and longevity'))),
              ]))),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.tr('Отмена', 'Cancel'))),
            ActionButton(
                label: context.tr('Опубликовать', 'Publish'),
                icon: Icons.check,
                action: text.text.trim().isEmpty
                    ? null
                    : () async {
                        await ref
                            .read(actionsProvider)
                            .review(widget.perfumeId, text.text, rating);
                        if (context.mounted) Navigator.pop(context);
                      })
          ]);
}
