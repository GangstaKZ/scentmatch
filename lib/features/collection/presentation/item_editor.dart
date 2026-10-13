import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/providers.dart';
import '../../../shared/widgets/action_button.dart';
import '../domain/collection_item.dart';

Future<void> editCollectionItem(BuildContext context, CollectionItem item) =>
    showDialog<void>(context: context, builder: (_) => ItemEditor(item: item));

class ItemEditor extends ConsumerStatefulWidget {
  const ItemEditor({super.key, required this.item});
  final CollectionItem item;
  @override
  ConsumerState<ItemEditor> createState() => _ItemEditorState();
}

class _ItemEditorState extends ConsumerState<ItemEditor> {
  late final TextEditingController note;
  late int rating;
  late CollectionType type;
  @override
  void initState() {
    super.initState();
    note = TextEditingController(text: widget.item.note);
    rating = widget.item.rating;
    type = widget.item.type;
  }

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
          title: Text(context.tr('Мои впечатления', 'My impressions')),
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
                TextButton(
                    onPressed: () => setState(() => rating = 0),
                    child: Text(context.tr('Без оценки', 'No rating'))),
                TextField(
                    controller: note,
                    maxLines: 4,
                    maxLength: 2000,
                    decoration: InputDecoration(
                        labelText: context.tr('Личная заметка', 'Private note'),
                        hintText: context.tr('Как раскрывается на вашей коже?',
                            'How does it develop on your skin?'))),
                const SizedBox(height: 12),
                DropdownButtonFormField<CollectionType>(
                    value: type,
                    items: CollectionType.values
                        .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t == CollectionType.collection
                                ? context.tr('Коллекция', 'Collection')
                                : 'Wishlist')))
                        .toList(),
                    onChanged: (v) => setState(() => type = v!)),
              ]))),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.tr('Отмена', 'Cancel'))),
            ActionButton(
                label: context.tr('Сохранить', 'Save'),
                icon: Icons.check,
                action: () async {
                  await ref.read(actionsProvider).saveItem(CollectionItem(
                      perfumeId: widget.item.perfumeId,
                      type: type,
                      addedAt: widget.item.addedAt,
                      rating: rating,
                      note: note.text.trim()));
                  if (context.mounted) Navigator.pop(context);
                })
          ]);
}
